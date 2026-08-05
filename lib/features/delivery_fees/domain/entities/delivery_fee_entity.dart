// lib/features/delivery_fees/domain/entities/delivery_fee_entity.dart
import 'package:equatable/equatable.dart';

class DeliveryFeeEntity extends Equatable {
  final String id;
  final String governorate;
  final int fee;

  const DeliveryFeeEntity({
    required this.id,
    required this.governorate,
    required this.fee,
  });

  @override
  List<Object?> get props => [id, governorate, fee];
}
