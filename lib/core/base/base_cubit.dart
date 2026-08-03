// lib/core/base/base_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import '../error/failures.dart';
import 'base_state.dart';

abstract class BaseCubit<T> extends Cubit<BaseState<T>> {
  BaseCubit() : super(BaseState<T>());

  void emitLoading() => emit(state.copyWith(status: BaseStatus.loading));

  void emitSuccess(T data) =>
      emit(state.copyWith(status: BaseStatus.success, data: data));

  void emitFailure(Failure failure) =>
      emit(state.copyWith(status: BaseStatus.failure, failure: failure));
}
