// lib/features/categories/presentation/screens/categories_screen.dart
import 'dart:io';
import 'package:dukan_admin/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/category_entity.dart';
import '../cubit/categories_cubit.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<CategoriesCubit>()..load(),
      child: const _CategoriesView(),
    );
  }
}

class _CategoriesView extends StatelessWidget {
  const _CategoriesView();

  void _openForm(BuildContext context, {CategoryEntity? category}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) => BlocProvider.value(
        value: context.read<CategoriesCubit>(),
        child: _CategoryFormSheet(category: category),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(title: const Text('التصنيفات')),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'fab_categories',
        onPressed: () => _openForm(context),
        backgroundColor: AppColors.jade,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'تصنيف جديد',
          style: TextStyle(
            fontFamily: 'Cairo',
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: BlocConsumer<CategoriesCubit, CategoriesState>(
        listener: (context, state) {
          if (state.mutationStatus == CategoryMutationStatus.error &&
              state.mutationError != null) {
            rootScaffoldMessengerKey.currentState?.showSnackBar(
              SnackBar(
                content: Text(state.mutationError!),
                backgroundColor: AppColors.error,
              ),
            );
            context.read<CategoriesCubit>().resetMutation();
          }
        },
        builder: (context, state) {
          if (state.status == CategoriesStatus.loading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.jade),
            );
          }
          if (state.status == CategoriesStatus.error) {
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
                    onPressed: () => context.read<CategoriesCubit>().load(),
                    child: const Text('إعادة المحاولة'),
                  ),
                ],
              ),
            );
          }
          if (state.categories.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.category_outlined,
                    size: 56,
                    color: AppColors.hairline,
                  ),
                  const SizedBox(height: 12),
                  Text('لا توجد تصنيفات بعد', style: AppTextStyles.bodyMuted),
                ],
              ),
            );
          }
          return RefreshIndicator(
            color: AppColors.jade,
            onRefresh: () => context.read<CategoriesCubit>().load(),
            child: ReorderableListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
              itemCount: state.categories.length,
              onReorder: (oldIndex, newIndex) {
                // إعادة الترتيب تحدّث sort_order — مبسّط: نعيد تحميل بعد ما نرتّب
              },
              itemBuilder: (context, i) {
                final cat = state.categories[i];
                return _CategoryTile(
                  key: ValueKey(cat.id),
                  category: cat,
                  onEdit: () => _openForm(context, category: cat),
                  onDelete: () => _confirmDelete(context, cat),
                );
              },
            ),
          );
        },
      ),
    );
  }

  void _confirmDelete(BuildContext context, CategoryEntity cat) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('حذف التصنيف'),
        content: Text(
          'هل تريد حذف "${cat.name}"؟\nسيُمنع الحذف لو عليه منتجات.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(dialogCtx).pop();
              context.read<CategoriesCubit>().delete(cat.id);
            },
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  final CategoryEntity category;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _CategoryTile({
    super.key,
    required this.category,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: category.isActive
              ? AppColors.hairline
              : AppColors.error.withOpacity(0.3),
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: SizedBox(
            width: 48,
            height: 48,
            child: category.imageUrl != null
                ? Image.network(
                    category.imageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _placeholder(),
                  )
                : _placeholder(),
          ),
        ),
        title: Text(
          category.name,
          style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w600),
        ),
        subtitle: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: category.isActive
                    ? AppColors.jadeLight
                    : AppColors.errorLight,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                category.isActive ? 'نشط' : 'مخفي',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 11,
                  color: category.isActive ? AppColors.jade : AppColors.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text('ترتيب: ${category.sortOrder}', style: AppTextStyles.caption),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(
                Icons.edit_outlined,
                color: AppColors.jade,
                size: 20,
              ),
              onPressed: onEdit,
            ),
            IconButton(
              icon: const Icon(
                Icons.delete_outline_rounded,
                color: AppColors.error,
                size: 20,
              ),
              onPressed: onDelete,
            ),
            const Icon(
              Icons.drag_handle_rounded,
              color: AppColors.inkMuted,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder() => Container(
    color: AppColors.jadeLight,
    child: const Icon(Icons.category_outlined, color: AppColors.jade, size: 22),
  );
}

