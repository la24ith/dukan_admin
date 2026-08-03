// lib/features/products/presentation/screens/admin_products_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/format_syp.dart';
import '../../../categories/domain/entities/category_entity.dart';
import '../../../categories/domain/usecases/categories_usecases.dart';
import '../../domain/entities/admin_product_entity.dart';
import '../cubit/admin_products_cubit.dart';
import 'admin_product_form_screen.dart';

class AdminProductsScreen extends StatelessWidget {
  const AdminProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<AdminProductsCubit>()..load(),
      child: const _AdminProductsView(),
    );
  }
}

class _AdminProductsView extends StatefulWidget {
  const _AdminProductsView();

  @override
  State<_AdminProductsView> createState() => _AdminProductsViewState();
}

class _AdminProductsViewState extends State<_AdminProductsView> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  List<CategoryEntity> _categories = [];

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final result = await sl<GetCategories>()();
    result.fold((_) {}, (cats) {
      if (mounted) setState(() => _categories = cats);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openForm(BuildContext ctx, {AdminProductEntity? product}) {
    Navigator.push(
      ctx,
      MaterialPageRoute(
        builder: (_) => AdminProductFormScreen(
          product: product,
          categories: _categories,
          cubit: ctx.read<AdminProductsCubit>(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(title: const Text('المنتجات')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(context),
        backgroundColor: AppColors.jade,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('منتج جديد',
            style: TextStyle(
                fontFamily: 'Cairo',
                color: Colors.white,
                fontWeight: FontWeight.w600)),
      ),
      body: BlocConsumer<AdminProductsCubit, AdminProductsState>(
        listener: (context, state) {
          if (state.mutationStatus == ProductMutationStatus.error &&
              state.mutationError != null) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(state.mutationError!),
                backgroundColor: AppColors.error));
            context.read<AdminProductsCubit>().resetMutation();
          }
        },
        builder: (context, state) {
          return Column(
            children: [
              // Search + Stats bar
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Row(children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      onChanged: (v) =>
                          setState(() => _searchQuery = v.trim()),
                      decoration: InputDecoration(
                        hintText: 'ابحث بالاسم...',
                        prefixIcon: const Icon(Icons.search_rounded,
                            color: AppColors.inkMuted, size: 20),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.close_rounded,
                                    size: 18, color: AppColors.inkMuted),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() => _searchQuery = '');
                                })
                            : null,
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 11, horizontal: 14),
                      ),
                    ),
                  ),
                  if (state.status == AdminProductsStatus.ready) ...[
                    const SizedBox(width: 10),
                    Text('${state.products.length} منتج',
                        style: AppTextStyles.bodyMuted),
                  ],
                ]),
              ),

              // Category Filter
              if (_categories.isNotEmpty)
                SizedBox(
                  height: 40,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      _FilterChip(
                        label: 'الكل',
                        selected: state.selectedCategoryFilter == 'all',
                        onTap: () => context
                            .read<AdminProductsCubit>()
                            .setCategoryFilter('all'),
                      ),
                      ..._categories.map((cat) => _FilterChip(
                            label: cat.name,
                            selected:
                                state.selectedCategoryFilter == cat.id,
                            onTap: () => context
                                .read<AdminProductsCubit>()
                                .setCategoryFilter(cat.id),
                          )),
                    ],
                  ),
                ),
              const SizedBox(height: 8),

              // List
              Expanded(
                child: state.status == AdminProductsStatus.loading
                    ? const Center(
                        child: CircularProgressIndicator(
                            color: AppColors.jade))
                    : state.status == AdminProductsStatus.error
                        ? Center(
                            child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                Text(state.errorMessage ?? 'حدث خطأ',
                                    style: AppTextStyles.bodyMuted),
                                const SizedBox(height: 12),
                                FilledButton(
                                    onPressed: () => context
                                        .read<AdminProductsCubit>()
                                        .load(),
                                    child: const Text('إعادة المحاولة')),
                              ]))
                        : _buildList(context, state),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildList(BuildContext context, AdminProductsState state) {
    final products = _searchQuery.isEmpty
        ? state.products
        : state.products
            .where((p) =>
                p.name.toLowerCase().contains(_searchQuery.toLowerCase()))
            .toList();

    if (products.isEmpty) {
      return Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.inventory_2_outlined,
              size: 56, color: AppColors.hairline),
          const SizedBox(height: 12),
          Text('لا توجد منتجات', style: AppTextStyles.bodyMuted),
        ]),
      );
    }

    return RefreshIndicator(
      color: AppColors.jade,
      onRefresh: () =>
          context.read<AdminProductsCubit>().load(
            categoryId: state.selectedCategoryFilter,
          ),
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
        itemCount: products.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, i) => _AdminProductCard(
          product: products[i],
          onEdit: () => _openForm(context, product: products[i]),
          onDelete: () => _confirmDelete(context, products[i]),
          onAdjustStock: () =>
              _showStockDialog(context, products[i]),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, AdminProductEntity p) {
    showDialog(
      context: context,
      builder: (d) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('حذف المنتج'),
        content: Text('هل تريد حذف "${p.name}"؟'),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(d).pop(),
              child: const Text('إلغاء')),
          FilledButton(
            onPressed: () {
              Navigator.of(d).pop();
              context.read<AdminProductsCubit>().delete(p.id);
            },
            style:
                FilledButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }

  void _showStockDialog(BuildContext context, AdminProductEntity p) {
    final ctrl =
        TextEditingController(text: p.stockQuantity.toString());
    showDialog(
      context: context,
      builder: (d) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('تعديل مخزون "${p.name}"'),
        content: TextField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          decoration:
              const InputDecoration(labelText: 'الكمية الجديدة'),
          autofocus: true,
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(d).pop(),
              child: const Text('إلغاء')),
          FilledButton(
            onPressed: () {
              final qty = int.tryParse(ctrl.text);
              if (qty == null || qty < 0) return;
              Navigator.of(d).pop();
              context
                  .read<AdminProductsCubit>()
                  .adjustStock(productId: p.id, newQuantity: qty);
            },
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip(
      {required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsetsDirectional.only(end: 8),
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color:
              selected ? AppColors.jade : AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: selected ? AppColors.jade : AppColors.hairline),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : AppColors.ink,
          ),
        ),
      ),
    );
  }
}

