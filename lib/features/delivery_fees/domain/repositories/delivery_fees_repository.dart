// lib/features/delivery_fees/domain/repositories/delivery_fees_repository.dart
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/delivery_fee_entity.dart';

abstract class DeliveryFeesRepository {
  Future<Either<Failure, List<DeliveryFeeEntity>>> getDeliveryFees();
  Future<Either<Failure, DeliveryFeeEntity>> addDeliveryFee({
    required String governorate,
    required int fee,
  });
  Future<Either<Failure, DeliveryFeeEntity>> updateDeliveryFee({
    required String id,
    required int fee,
  });
  Future<Either<Failure, void>> deleteDeliveryFee(String id);
}
