// lib/features/coupons/data/datasources/coupons_remote_data_source.dart
import 'package:dukan_admin/core/error/supabase_guard.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/coupon_model.dart';

abstract class CouponsRemoteDataSource {
  Future<List<CouponModel>> getCoupons();
  Future<CouponModel> addCoupon(CouponModel coupon);
  Future<CouponModel> updateCoupon(CouponModel coupon);
  Future<void> deleteCoupon(String id);
}

class CouponsRemoteDataSourceImpl implements CouponsRemoteDataSource {
  final SupabaseClient client;
  CouponsRemoteDataSourceImpl(this.client);

  static const _select = '*, coupon_usages(count)';

  @override
  Future<List<CouponModel>> getCoupons() async {
    return guardSupabaseCall(() async {
      final rows = await client
          .from('coupons')
          .select(_select)
          .order('created_at', ascending: false);
      return (rows as List).map((e) => CouponModel.fromJson(e)).toList();
    });
  }

  @override
  Future<CouponModel> addCoupon(CouponModel coupon) async {
    return guardSupabaseCall(() async {
      final row = await client
          .from('coupons')
          .insert(coupon.toInsertJson())
          .select(_select)
          .single();
      return CouponModel.fromJson(row);
    });
  }

  @override
  Future<CouponModel> updateCoupon(CouponModel coupon) async {
    return guardSupabaseCall(() async {
      final row = await client
          .from('coupons')
          .update(coupon.toInsertJson())
          .eq('id', coupon.id)
          .select(_select)
          .single();
      return CouponModel.fromJson(row);
    });
  }

  @override
  Future<void> deleteCoupon(String id) async {
    return guardSupabaseCall(() async {
      await client.from('coupons').delete().eq('id', id);
    });
  }
}
