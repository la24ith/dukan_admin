// lib/features/coupons/presentation/cubit/coupons_cubit.dart
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/coupon_entity.dart';
import '../../domain/usecases/coupons_usecases.dart';
import '../../data/models/coupon_model.dart';

enum CouponsStatus { loading, ready, error }

enum CouponMutationStatus { idle, saving, deleting, success, error }

class CouponsState extends Equatable {
  final CouponsStatus status;
  final List<CouponEntity> coupons;
  final String? errorMessage;
  final CouponMutationStatus mutationStatus;
  final String? mutationError;

  const CouponsState({
    this.status = CouponsStatus.loading,
    this.coupons = const [],
    this.errorMessage,
    this.mutationStatus = CouponMutationStatus.idle,
    this.mutationError,
  });

  CouponsState copyWith({
    CouponsStatus? status,
    List<CouponEntity>? coupons,
    String? errorMessage,
    CouponMutationStatus? mutationStatus,
    String? mutationError,
  }) => CouponsState(
    status: status ?? this.status,
    coupons: coupons ?? this.coupons,
    errorMessage: errorMessage,
    mutationStatus: mutationStatus ?? this.mutationStatus,
    mutationError: mutationError,
  );

  @override
  List<Object?> get props => [
    status,
    coupons,
    errorMessage,
    mutationStatus,
    mutationError,
  ];
}

class CouponsCubit extends Cubit<CouponsState> {
  final GetCoupons getCouponsUseCase;
  final AddCoupon addCouponUseCase;
  final UpdateCoupon updateCouponUseCase;
  final DeleteCoupon deleteCouponUseCase;

  CouponsCubit({
    required this.getCouponsUseCase,
    required this.addCouponUseCase,
    required this.updateCouponUseCase,
    required this.deleteCouponUseCase,
  }) : super(const CouponsState());

  Future<void> load() async {
    emit(state.copyWith(status: CouponsStatus.loading));
    final result = await getCouponsUseCase();
    result.fold(
      (f) => emit(
        state.copyWith(status: CouponsStatus.error, errorMessage: f.message),
      ),
      (coupons) =>
          emit(state.copyWith(status: CouponsStatus.ready, coupons: coupons)),
    );
  }

  Future<void> add(CouponModel coupon) async {
    emit(state.copyWith(mutationStatus: CouponMutationStatus.saving));
    final result = await addCouponUseCase(coupon);
    result.fold(
      (f) => emit(
        state.copyWith(
          mutationStatus: CouponMutationStatus.error,
          mutationError: f.message,
        ),
      ),
      (newCoupon) => emit(
        state.copyWith(
          mutationStatus: CouponMutationStatus.success,
          coupons: [newCoupon, ...state.coupons],
        ),
      ),
    );
  }

  Future<void> update(CouponModel coupon) async {
    emit(state.copyWith(mutationStatus: CouponMutationStatus.saving));
    final result = await updateCouponUseCase(coupon);
    result.fold(
      (f) => emit(
        state.copyWith(
          mutationStatus: CouponMutationStatus.error,
          mutationError: f.message,
        ),
      ),
      (updated) {
        final newList = state.coupons
            .map((c) => c.id == updated.id ? updated : c)
            .toList();
        emit(
          state.copyWith(
            mutationStatus: CouponMutationStatus.success,
            coupons: newList,
          ),
        );
      },
    );
  }

  Future<void> delete(String id) async {
    emit(state.copyWith(mutationStatus: CouponMutationStatus.deleting));
    final result = await deleteCouponUseCase(id);
    result.fold(
      (f) => emit(
        state.copyWith(
          mutationStatus: CouponMutationStatus.error,
          mutationError: f.message,
        ),
      ),
      (_) => emit(
        state.copyWith(
          mutationStatus: CouponMutationStatus.success,
          coupons: state.coupons.where((c) => c.id != id).toList(),
        ),
      ),
    );
  }

  void resetMutation() => emit(
    state.copyWith(
      mutationStatus: CouponMutationStatus.idle,
      mutationError: null,
    ),
  );
}
