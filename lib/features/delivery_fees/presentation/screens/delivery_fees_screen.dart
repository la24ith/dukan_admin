// lib/features/delivery_fees/presentation/screens/delivery_fees_screen.dart
import 'package:dukan_admin/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/format_syp.dart';
import '../../domain/entities/delivery_fee_entity.dart';
import '../cubit/delivery_fees_cubit.dart';

class DeliveryFeesScreen extends StatelessWidget {
  const DeliveryFeesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<DeliveryFeesCubit>()..load(),
      child: const _DeliveryFeesView(),
    );
  }
}

class _DeliveryFeesView extends StatelessWidget {
  const _DeliveryFeesView();

  // المحافظات السورية — لفلترة المضافة مسبقاً
  static const _allGovernorates = [
    'دمشق',
    'ريف دمشق',
    'حلب',
    'حمص',
    'حماة',
    'اللاذقية',
    'طرطوس',
    'إدلب',
    'دير الزور',
    'الرقة',
    'الحسكة',
    'القنيطرة',
    'السويداء',
    'درعا',
  ];

  void _openAddDialog(BuildContext context, List<String> usedGovernorates) {
    final available = _allGovernorates
        .where((g) => !usedGovernorates.contains(g))
        .toList();

    if (available.isEmpty) {
      rootScaffoldMessengerKey.currentState?.showSnackBar(
        const SnackBar(
          content: Text('تم إضافة رسوم لكل المحافظات'),
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.all(16),
        ),
      );
      return;
    }

    String? selectedGov = available.first;
    final feeCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (d) => StatefulBuilder(
        builder: (d, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text('إضافة رسوم توصيل'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: selectedGov,
                decoration: const InputDecoration(labelText: 'المحافظة'),
                items: available
                    .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                    .toList(),
                onChanged: (v) => setDialogState(() => selectedGov = v),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: feeCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'رسوم التوصيل (ل.س)',
                ),
                autofocus: true,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(d).pop(),
              child: const Text('إلغاء'),
            ),
            FilledButton(
              onPressed: () {
                final fee = int.tryParse(feeCtrl.text);
                if (fee == null || fee < 0) return;
                Navigator.of(d).pop();
                context.read<DeliveryFeesCubit>().add(
                  governorate: selectedGov!,
                  fee: fee,
                );
              },
              child: const Text('إضافة'),
            ),
          ],
        ),
      ),
    );
  }

  void _openEditDialog(BuildContext context, DeliveryFeeEntity fee) {
    final feeCtrl = TextEditingController(text: fee.fee.toString());

    showDialog(
      context: context,
      builder: (d) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('تعديل رسوم ${fee.governorate}'),
        content: TextField(
          controller: feeCtrl,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'رسوم التوصيل (ل.س)'),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(d).pop(),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: () {
              final newFee = int.tryParse(feeCtrl.text);
              if (newFee == null || newFee < 0) return;
              Navigator.of(d).pop();
              context.read<DeliveryFeesCubit>().update(id: fee.id, fee: newFee);
            },
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(title: const Text('رسوم التوصيل')),
      body: BlocConsumer<DeliveryFeesCubit, DeliveryFeesState>(
        listener: (context, state) {
          if (state.mutationStatus == DeliveryFeeMutationStatus.error &&
              state.mutationError != null) {
            rootScaffoldMessengerKey.currentState?.showSnackBar(
              SnackBar(
                content: Text(state.mutationError!),
                backgroundColor: AppColors.error,
                behavior: SnackBarBehavior.floating,
                margin: const EdgeInsets.all(16),
              ),
            );
            context.read<DeliveryFeesCubit>().resetMutation();
          }
        },
        builder: (context, state) {
          if (state.status == DeliveryFeesStatus.loading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.jade),
            );
          }

          if (state.status == DeliveryFeesStatus.error) {
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
                    onPressed: () => context.read<DeliveryFeesCubit>().load(),
                    child: const Text('إعادة المحاولة'),
                  ),
                ],
              ),
            );
          }

          final usedGovs = state.fees.map((f) => f.governorate).toList();
          final remaining = _allGovernorates.length - state.fees.length;

          return Column(
            children: [
              // إحصائية
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.hairline),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.local_shipping_outlined,
                      color: AppColors.jade,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      '${state.fees.length} محافظة مضبوطة',
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    if (remaining > 0)
                      Text(
                        '$remaining بدون رسوم',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.brass,
                        ),
                      ),
                  ],
                ),
              ),

              // القائمة
              Expanded(
                child: state.fees.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.local_shipping_outlined,
                              size: 56,
                              color: AppColors.hairline,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'لا توجد رسوم توصيل بعد',
                              style: AppTextStyles.bodyMuted,
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        color: AppColors.jade,
                        onRefresh: () =>
                            context.read<DeliveryFeesCubit>().load(),
                        child: ListView.separated(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                          itemCount: state.fees.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 8),
                          itemBuilder: (context, i) {
                            final fee = state.fees[i];
                            return Container(
                              decoration: BoxDecoration(
                                color: AppColors.surfaceElevated,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.hairline),
                              ),
                              child: ListTile(
                                leading: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: const BoxDecoration(
                                    color: AppColors.jadeLight,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.location_on_outlined,
                                    color: AppColors.jade,
                                    size: 18,
                                  ),
                                ),
                                title: Text(
                                  fee.governorate,
                                  style: AppTextStyles.bodyLarge.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                subtitle: Text(
                                  formatSyp(fee.fee),
                                  style: AppTextStyles.price.copyWith(
                                    fontSize: 13,
                                  ),
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(
                                        Icons.edit_outlined,
                                        color: AppColors.jade,
                                        size: 18,
                                      ),
                                      onPressed: () =>
                                          _openEditDialog(context, fee),
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.delete_outline_rounded,
                                        color: AppColors.error,
                                        size: 18,
                                      ),
                                      onPressed: () =>
                                          _confirmDelete(context, fee),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'fab_delivery',
        onPressed: () {
          final usedGovs = context
              .read<DeliveryFeesCubit>()
              .state
              .fees
              .map((f) => f.governorate)
              .toList();
          _openAddDialog(context, usedGovs);
        },
        backgroundColor: AppColors.jade,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'إضافة محافظة',
          style: TextStyle(
            fontFamily: 'Cairo',
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, DeliveryFeeEntity fee) {
    showDialog(
      context: context,
      builder: (d) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('حذف رسوم التوصيل'),
        content: Text(
          'هل تريد حذف رسوم توصيل ${fee.governorate}؟\nالطلبات القديمة لن تتأثر.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(d).pop(),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(d).pop();
              context.read<DeliveryFeesCubit>().delete(fee.id);
            },
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }
}
