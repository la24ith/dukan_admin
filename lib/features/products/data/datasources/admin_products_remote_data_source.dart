// lib/features/products/data/datasources/admin_products_remote_data_source.dart
import 'dart:io';
import 'package:dukan_admin/core/error/supabase_guard.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/services/image_upload_service.dart';
import '../models/admin_product_model.dart';

abstract class AdminProductsRemoteDataSource {
  Future<List<AdminProductModel>> getProducts({
    String? categoryId,
    bool? isActive,
  });
  Future<AdminProductModel> addProduct({
    required String categoryId,
    required String name,
    String? description,
    required int price,
    required int stockQuantity,
    File? mainImage,
  });
  Future<AdminProductModel> updateProduct({
    required String id,
    required String categoryId,
    required String name,
    String? description,
    required int price,
    required int stockQuantity,
    bool isActive,
    File? newMainImage,
    String? existingMainImageUrl,
  });
  Future<void> deleteProduct(String id);
  Future<void> adjustStock({required String id, required int newQuantity});
}

class AdminProductsRemoteDataSourceImpl
    implements AdminProductsRemoteDataSource {
  final SupabaseClient client;
  final ImageUploadService imageUploadService;

  AdminProductsRemoteDataSourceImpl({
    required this.client,
    required this.imageUploadService,
  });

  static const _select = '*, categories(name)';

  @override
  Future<List<AdminProductModel>> getProducts({
    String? categoryId,
    bool? isActive,
  }) async {
    return guardSupabaseCall(() async {
      var query = client.from('products').select(_select);
      if (categoryId != null) query = query.eq('category_id', categoryId);
      if (isActive != null) query = query.eq('is_active', isActive);
      final rows =
          await query.order('created_at', ascending: false);
      return (rows as List)
          .map((e) => AdminProductModel.fromJson(e))
          .toList();
    });
  }

  @override
  Future<AdminProductModel> addProduct({
    required String categoryId,
    required String name,
    String? description,
    required int price,
    required int stockQuantity,
    File? mainImage,
  }) async {
    return guardSupabaseCall(() async {
      String? imageUrl;
      if (mainImage != null) {
        imageUrl = await imageUploadService.uploadImage(
          file: mainImage,
          folder: 'products',
        );
      }
      final row = await client
          .from('products')
          .insert({
            'category_id': categoryId,
            'name': name,
            'description': description,
            'price': price,
            'stock_quantity': stockQuantity,
            'main_image_url': imageUrl,
            'is_active': true,
          })
          .select(_select)
          .single();
      return AdminProductModel.fromJson(row);
    });
  }

  @override
  Future<AdminProductModel> updateProduct({
    required String id,
    required String categoryId,
    required String name,
    String? description,
    required int price,
    required int stockQuantity,
    bool isActive = true,
    File? newMainImage,
    String? existingMainImageUrl,
  }) async {
    return guardSupabaseCall(() async {
      String? imageUrl = existingMainImageUrl;
      if (newMainImage != null) {
        imageUrl = await imageUploadService.uploadImage(
          file: newMainImage,
          folder: 'products',
          existingPath: existingMainImageUrl != null
              ? imageUploadService.pathFromUrlPublic(existingMainImageUrl)
              : null,
        );
      }
      final row = await client
          .from('products')
          .update({
            'category_id': categoryId,
            'name': name,
            'description': description,
            'price': price,
            'stock_quantity': stockQuantity,
            'is_active': isActive,
            'main_image_url': imageUrl,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', id)
          .select(_select)
          .single();
      return AdminProductModel.fromJson(row);
    });
  }

  @override
  Future<void> deleteProduct(String id) async {
    return guardSupabaseCall(() async {
      final row = await client
          .from('products')
          .select('main_image_url')
          .eq('id', id)
          .single();
      final imageUrl = row['main_image_url'] as String?;
      if (imageUrl != null) await imageUploadService.deleteImage(imageUrl);
      await client.from('products').delete().eq('id', id);
    });
  }

  @override
  Future<void> adjustStock({
    required String id,
    required int newQuantity,
  }) async {
    return guardSupabaseCall(() async {
      await client.from('products').update({
        'stock_quantity': newQuantity,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', id);
    });
  }
}
