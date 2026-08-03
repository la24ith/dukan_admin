// lib/features/orders/presentation/screens/admin_orders_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/format_syp.dart';
import '../../domain/entities/admin_order_entity.dart';
import '../../utils/order_status_ui.dart';
import '../cubit/admin_orders_cubit.dart';
import 'admin_order_details_screen.dart';

class AdminOrdersScreen extends StatelessWidget {
  const AdminOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<AdminOrdersCubit>()..load(),
      child: const _AdminOrdersView(),
    );
  }
}

class _AdminOrdersView extends StatefulWidget {
  const _AdminOrdersView();

  @override
  State<_AdminOrdersView> createState() => _AdminOrdersViewState();
}

class _AdminOrdersViewState extends State<_AdminOrdersView> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  static const _filters = [
    ('all', 'الكل'),
    ('pending', 'انتظار'),
    ('confirmed', 'مؤكد'),
    ('preparing', 'تحضير'),
    ('shipping', 'شحن'),
    ('delivered', 'مُسلَّم'),
    ('cancelled', 'ملغي'),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Text('الطلبات'),
        actions: [
          BlocBuilder<AdminOrdersCubit, AdminOrdersState>(
            builder: (context, state) {
              if (state.status != AdminOrdersStatus.ready) {
                return const SizedBox.shrink();
              }
              return Padding(
                padding: const EdgeInsetsDirectional.only(end: 16),
                child: Center(
                  child: Text(
                    '${state.orders.length}',
                    style: AppTextStyles.bodyMuted.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // ─── Search Bar ──────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              controller: _searchController,
              onChanged: (v) => setState(() => _searchQuery = v.trim()),
              decoration: InputDecoration(
                hintText: 'ابحث باسم الزبون أو رقم الطلب...',
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  color: AppColors.inkMuted,
                  size: 20,
                ),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(
                          Icons.close_rounded,
                          size: 18,
                          color: AppColors.inkMuted,
                        ),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 11,
                  horizontal: 14,
                ),
              ),
            ),
          ),

          // ─── Filter Chips ─────────────────────────────────────────
          SizedBox(
            height: 44,
            child: BlocBuilder<AdminOrdersCubit, AdminOrdersState>(
              buildWhen: (a, b) => a.selectedFilter != b.selectedFilter,
              builder: (context, state) {
                return ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: _filters.map((f) {
                    final (value, label) = f;
                    final selected = state.selectedFilter == value;
                    return GestureDetector(
                      onTap: () =>
                          context.read<AdminOrdersCubit>().setFilter(value),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        margin: const EdgeInsetsDirectional.only(end: 8),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: selected
                              ? AppColors.jade
                              : AppColors.surfaceElevated,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: selected
                                ? AppColors.jade
                                : AppColors.hairline,
                          ),
                        ),
                        child: Text(
                          label,
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: selected ? Colors.white : AppColors.ink,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ),
          const SizedBox(height: 8),

          // ─── القائمة ─────────────────────────────────────────────
          Expanded(
            child: BlocBuilder<AdminOrdersCubit, AdminOrdersState>(
              builder: (context, state) {
                if (state.status == AdminOrdersStatus.loading) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.jade),
                  );
                }

                if (state.status == AdminOrdersStatus.error) {
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
                              context.read<AdminOrdersCubit>().load(),
                          child: const Text('إعادة المحاولة'),
                        ),
                      ],
                    ),
                  );
                }

                // فلترة البحث محلياً
                final orders = _searchQuery.isEmpty
                    ? state.orders
                    : state.orders.where((o) {
                        final q = _searchQuery.toLowerCase();
                        return o.customerName.toLowerCase().contains(q) ||
                            o.customerPhone.contains(q) ||
                            o.id.toLowerCase().contains(q);
                      }).toList();

                if (orders.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.receipt_long_outlined,
                          size: 48,
                          color: AppColors.hairline,
                        ),
                        const SizedBox(height: 12),
                        Text('لا توجد طلبات', style: AppTextStyles.bodyMuted),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  color: AppColors.jade,
                  onRefresh: () => context.read<AdminOrdersCubit>().load(
                    statusFilter: state.selectedFilter == 'all'
                        ? null
                        : state.selectedFilter,
                  ),
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                    itemCount: orders.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, i) => _AdminOrderCard(
                      order: orders[i],
                      onTap: () =>
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => AdminOrderDetailsScreen(
                                orderId: orders[i].id,
                              ),
                            ),
                          ).then(
                            (_) => context.read<AdminOrdersCubit>().load(
                              statusFilter: state.selectedFilter == 'all'
                                  ? null
                                  : state.selectedFilter,
                            ),
                          ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _AdminOrderCard extends StatelessWidget {
  final AdminOrderEntity order;
  final VoidCallback onTap;

  const _AdminOrderCard({required this.order, required this.onTap});

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
    return '${dt.day} ${months[dt.month - 1]} ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final ui = OrderStatusUI.of(order.status);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.hairline),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Row 1: رقم الطلب + badge الحالة
            Row(
              children: [
                Text(
                  '#${order.shortId}',
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.w700,
                    fontFamily: 'monospace',
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: ui.bg,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(ui.icon, size: 13, color: ui.color),
                      const SizedBox(width: 4),
                      Text(
                        ui.label,
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: ui.color,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Row 2: اسم الزبون + هاتفه
            Row(
              children: [
                const Icon(
                  Icons.person_outline,
                  size: 15,
                  color: AppColors.inkMuted,
                ),
                const SizedBox(width: 6),
                Text(order.customerName, style: AppTextStyles.bodyLarge),
                const SizedBox(width: 12),
                const Icon(
                  Icons.phone_outlined,
                  size: 14,
                  color: AppColors.inkMuted,
                ),
                const SizedBox(width: 4),
                Text(
                  order.customerPhone,
                  style: AppTextStyles.bodyMuted.copyWith(
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),

            // Row 3: العنوان
            Row(
              children: [
                const Icon(
                  Icons.location_on_outlined,
                  size: 14,
                  color: AppColors.inkMuted,
                ),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(
                    order.fullAddress,
                    style: AppTextStyles.caption,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            const Divider(color: AppColors.hairline, height: 1),
            const SizedBox(height: 10),

            // Row 4: المبلغ + التاريخ + عدد المنتجات
            Row(
              children: [
                Text(
                  formatSyp(order.total),
                  style: AppTextStyles.price.copyWith(fontSize: 15),
                ),
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${order.itemsCount} منتج',
                    style: AppTextStyles.caption,
                  ),
                ),
                const Spacer(),
                Text(
                  _formatDate(order.createdAt),
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
