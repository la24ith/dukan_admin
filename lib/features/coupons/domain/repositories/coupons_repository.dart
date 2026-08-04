// lib/features/coupons/domain/repositories/coupons_repository.dart
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/coupon_entity.dart';

abstract class CouponsRepository {
  Future<Either<Failure, List<CouponEntity>>> getCoupons();
  Future<Either<Failure, CouponEntity>> addCoupon(CouponEntity coupon);
  Future<Either<Failure, CouponEntity>> updateCoupon(CouponEntity coupon);
  Future<Either<Failure, void>> deleteCoupon(String id);
}
