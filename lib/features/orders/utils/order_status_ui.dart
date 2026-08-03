// lib/features/orders/utils/order_status_ui.dart
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class OrderStatusUI {
  final String label;
  final Color color;
  final Color bg;
  final IconData icon;

  const OrderStatusUI({
    required this.label,
    required this.color,
    required this.bg,
    required this.icon,
  });

  static OrderStatusUI of(String status) {
    switch (status) {
      case 'pending':
        return const OrderStatusUI(
          label: 'قيد الانتظار',
          color: AppColors.brass,
          bg: AppColors.brassLight,
          icon: Icons.hourglass_top_outlined,
        );
      case 'confirmed':
        return const OrderStatusUI(
          label: 'تم التأكيد',
          color: AppColors.jade,
          bg: AppColors.jadeLight,
          icon: Icons.task_alt_outlined,
        );
      case 'preparing':
        return const OrderStatusUI(
          label: 'قيد التحضير',
          color: AppColors.info,
          bg: AppColors.infoLight,
          icon: Icons.inventory_2_outlined,
        );
      case 'shipping':
        return const OrderStatusUI(
          label: 'في الطريق',
          color: AppColors.plum,
          bg: AppColors.plumLight,
          icon: Icons.local_shipping_outlined,
        );
      case 'delivered':
        return const OrderStatusUI(
          label: 'تم التوصيل',
          color: AppColors.jade,
          bg: AppColors.jadeLight,
          icon: Icons.check_circle_outline,
        );
      case 'cancelled':
        return const OrderStatusUI(
          label: 'ملغي',
          color: AppColors.error,
          bg: AppColors.errorLight,
          icon: Icons.cancel_outlined,
        );
      default:
        return const OrderStatusUI(
          label: 'غير معروف',
          color: AppColors.inkMuted,
          bg: AppColors.hairline,
          icon: Icons.help_outline,
        );
    }
  }

  static const List<String> stages = [
    'pending',
    'confirmed',
    'preparing',
    'shipping',
    'delivered',
  ];

  static String labelOf(String status) => of(status).label;
}
