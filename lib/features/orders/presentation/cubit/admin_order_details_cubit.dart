// lib/features/orders/presentation/cubit/admin_order_details_cubit.dart
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/admin_order_entity.dart';
import '../../domain/entities/order_sub_entities.dart';
import '../../domain/usecases/orders_usecases.dart';

enum AdminOrderDetailsStatus { loading, ready, error }
enum StatusUpdateStatus { idle, updating, success, error }

class AdminOrderDetailsState extends Equatable {
  final AdminOrderDetailsStatus status;
  final AdminOrderEntity? order;
  final List<OrderItemEntity> items;
  final List<OrderStatusHistoryEntity> history;
  final String? errorMessage;
  final StatusUpdateStatus updateStatus;
  final String? updateError;

  const AdminOrderDetailsState({
    this.status = AdminOrderDetailsStatus.loading,
    this.order,
    this.items = const [],
    this.history = const [],
    this.errorMessage,
    this.updateStatus = StatusUpdateStatus.idle,
    this.updateError,
  });

  AdminOrderDetailsState copyWith({
    AdminOrderDetailsStatus? status,
    AdminOrderEntity? order,
    List<OrderItemEntity>? items,
    List<OrderStatusHistoryEntity>? history,
    String? errorMessage,
    StatusUpdateStatus? updateStatus,
    String? updateError,
  }) {
    return AdminOrderDetailsState(
      status: status ?? this.status,
      order: order ?? this.order,
      items: items ?? this.items,
      history: history ?? this.history,
      errorMessage: errorMessage,
      updateStatus: updateStatus ?? this.updateStatus,
      updateError: updateError,
    );
  }

  @override
  List<Object?> get props => [
    status, order, items, history, errorMessage, updateStatus, updateError,
  ];
}

class AdminOrderDetailsCubit extends Cubit<AdminOrderDetailsState> {
  final GetAdminOrderDetails getOrderDetailsUseCase;
  final GetAdminOrderItems getOrderItemsUseCase;
  final GetAdminOrderHistory getOrderHistoryUseCase;
  final UpdateOrderStatus updateOrderStatusUseCase;

  AdminOrderDetailsCubit({
    required this.getOrderDetailsUseCase,
    required this.getOrderItemsUseCase,
    required this.getOrderHistoryUseCase,
    required this.updateOrderStatusUseCase,
  }) : super(const AdminOrderDetailsState());

  Future<void> load(String orderId) async {
    emit(state.copyWith(status: AdminOrderDetailsStatus.loading));

    final results = await Future.wait([
      getOrderDetailsUseCase(orderId),
      getOrderItemsUseCase(orderId),
      getOrderHistoryUseCase(orderId),
    ]);

    final orderResult = results[0] as dynamic;
    final itemsResult = results[1] as dynamic;
    final historyResult = results[2] as dynamic;

    String? error;
    orderResult.fold((f) => error = f.message, (_) {});
    if (error != null) {
      emit(
        state.copyWith(
          status: AdminOrderDetailsStatus.error,
          errorMessage: error,
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        status: AdminOrderDetailsStatus.ready,
        order: orderResult.getOrElse(() => null),
        items: itemsResult.getOrElse(() => []),
        history: historyResult.getOrElse(() => []),
      ),
    );
  }

  Future<void> updateStatus({
    required String orderId,
    required String newStatus,
  }) async {
    emit(
      state.copyWith(
        updateStatus: StatusUpdateStatus.updating,
        updateError: null,
      ),
    );

    final result = await updateOrderStatusUseCase(
      orderId: orderId,
      newStatus: newStatus,
    );

    result.fold(
      (failure) => emit(
        state.copyWith(
          updateStatus: StatusUpdateStatus.error,
          updateError: failure.message,
        ),
      ),
      (_) {
        emit(state.copyWith(updateStatus: StatusUpdateStatus.success));
        // أعد تحميل التفاصيل بعد التحديث الناجح
        load(orderId);
      },
    );
  }

  void resetUpdateStatus() {
    emit(
      state.copyWith(
        updateStatus: StatusUpdateStatus.idle,
        updateError: null,
      ),
    );
  }
}
