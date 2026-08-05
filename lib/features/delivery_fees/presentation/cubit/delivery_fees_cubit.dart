// lib/features/delivery_fees/presentation/cubit/delivery_fees_cubit.dart
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/delivery_fee_entity.dart';
import '../../domain/usecases/delivery_fees_usecases.dart';

enum DeliveryFeesStatus { loading, ready, error }

enum DeliveryFeeMutationStatus { idle, saving, deleting, success, error }

class DeliveryFeesState extends Equatable {
  final DeliveryFeesStatus status;
  final List<DeliveryFeeEntity> fees;
  final String? errorMessage;
  final DeliveryFeeMutationStatus mutationStatus;
  final String? mutationError;

  const DeliveryFeesState({
    this.status = DeliveryFeesStatus.loading,
    this.fees = const [],
    this.errorMessage,
    this.mutationStatus = DeliveryFeeMutationStatus.idle,
    this.mutationError,
  });

  DeliveryFeesState copyWith({
    DeliveryFeesStatus? status,
    List<DeliveryFeeEntity>? fees,
    String? errorMessage,
    DeliveryFeeMutationStatus? mutationStatus,
    String? mutationError,
  }) => DeliveryFeesState(
    status: status ?? this.status,
    fees: fees ?? this.fees,
    errorMessage: errorMessage,
    mutationStatus: mutationStatus ?? this.mutationStatus,
    mutationError: mutationError,
  );

  @override
  List<Object?> get props => [
    status,
    fees,
    errorMessage,
    mutationStatus,
    mutationError,
  ];
}

class DeliveryFeesCubit extends Cubit<DeliveryFeesState> {
  final GetDeliveryFees getFeesUseCase;
  final AddDeliveryFee addFeeUseCase;
  final UpdateDeliveryFee updateFeeUseCase;
  final DeleteDeliveryFee deleteFeeUseCase;

  DeliveryFeesCubit({
    required this.getFeesUseCase,
    required this.addFeeUseCase,
    required this.updateFeeUseCase,
    required this.deleteFeeUseCase,
  }) : super(const DeliveryFeesState());

  Future<void> load() async {
    emit(state.copyWith(status: DeliveryFeesStatus.loading));
    final result = await getFeesUseCase();
    result.fold(
      (f) => emit(
        state.copyWith(
          status: DeliveryFeesStatus.error,
          errorMessage: f.message,
        ),
      ),
      (fees) =>
          emit(state.copyWith(status: DeliveryFeesStatus.ready, fees: fees)),
    );
  }

  Future<void> add({required String governorate, required int fee}) async {
    emit(state.copyWith(mutationStatus: DeliveryFeeMutationStatus.saving));
    final result = await addFeeUseCase(governorate: governorate, fee: fee);
    result.fold(
      (f) => emit(
        state.copyWith(
          mutationStatus: DeliveryFeeMutationStatus.error,
          mutationError: f.message,
        ),
      ),
      (newFee) => emit(
        state.copyWith(
          mutationStatus: DeliveryFeeMutationStatus.success,
          fees: [...state.fees, newFee]
            ..sort((a, b) => a.governorate.compareTo(b.governorate)),
        ),
      ),
    );
  }

  Future<void> update({required String id, required int fee}) async {
    emit(state.copyWith(mutationStatus: DeliveryFeeMutationStatus.saving));
    final result = await updateFeeUseCase(id: id, fee: fee);
    result.fold(
      (f) => emit(
        state.copyWith(
          mutationStatus: DeliveryFeeMutationStatus.error,
          mutationError: f.message,
        ),
      ),
      (updated) {
        final newList = state.fees
            .map((f) => f.id == id ? updated : f)
            .toList();
        emit(
          state.copyWith(
            mutationStatus: DeliveryFeeMutationStatus.success,
            fees: newList,
          ),
        );
      },
    );
  }

  Future<void> delete(String id) async {
    emit(state.copyWith(mutationStatus: DeliveryFeeMutationStatus.deleting));
    final result = await deleteFeeUseCase(id);
    result.fold(
      (f) => emit(
        state.copyWith(
          mutationStatus: DeliveryFeeMutationStatus.error,
          mutationError: f.message,
        ),
      ),
      (_) => emit(
        state.copyWith(
          mutationStatus: DeliveryFeeMutationStatus.success,
          fees: state.fees.where((f) => f.id != id).toList(),
        ),
      ),
    );
  }

  void resetMutation() => emit(
    state.copyWith(
      mutationStatus: DeliveryFeeMutationStatus.idle,
      mutationError: null,
    ),
  );
}
