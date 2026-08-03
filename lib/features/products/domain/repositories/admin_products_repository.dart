// lib/features/products/domain/repositories/admin_products_repository.dart
import 'dart:io';
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/admin_product_entity.dart';

abstract class AdminProductsRepository {
  Future<Either<Failure, List<AdminProductEntity>>> getProducts({
    String? categoryId,
    bool? isActive,
  });
  Future<Either<Failure, AdminProductEntity>> addProduct({
    required String categoryId,
    required String name,
    String? description,
    required int price,
    required int stockQuantity,
    File? mainImage,
  });
  Future<Either<Failure, AdminProductEntity>> updateProduct({
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
  Future<Either<Failure, void>> deleteProduct(String id);
  Future<Either<Failure, void>> adjustStock({
    required String id,
    required int newQuantity,
  });
}