class _AdminProductCard extends StatelessWidget {
  final AdminProductEntity product;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onAdjustStock;

  const _AdminProductCard({
    required this.product,
    required this.onEdit,
    required this.onDelete,
    required this.onAdjustStock,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: product.isActive
              ? AppColors.hairline
              : AppColors.error.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          // صورة المنتج
          ClipRRect(
            borderRadius: const BorderRadius.horizontal(
                right: Radius.circular(14)),
            child: SizedBox(
              width: 90,
              height: 90,
              child: product.mainImageUrl != null
                  ? Image.network(product.mainImageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _placeholder())
                  : _placeholder(),
            ),
          ),
          // البيانات
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.name,
                      style: AppTextStyles.bodyLarge
                          .copyWith(fontWeight: FontWeight.w600),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Text(product.categoryName,
                      style: AppTextStyles.caption),
                  const SizedBox(height: 4),
                  Row(children: [
                    Text(formatSyp(product.price),
                        style: AppTextStyles.price),
                    const SizedBox(width: 10),
                    _StockBadge(product: product),
                  ]),
                ],
              ),
            ),
          ),
          // Actions
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.edit_outlined,
                    color: AppColors.jade, size: 18),
                onPressed: onEdit,
                tooltip: 'تعديل',
              ),
              IconButton(
                icon: const Icon(Icons.inventory_outlined,
                    color: AppColors.brass, size: 18),
                onPressed: onAdjustStock,
                tooltip: 'تعديل المخزون',
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded,
                    color: AppColors.error, size: 18),
                onPressed: onDelete,
                tooltip: 'حذف',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _placeholder() => Container(
        color: AppColors.jadeLight,
        child: const Icon(Icons.image_outlined,
            color: AppColors.jade, size: 28),
      );
}

class _StockBadge extends StatelessWidget {
  final AdminProductEntity product;
  const _StockBadge({required this.product});

  @override
  Widget build(BuildContext context) {
    Color color;
    Color bg;
    String label;

    if (!product.isActive) {
      color = AppColors.inkMuted;
      bg = AppColors.hairline;
      label = 'مخفي';
    } else if (product.stockQuantity == 0) {
      color = AppColors.error;
      bg = AppColors.errorLight;
      label = 'نفد';
    } else if (product.isLowStock) {
      color = AppColors.brass;
      bg = AppColors.brassLight;
      label = 'متبقي ${product.stockQuantity}';
    } else {
      color = AppColors.jade;
      bg = AppColors.jadeLight;
      label = '${product.stockQuantity} قطعة';
    }

    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
          color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(label,
          style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 11,
              color: color,
              fontWeight: FontWeight.w600)),
    );
  }
}
