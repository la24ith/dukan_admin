// lib/features/orders/data/models/admin_order_model.dart
import '../../domain/entities/admin_order_entity.dart';
import '../../domain/entities/order_sub_entities.dart';

class AdminOrderModel extends AdminOrderEntity {
  const AdminOrderModel({
    required super.id,
    required super.status,
    required super.subtotal,
    required super.deliveryFee,
    required super.discountAmount,
    required super.total,
    required super.createdAt,
    super.itemsCount,
    required super.customerName,
    required super.customerPhone,
    required super.governorate,
    required super.area,
    super.addressDetails,
  });

  factory AdminOrderModel.fromJson(Map<String, dynamic> json) {
    // join: orders + profiles (as customer) + addresses
    final profile = json['profiles'] as Map<String, dynamic>? ?? {};
    final address = json['addresses'] as Map<String, dynamic>? ?? {};

    int count = 0;
    final embedded = json['order_items'];
    if (embedded is List && embedded.isNotEmpty && embedded.first['count'] != null) {
      count = (embedded.first['count'] as num).toInt();
    }

    return AdminOrderModel(
      id: json['id'] as String,
      status: json['status'] as String,
      subtotal: (json['subtotal'] as num).toInt(),
      deliveryFee: (json['delivery_fee'] as num).toInt(),
      discountAmount: (json['discount_amount'] as num).toInt(),
      total: (json['total'] as num).toInt(),
      createdAt: DateTime.parse(json['created_at'] as String),
      itemsCount: count,
      customerName: profile['full_name'] as String? ?? 'مستخدم',
      customerPhone: profile['phone'] as String? ?? '',
      governorate: address['governorate'] as String? ?? '',
      area: address['area'] as String? ?? '',
      addressDetails: address['details'] as String?,
    );
  }
}

class OrderItemModel extends OrderItemEntity {
  const OrderItemModel({
    required super.id,
    required super.productNameSnapshot,
    required super.productPriceSnapshot,
    required super.quantity,
    required super.subtotal,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      id: json['id'] as String,
      productNameSnapshot: json['product_name_snapshot'] as String,
      productPriceSnapshot: (json['product_price_snapshot'] as num).toInt(),
      quantity: json['quantity'] as int,
      subtotal: (json['subtotal'] as num).toInt(),
    );
  }
}

class OrderStatusHistoryModel extends OrderStatusHistoryEntity {
  const OrderStatusHistoryModel({
    required super.status,
    required super.changedBy,
    required super.changedAt,
  });

  factory OrderStatusHistoryModel.fromJson(Map<String, dynamic> json) {
    return OrderStatusHistoryModel(
      status: json['status'] as String,
      changedBy: json['changed_by'] as String? ?? 'system',
      changedAt: DateTime.parse(json['changed_at'] as String),
    );
  }
}
