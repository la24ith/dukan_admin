// lib/features/coupons/data/models/coupon_model.dart
import '../../domain/entities/coupon_entity.dart';

class CouponModel extends CouponEntity {
  const CouponModel({
    required super.id,
    required super.code,
    required super.discountType,
    required super.discountValue,
    required super.minOrderAmount,
    super.maxUses,
    required super.isActive,
    super.expiresAt,
    required super.createdAt,
    super.usageCount,
  });

  factory CouponModel.fromJson(Map<String, dynamic> json) {
    // usageCount من count على coupon_usages (join)
    int usageCount = 0;
    final usages = json['coupon_usages'];
    if (usages is List && usages.isNotEmpty) {
      usageCount = usages.first['count'] as int? ?? 0;
    }

    return CouponModel(
      id: json['id'] as String,
      code: json['code'] as String,
      discountType: json['discount_type'] == 'percentage'
          ? CouponDiscountType.percentage
          : CouponDiscountType.fixed,
      discountValue: (json['discount_value'] as num).toInt(),
      minOrderAmount: (json['min_order_amount'] as num).toInt(),
      maxUses: json['max_uses'] as int?,
      isActive: json['is_active'] as bool? ?? true,
      expiresAt: json['expires_at'] != null
          ? DateTime.parse(json['expires_at'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      usageCount: usageCount,
    );
  }

  Map<String, dynamic> toInsertJson() => {
    'code': code.toUpperCase().trim(),
    'discount_type': discountType == CouponDiscountType.percentage
        ? 'percentage'
        : 'fixed',
    'discount_value': discountValue,
    'min_order_amount': minOrderAmount,
    'max_uses': maxUses,
    'is_active': isActive,
    'expires_at': expiresAt?.toIso8601String(),
  };
}
