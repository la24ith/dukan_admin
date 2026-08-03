// lib/features/auth/data/models/admin_model.dart
import '../../domain/entities/admin_entity.dart';

class AdminModel extends AdminEntity {
  const AdminModel({
    required super.id,
    required super.phone,
    super.fullName,
    super.role,
  });

  factory AdminModel.fromJson(Map<String, dynamic> json) {
    return AdminModel(
      id: json['id'] as String,
      phone: json['phone'] as String,
      fullName: json['full_name'] as String?,
      role: json['role'] as String? ?? 'customer',
    );
  }
}
