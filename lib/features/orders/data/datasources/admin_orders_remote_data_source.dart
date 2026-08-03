// lib/features/orders/data/datasources/admin_orders_remote_data_source.dart
import 'package:dukan_admin/core/error/supabase_guard.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/admin_order_model.dart';

abstract class AdminOrdersRemoteDataSource {
  Future<List<AdminOrderModel>> getOrders({String? statusFilter});
  Future<AdminOrderModel> getOrderDetails(String orderId);
  Future<List<OrderItemModel>> getOrderItems(String orderId);
  Future<List<OrderStatusHistoryModel>> getOrderHistory(String orderId);
  Future<void> updateOrderStatus({
    required String orderId,
    required String newStatus,
  });
}

class AdminOrdersRemoteDataSourceImpl implements AdminOrdersRemoteDataSource {
  final SupabaseClient client;
  AdminOrdersRemoteDataSourceImpl(this.client);

  // Select الكامل: طلب + بيانات الزبون + العنوان + عدد المنتجات
  static const _ordersSelect =
      '*, profiles(full_name, phone), addresses(governorate, area, details), order_items(count)';

  @override
  Future<List<AdminOrderModel>> getOrders({String? statusFilter}) async {
    return guardSupabaseCall(() async {
      var query = client.from('orders').select(_ordersSelect);

      if (statusFilter != null && statusFilter != 'all') {
        query = query.eq('status', statusFilter);
      }

      final rows = await query.order('created_at', ascending: false);
      return (rows as List).map((e) => AdminOrderModel.fromJson(e)).toList();
    });
  }

  @override
  Future<AdminOrderModel> getOrderDetails(String orderId) async {
    return guardSupabaseCall(() async {
      final row = await client
          .from('orders')
          .select(_ordersSelect)
          .eq('id', orderId)
          .single();
      return AdminOrderModel.fromJson(row);
    });
  }

  @override
  Future<List<OrderItemModel>> getOrderItems(String orderId) async {
    return guardSupabaseCall(() async {
      final rows = await client
          .from('order_items')
          .select()
          .eq('order_id', orderId);
      return (rows as List).map((e) => OrderItemModel.fromJson(e)).toList();
    });
  }

  @override
  Future<List<OrderStatusHistoryModel>> getOrderHistory(
    String orderId,
  ) async {
    return guardSupabaseCall(() async {
      final rows = await client
          .from('order_status_history')
          .select()
          .eq('order_id', orderId)
          .order('changed_at', ascending: true);
      return (rows as List)
          .map((e) => OrderStatusHistoryModel.fromJson(e))
          .toList();
    });
  }

  @override
  Future<void> updateOrderStatus({
    required String orderId,
    required String newStatus,
  }) async {
    return guardSupabaseCall(() async {
      // update_order_status RPC — is_admin() تتحقق داخلها تلقائياً
      await client.rpc('update_order_status', params: {
        'p_order_id': orderId,
        'p_new_status': newStatus,
      });
    });
  }
}
