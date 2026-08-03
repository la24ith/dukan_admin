// lib/features/orders/presentation/cubit/admin_orders_cubit.dart
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/admin_order_entity.dart';
import '../../domain/usecases/orders_usecases.dart';

// ─── State ────────────────────────────────────────────────────────────────
enum AdminOrdersStatus { loading, ready, error }

class AdminOrdersState extends Equatable {
  final AdminOrdersStatus status;
  final List<AdminOrderEntity> orders;
  final String selectedFilter; // 'all' | حالة معينة
  final String? errorMessage;

  const AdminOrdersState({
    this.status = AdminOrdersStatus.loading,
    this.orders = const [],
    this.selectedFilter = 'all',
    this.errorMessage,
  });

  List<AdminOrderEntity> get filteredOrders => selectedFilter == 'all'
      ? orders
      : orders.where((o) => o.status == selectedFilter).toList();

  AdminOrdersState copyWith({
    AdminOrdersStatus? status,
    List<AdminOrderEntity>? orders,
    String? selectedFilter,
    String? errorMessage,
  }) {
    return AdminOrdersState(
      status: status ?? this.status,
      orders: orders ?? this.orders,
      selectedFilter: selectedFilter ?? this.selectedFilter,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, orders, selectedFilter, errorMessage];
}

// ─── Cubit ────────────────────────────────────────────────────────────────
class AdminOrdersCubit extends Cubit<AdminOrdersState> {
  final GetAdminOrders getAdminOrdersUseCase;

  AdminOrdersCubit({required this.getAdminOrdersUseCase})
      : super(const AdminOrdersState());

  Future<void> load({String? statusFilter}) async {
    emit(state.copyWith(status: AdminOrdersStatus.loading));
    final result = await getAdminOrdersUseCase(statusFilter: statusFilter);
    result.fold(
      (f) => emit(
        state.copyWith(
          status: AdminOrdersStatus.error,
          errorMessage: f.message,
        ),
      ),
      (orders) => emit(
        state.copyWith(status: AdminOrdersStatus.ready, orders: orders),
      ),
    );
  }

  void setFilter(String filter) {
    emit(state.copyWith(selectedFilter: filter));
    // نعيد التحميل من السيرفر مع الفلتر الجديد
    load(statusFilter: filter == 'all' ? null : filter);
  }
}
