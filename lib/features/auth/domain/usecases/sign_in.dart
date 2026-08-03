// lib/features/auth/domain/usecases/sign_in.dart
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/admin_entity.dart';
import '../repositories/auth_repository.dart';

class SignInParams {
  final String phone;
  final String password;
  const SignInParams({required this.phone, required this.password});
}

class SignIn {
  final AuthRepository repository;
  SignIn(this.repository);

  Future<Either<Failure, AdminEntity>> call(SignInParams params) {
    return repository.signIn(phone: params.phone, password: params.password);
  }
}
