// lib/features/delivery_fees/domain/usecases/delivery_fees_usecases.dart
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/delivery_fee_entity.dart';
import '../repositories/delivery_fees_repository.dart';

class GetDeliveryFees {
  final DeliveryFeesRepository repository;
  GetDeliveryFees(this.repository);
  Future<Either<Failure, List<DeliveryFeeEntity>>> call() =>
      repository.getDeliveryFees();
}

class AddDeliveryFee {
  final DeliveryFeesRepository repository;
  AddDeliveryFee(this.repository);
  Future<Either<Failure, DeliveryFeeEntity>> call({
    required String governorate,
    required int fee,
  }) => repository.addDeliveryFee(governorate: governorate, fee: fee);
}

class UpdateDeliveryFee {
  final DeliveryFeesRepository repository;
  UpdateDeliveryFee(this.repository);
  Future<Either<Failure, DeliveryFeeEntity>> call({
    required String id,
    required int fee,
  }) => repository.updateDeliveryFee(id: id, fee: fee);
}

class DeleteDeliveryFee {
  final DeliveryFeesRepository repository;
  DeleteDeliveryFee(this.repository);
  Future<Either<Failure, void>> call(String id) =>
      repository.deleteDeliveryFee(id);
}
