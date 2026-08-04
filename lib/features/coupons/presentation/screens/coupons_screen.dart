// lib/features/coupons/presentation/screens/coupons_screen.dart
import 'package:dukan_admin/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/format_syp.dart';
import '../../data/models/coupon_model.dart';
import '../../domain/entities/coupon_entity.dart';
import '../cubit/coupons_cubit.dart';

class CouponsScreen extends StatelessWidget {
  const CouponsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<CouponsCubit>()..load(),
      child: const _CouponsView(),
    );
  }
}

class _CouponsView extends StatelessWidget {
  const _CouponsView();

  void _openForm(BuildContext context, {CouponEntity? coupon}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) => BlocProvider.value(
        value: context.read<CouponsCubit>(),
        child: _CouponFormSheet(coupon: coupon),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(title: const Text('الكوبونات')),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'fab_coupons',
        onPressed: () => _openForm(context),
        backgroundColor: AppColors.jade,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'كوبون جديد',
          style: TextStyle(
            fontFamily: 'Cairo',
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: BlocConsumer<CouponsCubit, CouponsState>(
        listener: (context, state) {
          if (state.mutationStatus == CouponMutationStatus.error &&
              state.mutationError != null) {
            rootScaffoldMessengerKey.currentState?.showSnackBar(
              SnackBar(
                content: Text(state.mutationError!),
                backgroundColor: AppColors.error,
                behavior: SnackBarBehavior.floating,
                margin: const EdgeInsets.all(16),
              ),
            );
            context.read<CouponsCubit>().resetMutation();
          }
        },
        builder: (context, state) {
          if (state.status == CouponsStatus.loading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.jade),
            );
          }
          if (state.status == CouponsStatus.error) {
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
                    onPressed: () => context.read<CouponsCubit>().load(),
                    child: const Text('إعادة المحاولة'),
                  ),
                ],
              ),
            );
          }
          if (state.coupons.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.discount_outlined,
                    size: 56,
                    color: AppColors.hairline,
                  ),
                  const SizedBox(height: 12),
                  Text('لا توجد كوبونات بعد', style: AppTextStyles.bodyMuted),
                ],
              ),
            );
          }
          return RefreshIndicator(
            color: AppColors.jade,
            onRefresh: () => context.read<CouponsCubit>().load(),
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
              itemCount: state.coupons.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, i) => _CouponCard(
                coupon: state.coupons[i],
                onEdit: () => _openForm(context, coupon: state.coupons[i]),
                onDelete: () => _confirmDelete(context, state.coupons[i]),
              ),
            ),
          );
        },
      ),
    );
  }

  void _confirmDelete(BuildContext context, CouponEntity coupon) {
    showDialog(
      context: context,
      builder: (d) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('حذف الكوبون'),
        content: Text(
          'هل تريد حذف كوبون "${coupon.code}"؟\nلن يمكن التراجع عن هذا الإجراء.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(d).pop(),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(d).pop();
              context.read<CouponsCubit>().delete(coupon.id);
            },
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }
}

