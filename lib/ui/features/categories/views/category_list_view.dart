import 'package:flutter/material.dart';
import '../../../core/app_colors.dart';
import '../../../core/custom_card.dart';
import '../../../core/empty_state.dart';
import '../../../core/icon_helper.dart';
import '../../../../domain/models/category_item.dart';
import '../view_models/category_view_model.dart';
import 'add_edit_category_dialog.dart';

class CategoryListView extends StatefulWidget {
  final CategoryViewModel viewModel;

  const CategoryListView({super.key, required this.viewModel});

  @override
  State<CategoryListView> createState() => _CategoryListViewState();
}

class _CategoryListViewState extends State<CategoryListView> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.viewModel,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('จัดการหมวดหมู่'),
            bottom: TabBar(
              controller: _tabController,
              labelColor: AppColors.primary,
              indicatorColor: AppColors.primary,
              tabs: const [
                Tab(text: 'หมวดหมู่รายจ่าย'),
                Tab(text: 'หมวดหมู่รายรับ'),
              ],
            ),
          ),
          body: widget.viewModel.isLoading
              ? const Center(child: CircularProgressIndicator())
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildCategoryList(widget.viewModel.expenseCategories, CategoryType.expense),
                    _buildCategoryList(widget.viewModel.incomeCategories, CategoryType.income),
                  ],
                ),
          floatingActionButton: FloatingActionButton.extended(
            icon: const Icon(Icons.add),
            label: const Text('เพิ่มหมวดหมู่'),
            onPressed: () => _openAddEditDialog(
              context,
              type: _tabController.index == 0 ? CategoryType.expense : CategoryType.income,
            ),
          ),
        );
      },
    );
  }

  Widget _buildCategoryList(List<CategoryItem> categories, CategoryType type) {
    if (categories.isEmpty) {
      return const EmptyState(
        icon: Icons.category_outlined,
        title: 'ไม่มีหมวดหมู่',
        subtitle: 'กดปุ่มด้านล่างเพื่อเพิ่มหมวดหมู่ใหม่',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(top: 12, bottom: 80, left: 16, right: 16),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final cat = categories[index];
        final color = Color(cat.colorValue);

        return CustomCard(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  IconHelper.getIconData(cat.iconCodePoint),
                  color: color,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      cat.name,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    if (cat.isDefault)
                      const Text(
                        'ค่าเริ่มต้นระบบ',
                        style: TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                  ],
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, size: 20),
                    visualDensity: VisualDensity.compact,
                    onPressed: () => _openAddEditDialog(context, category: cat, type: type),
                  ),
                  if (!cat.isDefault)
                    IconButton(
                      icon: const Icon(Icons.delete_outline, size: 20, color: AppColors.expense),
                      visualDensity: VisualDensity.compact,
                      onPressed: () => _confirmDelete(context, cat),
                    ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _openAddEditDialog(BuildContext context, {CategoryItem? category, required CategoryType type}) async {
    final result = await showDialog<CategoryItem>(
      context: context,
      builder: (_) => AddEditCategoryDialog(categoryToEdit: category, defaultType: type),
    );

    if (result != null) {
      await widget.viewModel.saveCategory(result);
    }
  }

  Future<void> _confirmDelete(BuildContext context, CategoryItem category) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('ยืนยันการลบหมวดหมู่'),
        content: Text('คุณต้องการลบหมวดหมู่ "${category.name}" ใช่หรือไม่?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('ยกเลิก')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.expense),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('ลบหมวดหมู่'),
          ),
        ],
      ),
    );

    if (confirm == true && category.id != null) {
      await widget.viewModel.deleteCategory(category.id!);
    }
  }
}
