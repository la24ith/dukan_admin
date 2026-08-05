// lib/features/delivery_fees/data/repositories/delivery_fees_repository_impl.dart
import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/delivery_fee_entity.dart';
import '../../domain/repositories/delivery_fees_repository.dart';
import '../datasources/delivery_fees_remote_data_source.dart';

class DeliveryFeesRepositoryImpl implements DeliveryFeesRepository {
  final DeliveryFeesRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  DeliveryFeesRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<DeliveryFeeEntity>>> getDeliveryFees() async {
    if (!await networkInfo.isConnected) return const Left(NetworkFailure());
    try {
      return Right(await remoteDataSource.getDeliveryFees());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, DeliveryFeeEntity>> addDeliveryFee({
    required String governorate,
    required int fee,
  }) async {
    if (!await networkInfo.isConnected) return const Left(NetworkFailure());
    try {
      return Right(
        await remoteDataSource.addDeliveryFee(
          governorate: governorate,
          fee: fee,
        ),
      );
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, DeliveryFeeEntity>> updateDeliveryFee({
    required String id,
    required int fee,
  }) async {
    if (!await networkInfo.isConnected) return const Left(NetworkFailure());
    try {
      return Right(await remoteDataSource.updateDeliveryFee(id: id, fee: fee));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> deleteDeliveryFee(String id) async {
    if (!await networkInfo.isConnected) return const Left(NetworkFailure());
    try {
      await remoteDataSource.deleteDeliveryFee(id);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }
}
