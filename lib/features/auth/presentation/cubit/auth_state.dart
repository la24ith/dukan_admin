// lib/features/auth/presentation/cubit/auth_state.dart
import 'package:equatable/equatable.dart';
import '../../domain/entities/admin_entity.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthState extends Equatable {
  final AuthStatus status;
  final AdminEntity? admin;
  final String? errorMessage;

  const AuthState({
    this.status = AuthStatus.initial,
    this.admin,
    this.errorMessage,
  });

  AuthState copyWith({
    AuthStatus? status,
    AdminEntity? admin,
    String? errorMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      admin: admin ?? this.admin,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, admin, errorMessage];
}
