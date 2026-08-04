// lib/features/coupons/domain/usecases/coupons_usecases.dart
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/coupon_entity.dart';
import '../repositories/coupons_repository.dart';

class GetCoupons {
  final CouponsRepository repository;
  GetCoupons(this.repository);
  Future<Either<Failure, List<CouponEntity>>> call() => repository.getCoupons();
}

class AddCoupon {
  final CouponsRepository repository;
  AddCoupon(this.repository);
  Future<Either<Failure, CouponEntity>> call(CouponEntity coupon) =>
      repository.addCoupon(coupon);
}

class UpdateCoupon {
  final CouponsRepository repository;
  UpdateCoupon(this.repository);
  Future<Either<Failure, CouponEntity>> call(CouponEntity coupon) =>
      repository.updateCoupon(coupon);
}

class DeleteCoupon {
  final CouponsRepository repository;
  DeleteCoupon(this.repository);
  Future<Either<Failure, void>> call(String id) => repository.deleteCoupon(id);
}
