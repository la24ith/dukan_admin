// lib/features/coupons/data/repositories/coupons_repository_impl.dart
import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/coupon_entity.dart';
import '../../domain/repositories/coupons_repository.dart';
import '../datasources/coupons_remote_data_source.dart';
import '../models/coupon_model.dart';

class CouponsRepositoryImpl implements CouponsRepository {
  final CouponsRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  CouponsRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<CouponEntity>>> getCoupons() async {
    if (!await networkInfo.isConnected) return const Left(NetworkFailure());
    try {
      return Right(await remoteDataSource.getCoupons());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, CouponEntity>> addCoupon(CouponEntity coupon) async {
    if (!await networkInfo.isConnected) return const Left(NetworkFailure());
    try {
      return Right(await remoteDataSource.addCoupon(coupon as CouponModel));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, CouponEntity>> updateCoupon(
    CouponEntity coupon,
  ) async {
    if (!await networkInfo.isConnected) return const Left(NetworkFailure());
    try {
      return Right(await remoteDataSource.updateCoupon(coupon as CouponModel));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> deleteCoupon(String id) async {
    if (!await networkInfo.isConnected) return const Left(NetworkFailure());
    try {
      await remoteDataSource.deleteCoupon(id);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }
}
