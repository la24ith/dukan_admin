// lib/features/categories/data/repositories/categories_repository_impl.dart
import 'dart:io';
import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/category_entity.dart';
import '../../domain/repositories/categories_repository.dart';
import '../datasources/categories_remote_data_source.dart';

class CategoriesRepositoryImpl implements CategoriesRepository {
  final CategoriesRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  CategoriesRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<CategoryEntity>>> getCategories() async {
    if (!await networkInfo.isConnected) return const Left(NetworkFailure());
    try {
      return Right(await remoteDataSource.getCategories());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, CategoryEntity>> addCategory({
    required String name,
    int sortOrder = 0,
    File? image,
  }) async {
    if (!await networkInfo.isConnected) return const Left(NetworkFailure());
    try {
      return Right(
        await remoteDataSource.addCategory(
          name: name,
          sortOrder: sortOrder,
          image: image,
        ),
      );
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, CategoryEntity>> updateCategory({
    required String id,
    required String name,
    int sortOrder = 0,
    bool isActive = true,
    File? newImage,
    String? existingImageUrl,
  }) async {
    if (!await networkInfo.isConnected) return const Left(NetworkFailure());
    try {
      return Right(
        await remoteDataSource.updateCategory(
          id: id,
          name: name,
          sortOrder: sortOrder,
          isActive: isActive,
          newImage: newImage,
          existingImageUrl: existingImageUrl,
        ),
      );
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> deleteCategory(String id) async {
    if (!await networkInfo.isConnected) return const Left(NetworkFailure());
    try {
      await remoteDataSource.deleteCategory(id);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }
}
