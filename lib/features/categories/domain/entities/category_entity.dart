// lib/features/categories/domain/entities/category_entity.dart
import 'package:equatable/equatable.dart';

class CategoryEntity extends Equatable {
  final String id;
  final String name;
  final String? imageUrl;
  final int sortOrder;
  final bool isActive;
  final DateTime createdAt;

  const CategoryEntity({
    required this.id,
    required this.name,
    this.imageUrl,
    this.sortOrder = 0,
    this.isActive = true,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, name, imageUrl, sortOrder, isActive, createdAt];
}
