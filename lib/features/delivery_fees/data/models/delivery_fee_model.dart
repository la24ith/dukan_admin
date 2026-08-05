// lib/features/delivery_fees/data/models/delivery_fee_model.dart
import '../../domain/entities/delivery_fee_entity.dart';

class DeliveryFeeModel extends DeliveryFeeEntity {
  const DeliveryFeeModel({
    required super.id,
    required super.governorate,
    required super.fee,
  });

  factory DeliveryFeeModel.fromJson(Map<String, dynamic> json) {
    return DeliveryFeeModel(
      id: json['id'] as String,
      governorate: json['governorate'] as String,
      fee: (json['fee'] as num).toInt(),
    );
  }
}
