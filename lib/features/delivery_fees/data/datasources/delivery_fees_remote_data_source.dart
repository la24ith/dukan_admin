// lib/features/delivery_fees/data/datasources/delivery_fees_remote_data_source.dart
import 'package:dukan_admin/core/error/supabase_guard.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/delivery_fee_model.dart';

abstract class DeliveryFeesRemoteDataSource {
  Future<List<DeliveryFeeModel>> getDeliveryFees();
  Future<DeliveryFeeModel> addDeliveryFee({
    required String governorate,
    required int fee,
  });
  Future<DeliveryFeeModel> updateDeliveryFee({
    required String id,
    required int fee,
  });
  Future<void> deleteDeliveryFee(String id);
}

class DeliveryFeesRemoteDataSourceImpl implements DeliveryFeesRemoteDataSource {
  final SupabaseClient client;
  DeliveryFeesRemoteDataSourceImpl(this.client);

  @override
  Future<List<DeliveryFeeModel>> getDeliveryFees() async {
    return guardSupabaseCall(() async {
      final rows = await client
          .from('delivery_fees')
          .select()
          .order('governorate');
      return (rows as List).map((e) => DeliveryFeeModel.fromJson(e)).toList();
    });
  }

  @override
  Future<DeliveryFeeModel> addDeliveryFee({
    required String governorate,
    required int fee,
  }) async {
    return guardSupabaseCall(() async {
      final row = await client
          .from('delivery_fees')
          .insert({'governorate': governorate, 'fee': fee})
          .select()
          .single();
      return DeliveryFeeModel.fromJson(row);
    });
  }

  @override
  Future<DeliveryFeeModel> updateDeliveryFee({
    required String id,
    required int fee,
  }) async {
    return guardSupabaseCall(() async {
      final row = await client
          .from('delivery_fees')
          .update({'fee': fee})
          .eq('id', id)
          .select()
          .single();
      return DeliveryFeeModel.fromJson(row);
    });
  }

  @override
  Future<void> deleteDeliveryFee(String id) async {
    return guardSupabaseCall(() async {
      await client.from('delivery_fees').delete().eq('id', id);
    });
  }
}
