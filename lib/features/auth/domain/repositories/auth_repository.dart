// lib/features/auth/domain/repositories/auth_repository.dart
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/admin_entity.dart';

abstract class AuthRepository {
  Future<Either<Failure, AdminEntity>> signIn({
    required String phone,
    required String password,
  });

  Future<Either<Failure, AdminEntity?>> getCurrentAdmin();

  Future<Either<Failure, void>> signOut();
}
