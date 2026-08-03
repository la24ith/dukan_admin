// lib/features/products/domain/entities/admin_product_entity.dart
import 'package:equatable/equatable.dart';

class AdminProductEntity extends Equatable {
  final String id;
  final String categoryId;
  final String categoryName;
  final String name;
  final String? description;
  final int price;
  final int stockQuantity;
  final String? mainImageUrl;
  final bool isActive;
  final DateTime createdAt;

  const AdminProductEntity({
    required this.id,
    required this.categoryId,
    required this.categoryName,
    required this.name,
    this.description,
    required this.price,
    required this.stockQuantity,
    this.mainImageUrl,
    this.isActive = true,
    required this.createdAt,
  });

  bool get isAvailable => stockQuantity > 0 && isActive;
  bool get isLowStock => stockQuantity > 0 && stockQuantity <= 5;

  @override
  List<Object?> get props => [
    id, categoryId, categoryName, name, description,
    price, stockQuantity, mainImageUrl, isActive, createdAt,
  ];
}
