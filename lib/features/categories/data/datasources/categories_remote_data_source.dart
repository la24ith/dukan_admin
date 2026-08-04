// lib/features/categories/data/datasources/categories_remote_data_source.dart
import 'dart:io';
import 'package:dukan_admin/core/error/supabase_guard.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/services/image_upload_service.dart';
import '../models/category_model.dart';

abstract class CategoriesRemoteDataSource {
  Future<List<CategoryModel>> getCategories();
  Future<CategoryModel> addCategory({
    required String name,
    int sortOrder,
    File? image,
  });
  Future<CategoryModel> updateCategory({
    required String id,
    required String name,
    int sortOrder,
    bool isActive,
    File? newImage,
    String? existingImageUrl,
  });
  Future<void> deleteCategory(String id);
}

class CategoriesRemoteDataSourceImpl implements CategoriesRemoteDataSource {
  final SupabaseClient client;
  final ImageUploadService imageUploadService;

  CategoriesRemoteDataSourceImpl({
    required this.client,
    required this.imageUploadService,
  });

  @override
  Future<List<CategoryModel>> getCategories() async {
    return guardSupabaseCall(() async {
      // تحقق من الـ session الحالية
      final session = client.auth.currentSession;
      debugPrint(
        '[CATEGORIES] session: ${session != null ? "موجودة" : "null"}',
      );
      debugPrint('[CATEGORIES] user id: ${client.auth.currentUser?.id}');
      debugPrint(
        '[CATEGORIES] access token: ${session?.accessToken.substring(0, 20)}...',
      );

      final rows = await client
          .from('categories')
          .select()
          .order('sort_order')
          .order('created_at', ascending: false);
      return (rows as List).map((e) => CategoryModel.fromJson(e)).toList();
    });
  }

  @override
  Future<CategoryModel> addCategory({
    required String name,
    int sortOrder = 0,
    File? image,
  }) async {
    return guardSupabaseCall(() async {
      String? imageUrl;
      if (image != null) {
        imageUrl = await imageUploadService.uploadImage(
          file: image,
          folder: 'categories',
        );
      }
      final row = await client
          .from('categories')
          .insert({
            'name': name,
            'sort_order': sortOrder,
            'image_url': imageUrl,
            'is_active': true,
          })
          .select()
          .single();
      return CategoryModel.fromJson(row);
    });
  }

  @override
  Future<CategoryModel> updateCategory({
    required String id,
    required String name,
    int sortOrder = 0,
    bool isActive = true,
    File? newImage,
    String? existingImageUrl,
  }) async {
    return guardSupabaseCall(() async {
      String? imageUrl = existingImageUrl;
      if (newImage != null) {
        imageUrl = await imageUploadService.uploadImage(
          file: newImage,
          folder: 'categories',
          existingPath: existingImageUrl != null
              ? imageUploadService.pathFromUrlPublic(existingImageUrl)
              : null,
        );
      }
      final row = await client
          .from('categories')
          .update({
            'name': name,
            'sort_order': sortOrder,
            'is_active': isActive,
            'image_url': imageUrl,
          })
          .eq('id', id)
          .select()
          .single();
      return CategoryModel.fromJson(row);
    });
  }

  @override
  Future<void> deleteCategory(String id) async {
    return guardSupabaseCall(() async {
      // احذف الصورة أولاً إن وُجدت
      final row = await client
          .from('categories')
          .select('image_url')
          .eq('id', id)
          .single();
      final imageUrl = row['image_url'] as String?;
      if (imageUrl != null) await imageUploadService.deleteImage(imageUrl);

      await client.from('categories').delete().eq('id', id);
    });
  }
}
