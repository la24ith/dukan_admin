// lib/core/base/base_state.dart
import 'package:equatable/equatable.dart';
import '../error/failures.dart';

enum BaseStatus { initial, loading, success, failure }

class BaseState<T> extends Equatable {
  final BaseStatus status;
  final T? data;
  final Failure? failure;

  const BaseState({
    this.status = BaseStatus.initial,
    this.data,
    this.failure,
  });

  bool get isInitial => status == BaseStatus.initial;
  bool get isLoading => status == BaseStatus.loading;
  bool get isSuccess => status == BaseStatus.success;
  bool get isFailure => status == BaseStatus.failure;

  BaseState<T> copyWith({
    BaseStatus? status,
    T? data,
    Failure? failure,
  }) {
    return BaseState<T>(
      status: status ?? this.status,
      data: data ?? this.data,
      failure: failure,
    );
  }

  @override
  List<Object?> get props => [status, data, failure];
}
