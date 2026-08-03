// lib/features/auth/presentation/cubit/auth_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/auth_usecases.dart';
import '../../domain/usecases/sign_in.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final SignIn signInUseCase;
  final GetCurrentAdmin getCurrentAdminUseCase;
  final SignOut signOutUseCase;

  AuthCubit({
    required this.signInUseCase,
    required this.getCurrentAdminUseCase,
    required this.signOutUseCase,
  }) : super(const AuthState());

  Future<void> checkAuthStatus() async {
    emit(state.copyWith(status: AuthStatus.loading));
    final result = await getCurrentAdminUseCase();
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: AuthStatus.unauthenticated,
          errorMessage: failure.message,
        ),
      ),
      (admin) => emit(
        admin != null
            ? state.copyWith(status: AuthStatus.authenticated, admin: admin)
            : state.copyWith(status: AuthStatus.unauthenticated),
      ),
    );
  }

  Future<void> signIn({
    required String phone,
    required String password,
  }) async {
    emit(state.copyWith(status: AuthStatus.loading));
    final result = await signInUseCase(
      SignInParams(phone: phone, password: password),
    );
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: AuthStatus.error,
          errorMessage: failure.message,
        ),
      ),
      (admin) => emit(
        state.copyWith(status: AuthStatus.authenticated, admin: admin),
      ),
    );
  }

  Future<void> signOut() async {
    await signOutUseCase();
    emit(const AuthState(status: AuthStatus.unauthenticated));
  }
}
