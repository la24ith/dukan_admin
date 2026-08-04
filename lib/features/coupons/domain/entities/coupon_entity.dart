// lib/features/coupons/domain/entities/coupon_entity.dart
import 'package:equatable/equatable.dart';

enum CouponDiscountType { percentage, fixed }

extension CouponDiscountTypeLabel on CouponDiscountType {
  String get label =>
      this == CouponDiscountType.percentage ? 'نسبة مئوية %' : 'مبلغ ثابت ل.س';
}

class CouponEntity extends Equatable {
  final String id;
  final String code;
  final CouponDiscountType discountType;
  final int discountValue;
  final int minOrderAmount;
  final int? maxUses;
  final bool isActive;
  final DateTime? expiresAt;
  final DateTime createdAt;
  final int usageCount;

  const CouponEntity({
    required this.id,
    required this.code,
    required this.discountType,
    required this.discountValue,
    required this.minOrderAmount,
    this.maxUses,
    required this.isActive,
    this.expiresAt,
    required this.createdAt,
    this.usageCount = 0,
  });

  bool get isExpired =>
      expiresAt != null && expiresAt!.isBefore(DateTime.now());

  bool get isMaxedOut => maxUses != null && usageCount >= maxUses!;

  bool get isEffectivelyActive => isActive && !isExpired && !isMaxedOut;

  String get discountLabel => discountType == CouponDiscountType.percentage
      ? '$discountValue%'
      : '$discountValue ل.س';

  @override
  List<Object?> get props => [
    id,
    code,
    discountType,
    discountValue,
    minOrderAmount,
    maxUses,
    isActive,
    expiresAt,
    createdAt,
    usageCount,
  ];
}
