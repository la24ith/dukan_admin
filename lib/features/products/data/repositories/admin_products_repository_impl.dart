// lib/features/products/data/repositories/admin_products_repository_impl.dart
import 'dart:io';
import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/admin_product_entity.dart';
import '../../domain/repositories/admin_products_repository.dart';
import '../datasources/admin_products_remote_data_source.dart';

class AdminProductsRepositoryImpl implements AdminProductsRepository {
  final AdminProductsRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  AdminProductsRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<AdminProductEntity>>> getProducts({
    String? categoryId,
    bool? isActive,
  }) async {
    if (!await networkInfo.isConnected) return const Left(NetworkFailure());
    try {
      return Right(await remoteDataSource.getProducts(
          categoryId: categoryId, isActive: isActive));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, AdminProductEntity>> addProduct({
    required String categoryId,
    required String name,
    String? description,
    required int price,
    required int stockQuantity,
    File? mainImage,
  }) async {
    if (!await networkInfo.isConnected) return const Left(NetworkFailure());
    try {
      return Right(await remoteDataSource.addProduct(
        categoryId: categoryId,
        name: name,
        description: description,
        price: price,
        stockQuantity: stockQuantity,
        mainImage: mainImage,
      ));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, AdminProductEntity>> updateProduct({
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
    if (!await networkInfo.isConnected) return const Left(NetworkFailure());
    try {
      return Right(await remoteDataSource.updateProduct(
        id: id,
        categoryId: categoryId,
        name: name,
        description: description,
        price: price,
        stockQuantity: stockQuantity,
        isActive: isActive,
        newMainImage: newMainImage,
        existingMainImageUrl: existingMainImageUrl,
      ));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> deleteProduct(String id) async {
    if (!await networkInfo.isConnected) return const Left(NetworkFailure());
    try {
      await remoteDataSource.deleteProduct(id);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> adjustStock({
    required String id,
    required int newQuantity,
  }) async {
    if (!await networkInfo.isConnected) return const Left(NetworkFailure());
    try {
      await remoteDataSource.adjustStock(id: id, newQuantity: newQuantity);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }
}

// ─── Usecases ─────────────────────────────────────────────────────────────
