// lib/features/products/presentation/cubit/admin_products_cubit.dart
import 'dart:io';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/admin_product_entity.dart';
import '../../domain/usecases/products_usecases.dart';

enum AdminProductsStatus { loading, ready, error }
enum ProductMutationStatus { idle, saving, deleting, success, error }

class AdminProductsState extends Equatable {
  final AdminProductsStatus status;
  final List<AdminProductEntity> products;
  final String selectedCategoryFilter; // 'all' أو categoryId
  final String? errorMessage;
  final ProductMutationStatus mutationStatus;
  final String? mutationError;

  const AdminProductsState({
    this.status = AdminProductsStatus.loading,
    this.products = const [],
    this.selectedCategoryFilter = 'all',
    this.errorMessage,
    this.mutationStatus = ProductMutationStatus.idle,
    this.mutationError,
  });

  AdminProductsState copyWith({
    AdminProductsStatus? status,
    List<AdminProductEntity>? products,
    String? selectedCategoryFilter,
    String? errorMessage,
    ProductMutationStatus? mutationStatus,
    String? mutationError,
  }) =>
      AdminProductsState(
        status: status ?? this.status,
        products: products ?? this.products,
        selectedCategoryFilter:
            selectedCategoryFilter ?? this.selectedCategoryFilter,
        errorMessage: errorMessage,
        mutationStatus: mutationStatus ?? this.mutationStatus,
        mutationError: mutationError,
      );

  @override
  List<Object?> get props => [
        status, products, selectedCategoryFilter,
        errorMessage, mutationStatus, mutationError,
      ];
}

class AdminProductsCubit extends Cubit<AdminProductsState> {
  final GetAdminProducts getProductsUseCase;
  final AddAdminProduct addProductUseCase;
  final UpdateAdminProduct updateProductUseCase;
  final DeleteAdminProduct deleteProductUseCase;
  final AdjustProductStock adjustStockUseCase;

  AdminProductsCubit({
    required this.getProductsUseCase,
    required this.addProductUseCase,
    required this.updateProductUseCase,
    required this.deleteProductUseCase,
    required this.adjustStockUseCase,
  }) : super(const AdminProductsState());

  Future<void> load({String? categoryId}) async {
    emit(state.copyWith(status: AdminProductsStatus.loading));
    final result = await getProductsUseCase(
      categoryId: categoryId == 'all' ? null : categoryId,
    );
    result.fold(
      (f) => emit(state.copyWith(
          status: AdminProductsStatus.error, errorMessage: f.message)),
      (products) => emit(
          state.copyWith(status: AdminProductsStatus.ready, products: products)),
    );
  }

  void setCategoryFilter(String categoryId) {
    emit(state.copyWith(selectedCategoryFilter: categoryId));
    load(categoryId: categoryId);
  }

  Future<void> add({
    required String categoryId,
    required String name,
    String? description,
    required int price,
    required int stockQuantity,
    File? mainImage,
  }) async {
    emit(state.copyWith(mutationStatus: ProductMutationStatus.saving));
    final result = await addProductUseCase(
      categoryId: categoryId,
      name: name,
      description: description,
      price: price,
      stockQuantity: stockQuantity,
      mainImage: mainImage,
    );
    result.fold(
      (f) => emit(state.copyWith(
          mutationStatus: ProductMutationStatus.error, mutationError: f.message)),
      (product) => emit(state.copyWith(
        mutationStatus: ProductMutationStatus.success,
        products: [product, ...state.products],
      )),
    );
  }

  Future<void> update({
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
    emit(state.copyWith(mutationStatus: ProductMutationStatus.saving));
    final result = await updateProductUseCase(
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
    result.fold(
      (f) => emit(state.copyWith(
          mutationStatus: ProductMutationStatus.error, mutationError: f.message)),
      (updated) {
        final newList =
            state.products.map((p) => p.id == id ? updated : p).toList();
        emit(state.copyWith(
            mutationStatus: ProductMutationStatus.success, products: newList));
      },
    );
  }

  Future<void> delete(String id) async {
    emit(state.copyWith(mutationStatus: ProductMutationStatus.deleting));
    final result = await deleteProductUseCase(id);
    result.fold(
      (f) => emit(state.copyWith(
          mutationStatus: ProductMutationStatus.error, mutationError: f.message)),
      (_) => emit(state.copyWith(
        mutationStatus: ProductMutationStatus.success,
        products: state.products.where((p) => p.id != id).toList(),
      )),
    );
  }

  Future<void> adjustStock({
    required String productId,
    required int newQuantity,
  }) async {
    final result =
        await adjustStockUseCase(id: productId, newQuantity: newQuantity);
    result.fold(
      (f) => emit(state.copyWith(
          mutationStatus: ProductMutationStatus.error, mutationError: f.message)),
      (_) {
        final newList = state.products.map((p) {
          if (p.id != productId) return p;
          return AdminProductEntity(
            id: p.id,
            categoryId: p.categoryId,
            categoryName: p.categoryName,
            name: p.name,
            description: p.description,
            price: p.price,
            stockQuantity: newQuantity,
            mainImageUrl: p.mainImageUrl,
            isActive: p.isActive,
            createdAt: p.createdAt,
          );
        }).toList();
        emit(state.copyWith(
            mutationStatus: ProductMutationStatus.success, products: newList));
      },
    );
  }

  void resetMutation() => emit(state.copyWith(
      mutationStatus: ProductMutationStatus.idle, mutationError: null));
}
