// lib/features/orders/domain/usecases/orders_usecases.dart
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/admin_order_entity.dart';
import '../entities/order_sub_entities.dart';
import '../repositories/admin_orders_repository.dart';

class GetAdminOrders {
  final AdminOrdersRepository repository;
  GetAdminOrders(this.repository);
  Future<Either<Failure, List<AdminOrderEntity>>> call({
    String? statusFilter,
  }) =>
      repository.getOrders(statusFilter: statusFilter);
}

class GetAdminOrderDetails {
  final AdminOrdersRepository repository;
  GetAdminOrderDetails(this.repository);
  Future<Either<Failure, AdminOrderEntity>> call(String orderId) =>
      repository.getOrderDetails(orderId);
}

class GetAdminOrderItems {
  final AdminOrdersRepository repository;
  GetAdminOrderItems(this.repository);
  Future<Either<Failure, List<OrderItemEntity>>> call(String orderId) =>
      repository.getOrderItems(orderId);
}

class GetAdminOrderHistory {
  final AdminOrdersRepository repository;
  GetAdminOrderHistory(this.repository);
  Future<Either<Failure, List<OrderStatusHistoryEntity>>> call(
    String orderId,
  ) =>
      repository.getOrderHistory(orderId);
}

class UpdateOrderStatus {
  final AdminOrdersRepository repository;
  UpdateOrderStatus(this.repository);
  Future<Either<Failure, void>> call({
    required String orderId,
    required String newStatus,
  }) =>
      repository.updateOrderStatus(orderId: orderId, newStatus: newStatus);
}
