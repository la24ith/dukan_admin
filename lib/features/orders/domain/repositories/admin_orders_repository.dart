// lib/features/orders/domain/repositories/admin_orders_repository.dart
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/admin_order_entity.dart';
import '../entities/order_sub_entities.dart';

abstract class AdminOrdersRepository {
  /// جلب كل الطلبات مع فلتر اختياري للحالة
  Future<Either<Failure, List<AdminOrderEntity>>> getOrders({
    String? statusFilter,
  });

  Future<Either<Failure, AdminOrderEntity>> getOrderDetails(String orderId);

  Future<Either<Failure, List<OrderItemEntity>>> getOrderItems(String orderId);

  Future<Either<Failure, List<OrderStatusHistoryEntity>>> getOrderHistory(
    String orderId,
  );

  /// تغيير حالة الطلب عبر update_order_status RPC (للأدمن فقط)
  Future<Either<Failure, void>> updateOrderStatus({
    required String orderId,
    required String newStatus,
  });
}
