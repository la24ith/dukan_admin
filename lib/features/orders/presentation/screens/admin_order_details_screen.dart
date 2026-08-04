// lib/features/orders/presentation/screens/admin_order_details_screen.dart
import 'package:dukan_admin/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/format_syp.dart';
import '../../domain/entities/admin_order_entity.dart';
import '../../domain/entities/order_sub_entities.dart';
import '../../utils/order_status_ui.dart';
import '../cubit/admin_order_details_cubit.dart';

class AdminOrderDetailsScreen extends StatelessWidget {
  final String orderId;

  const AdminOrderDetailsScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<AdminOrderDetailsCubit>()..load(orderId),
      child: _AdminOrderDetailsView(orderId: orderId),
    );
  }
}

class _AdminOrderDetailsView extends StatelessWidget {
  final String orderId;

  const _AdminOrderDetailsView({required this.orderId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('تفاصيل الطلب')),
      body: BlocConsumer<AdminOrderDetailsCubit, AdminOrderDetailsState>(
        listener: (context, state) {
          if (state.updateStatus == StatusUpdateStatus.success) {
            rootScaffoldMessengerKey.currentState?.showSnackBar(
              const SnackBar(
                content: Text('تم تحديث حالة الطلب بنجاح'),
                backgroundColor: AppColors.jade,
              ),
            );
            context.read<AdminOrderDetailsCubit>().resetUpdateStatus();
          } else if (state.updateStatus == StatusUpdateStatus.error) {
            rootScaffoldMessengerKey.currentState?.showSnackBar(
              SnackBar(
                content: Text(state.updateError ?? 'حدث خطأ'),
                backgroundColor: AppColors.error,
              ),
            );
            context.read<AdminOrderDetailsCubit>().resetUpdateStatus();
          }
        },
        builder: (context, state) {
          if (state.status == AdminOrderDetailsStatus.loading &&
              state.order == null) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.jade),
            );
          }

          if (state.status == AdminOrderDetailsStatus.error) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    state.errorMessage ?? 'حدث خطأ',
                    style: AppTextStyles.bodyMuted,
                  ),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: () =>
                        context.read<AdminOrderDetailsCubit>().load(orderId),
                    child: const Text('إعادة المحاولة'),
                  ),
                ],
              ),
            );
          }

          final order = state.order!;
          final ui = OrderStatusUI.of(order.status);
          final isUpdating = state.updateStatus == StatusUpdateStatus.updating;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // ─── Header: رقم الطلب + الحالة ──────────────────────
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [ui.bg, ui.bg.withOpacity(0.5)],
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: ui.color.withOpacity(0.2)),
                ),
                child: Row(
                  children: [
                    Icon(ui.icon, color: ui.color, size: 28),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            ui.label,
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: ui.color,
                            ),
                          ),
                          Text(
                            '#${order.shortId}',
                            style: AppTextStyles.bodyMuted,
                          ),
                        ],
                      ),
                    ),
                    if (order.canChangeStatus)
                      _StatusUpdateButton(
                        order: order,
                        isUpdating: isUpdating,
                        onUpdate: (newStatus) =>
                            context.read<AdminOrderDetailsCubit>().updateStatus(
                              orderId: orderId,
                              newStatus: newStatus,
                            ),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // ─── بيانات الزبون ───────────────────────────────────
              _SectionCard(
                title: 'بيانات الزبون',
                icon: Icons.person_outline,
                children: [
                  _InfoRow(label: 'الاسم', value: order.customerName),
                  _InfoRow(
                    label: 'الهاتف',
                    value: order.customerPhone,
                    isPhone: true,
                  ),
                  _InfoRow(label: 'المحافظة', value: order.governorate),
                  _InfoRow(label: 'المنطقة', value: order.area),
                  if (order.addressDetails != null)
                    _InfoRow(label: 'التفاصيل', value: order.addressDetails!),
                ],
              ),

              const SizedBox(height: 12),

              // ─── المنتجات ────────────────────────────────────────
              _SectionCard(
                title: 'المنتجات (${state.items.length})',
                icon: Icons.inventory_2_outlined,
                children: state.items
                    .map((item) => _ItemRow(item: item))
                    .toList(),
              ),

              const SizedBox(height: 12),

              // ─── ملخص المبالغ ────────────────────────────────────
              _SectionCard(
                title: 'ملخص المبالغ',
                icon: Icons.receipt_outlined,
                children: [
                  _InfoRow(
                    label: 'المجموع الفرعي',
                    value: formatSyp(order.subtotal),
                  ),
                  _InfoRow(
                    label: 'رسوم التوصيل',
                    value: formatSyp(order.deliveryFee),
                  ),
                  if (order.discountAmount > 0)
                    _InfoRow(
                      label: 'الخصم',
                      value: '- ${formatSyp(order.discountAmount)}',
                      valueColor: AppColors.plum,
                    ),
                  const Divider(color: AppColors.hairline, height: 16),
                  _InfoRow(
                    label: 'الإجمالي',
                    value: formatSyp(order.total),
                    isTotal: true,
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // ─── Timeline ────────────────────────────────────────
              if (state.history.isNotEmpty)
                _SectionCard(
                  title: 'سجل الحالات',
                  icon: Icons.timeline_outlined,
                  children: state.history
                      .map((h) => _HistoryRow(history: h))
                      .toList(),
                ),

              const SizedBox(height: 24),
            ],
          );
        },
      ),
    );
  }
}

