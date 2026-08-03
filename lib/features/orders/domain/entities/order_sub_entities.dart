// lib/features/orders/domain/entities/order_item_entity.dart
import 'package:equatable/equatable.dart';

class OrderItemEntity extends Equatable {
  final String id;
  final String productNameSnapshot;
  final int productPriceSnapshot;
  final int quantity;
  final int subtotal;

  const OrderItemEntity({
    required this.id,
    required this.productNameSnapshot,
    required this.productPriceSnapshot,
    required this.quantity,
    required this.subtotal,
  });

  @override
  List<Object?> get props => [
    id, productNameSnapshot, productPriceSnapshot, quantity, subtotal,
  ];
}

// lib/features/orders/domain/entities/order_status_history_entity.dart
class OrderStatusHistoryEntity extends Equatable {
  final String status;
  final String changedBy;
  final DateTime changedAt;

  const OrderStatusHistoryEntity({
    required this.status,
    required this.changedBy,
    required this.changedAt,
  });

  @override
  List<Object?> get props => [status, changedBy, changedAt];
}