// ─── Form Sheet ───────────────────────────────────────────────────────────
class _CategoryFormSheet extends StatefulWidget {
  final CategoryEntity? category;
  const _CategoryFormSheet({this.category});

  @override
  State<_CategoryFormSheet> createState() => _CategoryFormSheetState();
}

class _CategoryFormSheetState extends State<_CategoryFormSheet> {
  late final TextEditingController _nameController;
  late final TextEditingController _sortController;
  late bool _isActive;
  File? _pickedImage;
  final _picker = ImagePicker();

  bool get _isEditing => widget.category != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.category?.name ?? '');
    _sortController = TextEditingController(
      text: widget.category?.sortOrder.toString() ?? '0',
    );
    _isActive = widget.category?.isActive ?? true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _sortController.dispose();
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
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('أدخل اسم التصنيف')));
      return;
    }
    final sortOrder = int.tryParse(_sortController.text) ?? 0;
    final cubit = context.read<CategoriesCubit>();

    if (_isEditing) {
      cubit.update(
        id: widget.category!.id,
        name: name,
        sortOrder: sortOrder,
        isActive: _isActive,
        newImage: _pickedImage,
        existingImageUrl: widget.category!.imageUrl,
      );
    } else {
      cubit.add(name: name, sortOrder: sortOrder, image: _pickedImage);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CategoriesCubit, CategoriesState>(
      listenWhen: (p, c) => p.mutationStatus != c.mutationStatus,
      listener: (context, state) {
        if (state.mutationStatus == CategoryMutationStatus.success) {
          Navigator.of(context).pop();
        } else if (state.mutationStatus == CategoryMutationStatus.error) {
          rootScaffoldMessengerKey.currentState?.showSnackBar(
            SnackBar(
              content: Text(state.mutationError ?? 'حدث خطأ'),
              backgroundColor: AppColors.error,
            ),
          );
          context.read<CategoriesCubit>().resetMutation();
        }
      },
      builder: (context, state) {
        final isSaving = state.mutationStatus == CategoryMutationStatus.saving;
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.hairline,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                _isEditing ? 'تعديل التصنيف' : 'تصنيف جديد',
                style: AppTextStyles.headlineSmall,
              ),
              const SizedBox(height: 20),

              // صورة التصنيف
              GestureDetector(
                onTap: isSaving ? null : _pickImage,
                child: Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    color: AppColors.jadeLight,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.hairline),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: _pickedImage != null
                      ? Image.file(_pickedImage!, fit: BoxFit.cover)
                      : widget.category?.imageUrl != null
                      ? Image.network(
                          widget.category!.imageUrl!,
                          fit: BoxFit.cover,
                        )
                      : const Icon(
                          Icons.add_photo_alternate_outlined,
                          color: AppColors.jade,
                          size: 32,
                        ),
                ),
              ),
              const SizedBox(height: 6),
              Text('اضغط لاختيار صورة', style: AppTextStyles.caption),
              const SizedBox(height: 16),

              TextFormField(
                controller: _nameController,
                enabled: !isSaving,
                decoration: const InputDecoration(labelText: 'اسم التصنيف'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _sortController,
                enabled: !isSaving,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'رقم الترتيب (0 = الأول)',
                ),
              ),
              const SizedBox(height: 12),
              if (_isEditing)
                SwitchListTile(
                  value: _isActive,
                  onChanged: isSaving
                      ? null
                      : (v) => setState(() => _isActive = v),
                  title: Text(
                    'نشط (يظهر للزبائن)',
                    style: AppTextStyles.bodyLarge,
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
                      : Text(_isEditing ? 'حفظ التعديلات' : 'إضافة التصنيف'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
