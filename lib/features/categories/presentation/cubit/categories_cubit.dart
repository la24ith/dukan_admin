// lib/features/categories/presentation/cubit/categories_cubit.dart
import 'dart:io';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/category_entity.dart';
import '../../domain/usecases/categories_usecases.dart';

enum CategoriesStatus { loading, ready, error }
enum CategoryMutationStatus { idle, saving, deleting, success, error }

class CategoriesState extends Equatable {
  final CategoriesStatus status;
  final List<CategoryEntity> categories;
  final String? errorMessage;
  final CategoryMutationStatus mutationStatus;
  final String? mutationError;

  const CategoriesState({
    this.status = CategoriesStatus.loading,
    this.categories = const [],
    this.errorMessage,
    this.mutationStatus = CategoryMutationStatus.idle,
    this.mutationError,
  });

  CategoriesState copyWith({
    CategoriesStatus? status,
    List<CategoryEntity>? categories,
    String? errorMessage,
    CategoryMutationStatus? mutationStatus,
    String? mutationError,
  }) =>
      CategoriesState(
        status: status ?? this.status,
        categories: categories ?? this.categories,
        errorMessage: errorMessage,
        mutationStatus: mutationStatus ?? this.mutationStatus,
        mutationError: mutationError,
      );

  @override
  List<Object?> get props =>
      [status, categories, errorMessage, mutationStatus, mutationError];
}

class CategoriesCubit extends Cubit<CategoriesState> {
  final GetCategories getCategoriesUseCase;
  final AddCategory addCategoryUseCase;
  final UpdateCategory updateCategoryUseCase;
  final DeleteCategory deleteCategoryUseCase;

  CategoriesCubit({
    required this.getCategoriesUseCase,
    required this.addCategoryUseCase,
    required this.updateCategoryUseCase,
    required this.deleteCategoryUseCase,
  }) : super(const CategoriesState());

  Future<void> load() async {
    emit(state.copyWith(status: CategoriesStatus.loading));
    final result = await getCategoriesUseCase();
    result.fold(
      (f) => emit(state.copyWith(
          status: CategoriesStatus.error, errorMessage: f.message)),
      (cats) => emit(
          state.copyWith(status: CategoriesStatus.ready, categories: cats)),
    );
  }

  Future<void> add({
    required String name,
    int sortOrder = 0,
    File? image,
  }) async {
    emit(state.copyWith(mutationStatus: CategoryMutationStatus.saving));
    final result = await addCategoryUseCase(
        name: name, sortOrder: sortOrder, image: image);
    result.fold(
      (f) => emit(state.copyWith(
          mutationStatus: CategoryMutationStatus.error,
          mutationError: f.message)),
      (cat) => emit(state.copyWith(
        mutationStatus: CategoryMutationStatus.success,
        categories: [cat, ...state.categories],
      )),
    );
  }

  Future<void> update({
    required String id,
    required String name,
    int sortOrder = 0,
    bool isActive = true,
    File? newImage,
    String? existingImageUrl,
  }) async {
    emit(state.copyWith(mutationStatus: CategoryMutationStatus.saving));
    final result = await updateCategoryUseCase(
      id: id,
      name: name,
      sortOrder: sortOrder,
      isActive: isActive,
      newImage: newImage,
      existingImageUrl: existingImageUrl,
    );
    result.fold(
      (f) => emit(state.copyWith(
          mutationStatus: CategoryMutationStatus.error,
          mutationError: f.message)),
      (updated) {
        final newList = state.categories
            .map((c) => c.id == id ? updated : c)
            .toList();
        emit(state.copyWith(
            mutationStatus: CategoryMutationStatus.success,
            categories: newList));
      },
    );
  }

  Future<void> delete(String id) async {
    emit(state.copyWith(mutationStatus: CategoryMutationStatus.deleting));
    final result = await deleteCategoryUseCase(id);
    result.fold(
      (f) => emit(state.copyWith(
          mutationStatus: CategoryMutationStatus.error,
          mutationError: f.message)),
      (_) => emit(state.copyWith(
        mutationStatus: CategoryMutationStatus.success,
        categories: state.categories.where((c) => c.id != id).toList(),
      )),
    );
  }

  void resetMutation() => emit(state.copyWith(
      mutationStatus: CategoryMutationStatus.idle, mutationError: null));
}
