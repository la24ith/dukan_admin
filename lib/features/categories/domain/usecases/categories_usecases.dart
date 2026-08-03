// lib/features/categories/domain/usecases/categories_usecases.dart
import 'dart:io';
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/category_entity.dart';
import '../repositories/categories_repository.dart';

class GetCategories {
  final CategoriesRepository repository;
  GetCategories(this.repository);
  Future<Either<Failure, List<CategoryEntity>>> call() =>
      repository.getCategories();
}

class AddCategory {
  final CategoriesRepository repository;
  AddCategory(this.repository);
  Future<Either<Failure, CategoryEntity>> call({
    required String name,
    int sortOrder = 0,
    File? image,
  }) =>
      repository.addCategory(name: name, sortOrder: sortOrder, image: image);
}

class UpdateCategory {
  final CategoriesRepository repository;
  UpdateCategory(this.repository);
  Future<Either<Failure, CategoryEntity>> call({
    required String id,
    required String name,
    int sortOrder = 0,
    bool isActive = true,
    File? newImage,
    String? existingImageUrl,
  }) =>
      repository.updateCategory(
        id: id,
        name: name,
        sortOrder: sortOrder,
        isActive: isActive,
        newImage: newImage,
        existingImageUrl: existingImageUrl,
      );
}

class DeleteCategory {
  final CategoriesRepository repository;
  DeleteCategory(this.repository);
  Future<Either<Failure, void>> call(String id) =>
      repository.deleteCategory(id);
}
