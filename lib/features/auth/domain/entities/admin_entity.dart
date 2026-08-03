// lib/features/auth/domain/entities/admin_entity.dart
import 'package:equatable/equatable.dart';

class AdminEntity extends Equatable {
  final String id;
  final String phone;
  final String? fullName;
  final String role;

  const AdminEntity({
    required this.id,
    required this.phone,
    this.fullName,
    this.role = 'admin',
  });

  bool get isAdmin => role == 'admin';

  @override
  List<Object?> get props => [id, phone, fullName, role];
}
