// lib/features/auth/domain/usecases/get_current_admin.dart
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/admin_entity.dart';
import '../repositories/auth_repository.dart';

class GetCurrentAdmin {
  final AuthRepository repository;
  GetCurrentAdmin(this.repository);

  Future<Either<Failure, AdminEntity?>> call() =>
      repository.getCurrentAdmin();
}

// lib/features/auth/domain/usecases/sign_out.dart
class SignOut {
  final AuthRepository repository;
  SignOut(this.repository);

  Future<Either<Failure, void>> call() => repository.signOut();
}
