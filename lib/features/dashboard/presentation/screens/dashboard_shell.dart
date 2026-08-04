// lib/features/dashboard/presentation/screens/dashboard_shell.dart
import 'package:dukan_admin/features/coupons/presentation/screens/coupons_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/routing/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';
import '../../../orders/presentation/screens/admin_orders_screen.dart';
import '../../../products/presentation/screens/admin_products_screen.dart';
import '../../../categories/presentation/screens/categories_screen.dart';

class DashboardShell extends StatefulWidget {
  const DashboardShell({super.key});

  @override
  State<DashboardShell> createState() => _DashboardShellState();
}

class _DashboardShellState extends State<DashboardShell> {
  int _index = 0;
  late final AuthCubit _authCubit;

  // التبويبات ستُبنى تدريجياً — الآن placeholders مؤقتة
  static const _tabs = [
    _TabInfo(icon: Icons.receipt_long_outlined, label: 'الطلبات'),
    _TabInfo(icon: Icons.inventory_2_outlined, label: 'المنتجات'),
    _TabInfo(icon: Icons.category_outlined, label: 'التصنيفات'),
    _TabInfo(icon: Icons.discount_outlined, label: 'الكوبونات'),
    _TabInfo(icon: Icons.local_shipping_outlined, label: 'التوصيل'),
  ];

  @override
  void initState() {
    super.initState();
    _authCubit = sl<AuthCubit>()..checkAuthStatus();
  }

  @override
  void dispose() {
    _authCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _authCubit,
      child: BlocListener<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state.status == AuthStatus.unauthenticated) {
            Navigator.of(
              context,
              rootNavigator: true,
            ).pushNamedAndRemoveUntil(AppRoutes.auth, (r) => false);
          }
        },
        child: Scaffold(
          appBar: AppBar(
            title: Text(_tabs[_index].label),
            actions: [
              IconButton(
                icon: const Icon(Icons.logout_rounded),
                tooltip: 'تسجيل الخروج',
                onPressed: () => _confirmSignOut(context),
              ),
            ],
          ),
          body: IndexedStack(
            index: _index,
            children: [
              const AdminOrdersScreen(),
              const AdminProductsScreen(),
              const CategoriesScreen(),
              const CouponsScreen(),
              _PlaceholderTabBody(
                icon: Icons.local_shipping_outlined,
                label: 'التوصيل',
              ),
            ],
          ),
          bottomNavigationBar: NavigationBar(
            selectedIndex: _index,
            onDestinationSelected: (i) => setState(() => _index = i),
            destinations: _tabs
                .map(
                  (tab) => NavigationDestination(
                    icon: Icon(tab.icon),
                    label: tab.label,
                  ),
                )
                .toList(),
          ),
        ),
      ),
    );
  }

  void _confirmSignOut(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('تسجيل الخروج'),
        content: const Text('هل تريد تسجيل الخروج من لوحة التحكم؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(dialogCtx).pop();
              _authCubit.signOut();
            },
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('خروج'),
          ),
        ],
      ),
    );
  }
}

class _TabInfo {
  final IconData icon;
  final String label;
  const _TabInfo({required this.icon, required this.label});
}

class _PlaceholderTabBody extends StatelessWidget {
  final IconData icon;
  final String label;
  const _PlaceholderTabBody({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 56, color: AppColors.hairline),
          const SizedBox(height: 12),
          Text('$label — قيد الإنشاء', style: AppTextStyles.bodyMuted),
        ],
      ),
    );
  }
}