// ─── تغيير الحالة ────────────────────────────────────────────────────────
class _StatusUpdateButton extends StatelessWidget {
  final AdminOrderEntity order;
  final bool isUpdating;
  final ValueChanged<String> onUpdate;

  const _StatusUpdateButton({
    required this.order,
    required this.isUpdating,
    required this.onUpdate,
  });

  void _showDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('تغيير حالة الطلب'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: order.availableNextStatuses.map((status) {
            final ui = OrderStatusUI.of(status);
            return ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(color: ui.bg, shape: BoxShape.circle),
                child: Icon(ui.icon, color: ui.color, size: 18),
              ),
              title: Text(
                ui.label,
                style: AppTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              onTap: () {
                Navigator.of(dialogCtx).pop();
                onUpdate(status);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return isUpdating
        ? const SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: AppColors.jade,
            ),
          )
        : FilledButton.icon(
            onPressed: () => _showDialog(context),
            icon: const Icon(Icons.swap_horiz_rounded, size: 16),
            label: const Text('تحديث'),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.jade,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              textStyle: const TextStyle(
                fontFamily: 'Cairo',
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          );
  }
}

// ─── Widgets مساعدة ──────────────────────────────────────────────────────
class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.hairline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: AppColors.jade),
              const SizedBox(width: 8),
              Text(
                title,
                style: AppTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final bool isTotal;
  final bool isPhone;

  const _InfoRow({
    required this.label,
    required this.value,
    this.valueColor,
    this.isTotal = false,
    this.isPhone = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTextStyles.bodyMuted),
          const Spacer(),
          Text(
            value,
            style:
                (isTotal
                        ? AppTextStyles.headlineSmall.copyWith(
                            color: AppColors.jade,
                          )
                        : AppTextStyles.bodyLarge)
                    .copyWith(
                      color: valueColor,
                      fontFamily: isPhone ? 'monospace' : null,
                    ),
          ),
        ],
      ),
    );
  }
}

class _ItemRow extends StatelessWidget {
  final OrderItemEntity item;

  const _ItemRow({required this.item});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: const BoxDecoration(
              color: AppColors.jadeLight,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '${item.quantity}',
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.jade,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              item.productNameSnapshot,
              style: AppTextStyles.bodyLarge,
            ),
          ),
          Text(formatSyp(item.subtotal), style: AppTextStyles.price),
        ],
      ),
    );
  }
}

class _HistoryRow extends StatelessWidget {
  final OrderStatusHistoryEntity history;

  const _HistoryRow({required this.history});

  String _formatDate(DateTime dt) {
    const months = [
      'يناير',
      'فبراير',
      'مارس',
      'أبريل',
      'مايو',
      'يونيو',
      'يوليو',
      'أغسطس',
      'سبتمبر',
      'أكتوبر',
      'نوفمبر',
      'ديسمبر',
    ];
    return '${dt.day} ${months[dt.month - 1]} — ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
  }

  String _changedByLabel(String by) => switch (by) {
    'admin' => 'الأدمن',
    'customer' => 'الزبون',
    _ => 'النظام',
  };

  @override
  Widget build(BuildContext context) {
    final ui = OrderStatusUI.of(history.status);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(color: ui.bg, shape: BoxShape.circle),
            child: Icon(ui.icon, size: 15, color: ui.color),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ui.label,
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${_changedByLabel(history.changedBy)} • ${_formatDate(history.changedAt)}',
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
