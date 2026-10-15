import 'package:flutter/foundation.dart';
import '../../../../data/repositories/category_repository.dart';
import '../../../../domain/models/category_item.dart';

class CategoryViewModel extends ChangeNotifier {
  final CategoryRepository _categoryRepository;

  CategoryViewModel({CategoryRepository? categoryRepository})
      : _categoryRepository = categoryRepository ?? CategoryRepository();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<CategoryItem> _expenseCategories = [];
  List<CategoryItem> get expenseCategories => _expenseCategories;

  List<CategoryItem> _incomeCategories = [];
  List<CategoryItem> get incomeCategories => _incomeCategories;

  Future<void> loadCategories() async {
    _isLoading = true;
    notifyListeners();

    try {
      _expenseCategories = await _categoryRepository.getAllCategories(type: CategoryType.expense);
      _incomeCategories = await _categoryRepository.getAllCategories(type: CategoryType.income);
    } catch (e) {
      debugPrint('Error loading categories: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> saveCategory(CategoryItem category) async {
    if (category.id == null) {
      await _categoryRepository.addCategory(category);
    } else {
      await _categoryRepository.updateCategory(category);
    }
    await loadCategories();
  }

  Future<void> deleteCategory(int id) async {
    await _categoryRepository.deleteCategory(id);
    await loadCategories();
  }
}
