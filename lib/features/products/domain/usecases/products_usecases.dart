// lib/features/products/domain/usecases/products_usecases.dart
import 'dart:io';
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/admin_product_entity.dart';
import '../repositories/admin_products_repository.dart';

class GetAdminProducts {
  final AdminProductsRepository repository;
  GetAdminProducts(this.repository);
  Future<Either<Failure, List<AdminProductEntity>>> call({
    String? categoryId,
    bool? isActive,
  }) =>
      repository.getProducts(categoryId: categoryId, isActive: isActive);
}

class AddAdminProduct {
  final AdminProductsRepository repository;
  AddAdminProduct(this.repository);
  Future<Either<Failure, AdminProductEntity>> call({
    required String categoryId,
    required String name,
    String? description,
    required int price,
    required int stockQuantity,
    File? mainImage,
  }) =>
      repository.addProduct(
        categoryId: categoryId,
        name: name,
        description: description,
        price: price,
        stockQuantity: stockQuantity,
        mainImage: mainImage,
      );
}

class UpdateAdminProduct {
  final AdminProductsRepository repository;
  UpdateAdminProduct(this.repository);
  Future<Either<Failure, AdminProductEntity>> call({
    required String id,
    required String categoryId,
    required String name,
    String? description,
    required int price,
    required int stockQuantity,
    bool isActive = true,
    File? newMainImage,
    String? existingMainImageUrl,
  }) =>
      repository.updateProduct(
        id: id,
        categoryId: categoryId,
        name: name,
        description: description,
        price: price,
        stockQuantity: stockQuantity,
        isActive: isActive,
        newMainImage: newMainImage,
        existingMainImageUrl: existingMainImageUrl,
      );
}

class DeleteAdminProduct {
  final AdminProductsRepository repository;
  DeleteAdminProduct(this.repository);
  Future<Either<Failure, void>> call(String id) =>
      repository.deleteProduct(id);
}

class AdjustProductStock {
  final AdminProductsRepository repository;
  AdjustProductStock(this.repository);
  Future<Either<Failure, void>> call({
    required String id,
    required int newQuantity,
  }) =>
      repository.adjustStock(id: id, newQuantity: newQuantity);
}
