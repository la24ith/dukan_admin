// lib/features/orders/domain/entities/admin_order_entity.dart
import 'package:equatable/equatable.dart';

class AdminOrderEntity extends Equatable {
  final String id;
  final String status;
  final int subtotal;
  final int deliveryFee;
  final int discountAmount;
  final int total;
  final DateTime createdAt;
  final int itemsCount;
  // بيانات الزبون — join مع profiles
  final String customerName;
  final String customerPhone;
  // بيانات العنوان — join مع addresses
  final String governorate;
  final String area;
  final String? addressDetails;

  const AdminOrderEntity({
    required this.id,
    required this.status,
    required this.subtotal,
    required this.deliveryFee,
    required this.discountAmount,
    required this.total,
    required this.createdAt,
    this.itemsCount = 0,
    required this.customerName,
    required this.customerPhone,
    required this.governorate,
    required this.area,
    this.addressDetails,
  });

  String get shortId => id.substring(0, 8).toUpperCase();

  String get fullAddress => addressDetails != null && addressDetails!.isNotEmpty
      ? '$governorate، $area، $addressDetails'
      : '$governorate، $area';

  /// الحالات التي يمكن للأدمن الانتقال إليها من الحالة الحالية
  List<String> get availableNextStatuses {
    switch (status) {
      case 'pending':
        return ['confirmed', 'cancelled'];
      case 'confirmed':
        return ['preparing', 'cancelled'];
      case 'preparing':
        return ['shipping', 'cancelled'];
      case 'shipping':
        return ['delivered', 'cancelled'];
      case 'delivered':
      case 'cancelled':
        return [];
      default:
        return [];
    }
  }

  bool get canChangeStatus => availableNextStatuses.isNotEmpty;

  @override
  List<Object?> get props => [
    id, status, subtotal, deliveryFee, discountAmount, total,
    createdAt, itemsCount, customerName, customerPhone,
    governorate, area, addressDetails,
  ];
}
