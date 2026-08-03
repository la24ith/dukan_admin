// lib/features/categories/domain/repositories/categories_repository.dart
import 'dart:io';
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/category_entity.dart';

abstract class CategoriesRepository {
  Future<Either<Failure, List<CategoryEntity>>> getCategories();
  Future<Either<Failure, CategoryEntity>> addCategory({
    required String name,
    int sortOrder,
    File? image,
  });
  Future<Either<Failure, CategoryEntity>> updateCategory({
    required String id,
    required String name,
    int sortOrder,
    bool isActive,
    File? newImage,
    String? existingImageUrl,
  });
  Future<Either<Failure, void>> deleteCategory(String id);
}
