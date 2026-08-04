// lib/features/products/presentation/screens/admin_product_form_screen.dart
import 'dart:io';
import 'package:dukan_admin/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../categories/domain/entities/category_entity.dart';
import '../../domain/entities/admin_product_entity.dart';
import '../cubit/admin_products_cubit.dart';

class AdminProductFormScreen extends StatefulWidget {
  final AdminProductEntity? product;
  final List<CategoryEntity> categories;
  final AdminProductsCubit cubit;

  const AdminProductFormScreen({
    super.key,
    this.product,
    required this.categories,
    required this.cubit,
  });

  @override
  State<AdminProductFormScreen> createState() => _AdminProductFormScreenState();
}

class _AdminProductFormScreenState extends State<AdminProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _priceCtrl;
  late final TextEditingController _stockCtrl;
  String? _selectedCategoryId;
  late bool _isActive;
  File? _pickedImage;
  final _picker = ImagePicker();

  bool get _isEditing => widget.product != null;

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    _nameCtrl = TextEditingController(text: p?.name ?? '');
    _descCtrl = TextEditingController(text: p?.description ?? '');
    _priceCtrl = TextEditingController(
      text: p != null ? p.price.toString() : '',
    );
    _stockCtrl = TextEditingController(
      text: p != null ? p.stockQuantity.toString() : '0',
    );
    _selectedCategoryId = p?.categoryId;
    _isActive = p?.isActive ?? true;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _priceCtrl.dispose();
    _stockCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 90,
    );
    if (picked != null) setState(() => _pickedImage = File(picked.path));
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategoryId == null) {
      rootScaffoldMessengerKey.currentState?.showSnackBar(
        const SnackBar(content: Text('اختر التصنيف أولاً')),
      );
      return;
    }

    final name = _nameCtrl.text.trim();
    final desc = _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim();
    final price = int.parse(_priceCtrl.text.replaceAll(',', ''));
    final stock = int.parse(_stockCtrl.text);

    if (_isEditing) {
      widget.cubit.update(
        id: widget.product!.id,
        categoryId: _selectedCategoryId!,
        name: name,
        description: desc,
        price: price,
        stockQuantity: stock,
        isActive: _isActive,
        newMainImage: _pickedImage,
        existingMainImageUrl: widget.product!.mainImageUrl,
      );
    } else {
      widget.cubit.add(
        categoryId: _selectedCategoryId!,
        name: name,
        description: desc,
        price: price,
        stockQuantity: stock,
        mainImage: _pickedImage,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: widget.cubit,
      child: BlocConsumer<AdminProductsCubit, AdminProductsState>(
        listenWhen: (p, c) => p.mutationStatus != c.mutationStatus,
        listener: (context, state) {
          if (state.mutationStatus == ProductMutationStatus.success) {
            Navigator.of(context).pop();
          } else if (state.mutationStatus == ProductMutationStatus.error) {
            rootScaffoldMessengerKey.currentState?.showSnackBar(
              SnackBar(
                content: Text(state.mutationError ?? 'حدث خطأ'),
                backgroundColor: AppColors.error,
              ),
            );
            widget.cubit.resetMutation();
          }
        },
        builder: (context, state) {
          final isSaving = state.mutationStatus == ProductMutationStatus.saving;

          return Scaffold(
            appBar: AppBar(
              title: Text(_isEditing ? 'تعديل المنتج' : 'منتج جديد'),
              actions: [
                TextButton(
                  onPressed: isSaving ? null : _submit,
                  child: isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.jade,
                          ),
                        )
                      : Text(
                          'حفظ',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            color: AppColors.jade,
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                        ),
                ),
              ],
            ),
            body: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  // ─── صورة المنتج ──────────────────────────────────
                  Center(
                    child: GestureDetector(
                      onTap: isSaving ? null : _pickImage,
                      child: Stack(
                        children: [
                          Container(
                            width: 140,
                            height: 140,
                            decoration: BoxDecoration(
                              color: AppColors.jadeLight,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(color: AppColors.hairline),
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: _pickedImage != null
                                ? Image.file(_pickedImage!, fit: BoxFit.cover)
                                : widget.product?.mainImageUrl != null
                                ? Image.network(
                                    widget.product!.mainImageUrl!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) =>
                                        _imagePlaceholder(),
                                  )
                                : _imagePlaceholder(),
                          ),
                          Positioned(
                            bottom: 8,
                            left: 8,
                            child: Container(
                              width: 32,
                              height: 32,
                              decoration: const BoxDecoration(
                                color: AppColors.jade,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.camera_alt_outlined,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ─── التصنيف ──────────────────────────────────────
                  DropdownButtonFormField<String>(
                    value: _selectedCategoryId,
                    decoration: const InputDecoration(labelText: 'التصنيف'),
                    items: widget.categories
                        .map(
                          (cat) => DropdownMenuItem(
                            value: cat.id,
                            child: Text(cat.name),
                          ),
                        )
                        .toList(),
                    onChanged: isSaving
                        ? null
                        : (v) => setState(() => _selectedCategoryId = v),
                    validator: (v) => v == null ? 'اختر التصنيف' : null,
                  ),
                  const SizedBox(height: 14),

                  // ─── الاسم ────────────────────────────────────────
                  TextFormField(
                    controller: _nameCtrl,
                    enabled: !isSaving,
                    decoration: const InputDecoration(labelText: 'اسم المنتج'),
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'أدخل اسم المنتج'
                        : null,
                  ),
                  const SizedBox(height: 14),

                  // ─── الوصف ────────────────────────────────────────
                  TextFormField(
                    controller: _descCtrl,
                    enabled: !isSaving,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'الوصف (اختياري)',
                    ),
                  ),
                  const SizedBox(height: 14),

                  // ─── السعر والمخزون ───────────────────────────────
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _priceCtrl,
                          enabled: !isSaving,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'السعر (ل.س)',
                          ),
                          validator: (v) {
                            if (v == null || v.isEmpty) return 'أدخل السعر';
                            final n = int.tryParse(v.replaceAll(',', ''));
                            if (n == null || n < 0) return 'سعر غير صالح';
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _stockCtrl,
                          enabled: !isSaving,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'الكمية',
                          ),
                          validator: (v) {
                            if (v == null || v.isEmpty) return 'أدخل الكمية';
                            final n = int.tryParse(v);
                            if (n == null || n < 0) return 'كمية غير صالحة';
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // ─── نشط / مخفي ──────────────────────────────────
                  if (_isEditing)
                    SwitchListTile(
                      value: _isActive,
                      onChanged: isSaving
                          ? null
                          : (v) => setState(() => _isActive = v),
                      title: Text(
                        'يظهر للزبائن',
                        style: AppTextStyles.bodyLarge,
                      ),
                      subtitle: Text(
                        _isActive ? 'المنتج نشط' : 'المنتج مخفي',
                        style: AppTextStyles.caption,
                      ),
                      activeColor: AppColors.jade,
                      contentPadding: EdgeInsets.zero,
                    ),

                  const SizedBox(height: 32),

                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: isSaving ? null : _submit,
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: isSaving
                          ? const SizedBox(
                              height: 22,
                              width: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              _isEditing ? 'حفظ التعديلات' : 'إضافة المنتج',
                              style: const TextStyle(fontSize: 15),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _imagePlaceholder() => const Center(
    child: Icon(
      Icons.add_photo_alternate_outlined,
      color: AppColors.jade,
      size: 40,
    ),
  );
}
