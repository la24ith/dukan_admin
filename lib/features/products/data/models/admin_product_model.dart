// lib/features/products/data/models/admin_product_model.dart
import '../../domain/entities/admin_product_entity.dart';

class AdminProductModel extends AdminProductEntity {
  const AdminProductModel({
    required super.id,
    required super.categoryId,
    required super.categoryName,
    required super.name,
    super.description,
    required super.price,
    required super.stockQuantity,
    super.mainImageUrl,
    super.isActive,
    required super.createdAt,
  });

  factory AdminProductModel.fromJson(Map<String, dynamic> json) {
    final category = json['categories'] as Map<String, dynamic>? ?? {};
    return AdminProductModel(
      id: json['id'] as String,
      categoryId: json['category_id'] as String,
      categoryName: category['name'] as String? ?? '—',
      name: json['name'] as String,
      description: json['description'] as String?,
      price: (json['price'] as num).toInt(),
      stockQuantity: json['stock_quantity'] as int? ?? 0,
      mainImageUrl: json['main_image_url'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