// ─── بطاقة الكوبون ────────────────────────────────────────────────────────
class _CouponCard extends StatelessWidget {
  final CouponEntity coupon;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _CouponCard({
    required this.coupon,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = coupon.isEffectivelyActive;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isActive
              ? AppColors.plum.withOpacity(0.3)
              : AppColors.hairline,
        ),
      ),
      child: Column(
        children: [
          // Header: الكود + status
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isActive ? AppColors.plumLight : AppColors.surface,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(14),
              ),
            ),
            child: Row(
              children: [
                // كود الكوبون قابل للنسخ
                GestureDetector(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: coupon.code));
                    rootScaffoldMessengerKey.currentState?.showSnackBar(
                      const SnackBar(
                        content: Text('تم نسخ الكود'),
                        behavior: SnackBarBehavior.floating,
                        margin: EdgeInsets.all(16),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  },
                  child: Row(
                    children: [
                      Text(
                        coupon.code,
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.plum,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Icon(
                        Icons.copy_rounded,
                        size: 14,
                        color: AppColors.plum,
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                _StatusBadge(coupon: coupon),
              ],
            ),
          ),

          // Body: التفاصيل
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              children: [
                Row(
                  children: [
                    _InfoChip(
                      icon: Icons.discount_outlined,
                      label: coupon.discountLabel,
                      color: AppColors.plum,
                      bg: AppColors.plumLight,
                    ),
                    const SizedBox(width: 8),
                    _InfoChip(
                      icon: Icons.shopping_cart_outlined,
                      label: 'حد أدنى ${formatSyp(coupon.minOrderAmount)}',
                      color: AppColors.jade,
                      bg: AppColors.jadeLight,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _InfoChip(
                      icon: Icons.people_outline,
                      label: coupon.maxUses != null
                          ? '${coupon.usageCount}/${coupon.maxUses} استخدام'
                          : '${coupon.usageCount} استخدام (غير محدود)',
                      color: AppColors.inkMuted,
                      bg: AppColors.surface,
                    ),
                    if (coupon.expiresAt != null) ...[
                      const SizedBox(width: 8),
                      _InfoChip(
                        icon: Icons.calendar_today_outlined,
                        label: _formatDate(coupon.expiresAt!),
                        color: coupon.isExpired
                            ? AppColors.error
                            : AppColors.inkMuted,
                        bg: coupon.isExpired
                            ? AppColors.errorLight
                            : AppColors.surface,
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 10),
                const Divider(color: AppColors.hairline, height: 1),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      onPressed: onEdit,
                      icon: const Icon(
                        Icons.edit_outlined,
                        size: 16,
                        color: AppColors.jade,
                      ),
                      label: const Text(
                        'تعديل',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          color: AppColors.jade,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    TextButton.icon(
                      onPressed: onDelete,
                      icon: const Icon(
                        Icons.delete_outline_rounded,
                        size: 16,
                        color: AppColors.error,
                      ),
                      label: const Text(
                        'حذف',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          color: AppColors.error,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

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
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }
}

class _StatusBadge extends StatelessWidget {
  final CouponEntity coupon;
  const _StatusBadge({required this.coupon});

  @override
  Widget build(BuildContext context) {
    String label;
    Color color;
    Color bg;

    if (!coupon.isActive) {
      label = 'معطّل';
      color = AppColors.inkMuted;
      bg = AppColors.hairline;
    } else if (coupon.isExpired) {
      label = 'منتهي';
      color = AppColors.error;
      bg = AppColors.errorLight;
    } else if (coupon.isMaxedOut) {
      label = 'استُنفد';
      color = AppColors.brass;
      bg = AppColors.brassLight;
    } else {
      label = 'فعّال';
      color = AppColors.jade;
      bg = AppColors.jadeLight;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'Cairo',
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Color bg;
  const _InfoChip({
    required this.icon,
    required this.label,
    required this.color,
    required this.bg,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 11,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Form Sheet ───────────────────────────────────────────────────────────
class _CouponFormSheet extends StatefulWidget {
  final CouponEntity? coupon;
  const _CouponFormSheet({this.coupon});

  @override
  State<_CouponFormSheet> createState() => _CouponFormSheetState();
}

class _CouponFormSheetState extends State<_CouponFormSheet> {
  final _codeCtrl = TextEditingController();
  final _valueCtrl = TextEditingController();
  final _minOrderCtrl = TextEditingController();
  final _maxUsesCtrl = TextEditingController();
  CouponDiscountType _discountType = CouponDiscountType.percentage;
  bool _isActive = true;
  bool _hasExpiry = false;
  bool _hasMaxUses = false;
  DateTime? _expiresAt;

  bool get _isEditing => widget.coupon != null;

  @override
  void initState() {
    super.initState();
    final c = widget.coupon;
    if (c != null) {
      _codeCtrl.text = c.code;
      _valueCtrl.text = c.discountValue.toString();
      _minOrderCtrl.text = c.minOrderAmount.toString();
      _discountType = c.discountType;
      _isActive = c.isActive;
      _expiresAt = c.expiresAt;
      _hasExpiry = c.expiresAt != null;
      _hasMaxUses = c.maxUses != null;
      if (c.maxUses != null) _maxUsesCtrl.text = c.maxUses.toString();
    }
  }

  @override
  void dispose() {
    _codeCtrl.dispose();
    _valueCtrl.dispose();
    _minOrderCtrl.dispose();
    _maxUsesCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    final code = _codeCtrl.text.trim().toUpperCase();
    if (code.isEmpty) {
      rootScaffoldMessengerKey.currentState?.showSnackBar(
        const SnackBar(content: Text('أدخل كود الكوبون')),
      );
      return;
    }
    final value = int.tryParse(_valueCtrl.text);
    if (value == null || value <= 0) {
      rootScaffoldMessengerKey.currentState?.showSnackBar(
        const SnackBar(content: Text('أدخل قيمة الخصم')),
      );
      return;
    }
    final minOrder = int.tryParse(_minOrderCtrl.text) ?? 0;
    final maxUses = _hasMaxUses ? int.tryParse(_maxUsesCtrl.text) : null;

    final coupon = CouponModel(
      id: widget.coupon?.id ?? '',
      code: code,
      discountType: _discountType,
      discountValue: value,
      minOrderAmount: minOrder,
      maxUses: maxUses,
      isActive: _isActive,
      expiresAt: _hasExpiry ? _expiresAt : null,
      createdAt: widget.coupon?.createdAt ?? DateTime.now(),
      usageCount: widget.coupon?.usageCount ?? 0,
    );

    final cubit = context.read<CouponsCubit>();
    if (_isEditing) {
      cubit.update(coupon);
    } else {
      cubit.add(coupon);
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _expiresAt ?? DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 3)),
      locale: const Locale('ar'),
    );
    if (picked != null) setState(() => _expiresAt = picked);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CouponsCubit, CouponsState>(
      listenWhen: (p, c) => p.mutationStatus != c.mutationStatus,
      listener: (context, state) {
        if (state.mutationStatus == CouponMutationStatus.success) {
          Navigator.of(context).pop();
        } else if (state.mutationStatus == CouponMutationStatus.error) {
          rootScaffoldMessengerKey.currentState?.showSnackBar(
            SnackBar(
              content: Text(state.mutationError ?? 'حدث خطأ'),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
              margin: const EdgeInsets.all(16),
            ),
          );
          context.read<CouponsCubit>().resetMutation();
        }
      },
      builder: (context, state) {
        final isSaving = state.mutationStatus == CouponMutationStatus.saving;

        return Container(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.hairline,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  _isEditing ? 'تعديل الكوبون' : 'كوبون جديد',
                  style: AppTextStyles.headlineSmall,
                ),
                const SizedBox(height: 20),

                // الكود
                TextFormField(
                  controller: _codeCtrl,
                  enabled: !isSaving && !_isEditing,
                  textDirection: TextDirection.ltr,
                  textCapitalization: TextCapitalization.characters,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.5,
                  ),
                  decoration: InputDecoration(
                    labelText: 'كود الكوبون',
                    hintText: 'SAVE20',
                    suffixIcon: !_isEditing
                        ? IconButton(
                            icon: const Icon(
                              Icons.auto_fix_high_outlined,
                              color: AppColors.jade,
                            ),
                            tooltip: 'توليد كود تلقائي',
                            onPressed: () {
                              final random = DateTime.now()
                                  .millisecondsSinceEpoch
                                  .toString()
                                  .substring(7);
                              _codeCtrl.text = 'CODE$random';
                            },
                          )
                        : null,
                  ),
                ),
                const SizedBox(height: 14),

                // نوع الخصم
                Row(
                  children: [
                    Text('نوع الخصم:', style: AppTextStyles.bodyMuted),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SegmentedButton<CouponDiscountType>(
                        segments: const [
                          ButtonSegment(
                            value: CouponDiscountType.percentage,
                            label: Text('نسبة %'),
                          ),
                          ButtonSegment(
                            value: CouponDiscountType.fixed,
                            label: Text('مبلغ ثابت'),
                          ),
                        ],
                        selected: {_discountType},
                        onSelectionChanged: isSaving
                            ? null
                            : (s) => setState(() => _discountType = s.first),
                        style: ButtonStyle(
                          textStyle: WidgetStateProperty.all(
                            const TextStyle(fontFamily: 'Cairo', fontSize: 12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // قيمة الخصم + الحد الأدنى
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _valueCtrl,
                        enabled: !isSaving,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText:
                              _discountType == CouponDiscountType.percentage
                              ? 'النسبة (%)'
                              : 'المبلغ (ل.س)',
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _minOrderCtrl,
                        enabled: !isSaving,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'حد أدنى للطلب (ل.س)',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // حد الاستخدامات
                SwitchListTile(
                  value: _hasMaxUses,
                  onChanged: isSaving
                      ? null
                      : (v) => setState(() => _hasMaxUses = v),
                  title: const Text(
                    'تحديد عدد الاستخدامات',
                    style: TextStyle(fontFamily: 'Cairo', fontSize: 14),
                  ),
                  activeColor: AppColors.jade,
                  contentPadding: EdgeInsets.zero,
                ),
                if (_hasMaxUses) ...[
                  TextFormField(
                    controller: _maxUsesCtrl,
                    enabled: !isSaving,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'عدد الاستخدامات',
                    ),
                  ),
                  const SizedBox(height: 14),
                ],

                // تاريخ الانتهاء
                SwitchListTile(
                  value: _hasExpiry,
                  onChanged: isSaving
                      ? null
                      : (v) => setState(() => _hasExpiry = v),
                  title: const Text(
                    'تحديد تاريخ انتهاء',
                    style: TextStyle(fontFamily: 'Cairo', fontSize: 14),
                  ),
                  activeColor: AppColors.jade,
                  contentPadding: EdgeInsets.zero,
                ),
                if (_hasExpiry) ...[
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      _expiresAt != null
                          ? 'ينتهي: ${_expiresAt!.day}/${_expiresAt!.month}/${_expiresAt!.year}'
                          : 'اختر تاريخ الانتهاء',
                      style: AppTextStyles.bodyLarge,
                    ),
                    trailing: const Icon(
                      Icons.calendar_today_outlined,
                      color: AppColors.jade,
                    ),
                    onTap: isSaving ? null : _pickDate,
                  ),
                ],

                // نشط
                SwitchListTile(
                  value: _isActive,
                  onChanged: isSaving
                      ? null
                      : (v) => setState(() => _isActive = v),
                  title: const Text(
                    'الكوبون فعّال',
                    style: TextStyle(fontFamily: 'Cairo', fontSize: 14),
                  ),
                  activeColor: AppColors.jade,
                  contentPadding: EdgeInsets.zero,
                ),
                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: isSaving ? null : _submit,
                    child: isSaving
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(_isEditing ? 'حفظ التعديلات' : 'إضافة الكوبون'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
