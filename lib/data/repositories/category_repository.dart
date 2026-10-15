import '../../domain/models/category_item.dart';
import '../services/database_service.dart';

class CategoryRepository {
  final DatabaseService _databaseService;

  CategoryRepository({DatabaseService? databaseService})
      : _databaseService = databaseService ?? DatabaseService();

  Future<List<CategoryItem>> getAllCategories({CategoryType? type}) async {
    final db = await _databaseService.database;
    final where = type != null ? 'type = ?' : null;
    final whereArgs = type != null ? [type.name] : null;

    final maps = await db.query(
      'categories',
      where: where,
      whereArgs: whereArgs,
      orderBy: 'is_default DESC, id ASC',
    );

    return maps.map((map) {
      return CategoryItem(
        id: map['id'] as int,
        name: map['name'] as String,
        type: map['type'] == 'income' ? CategoryType.income : CategoryType.expense,
        colorValue: map['color_value'] as int,
        iconCodePoint: map['icon_code_point'] as int,
        isDefault: (map['is_default'] as int) == 1,
      );
    }).toList();
  }

  Future<int> addCategory(CategoryItem category) async {
    final db = await _databaseService.database;
    return await db.insert('categories', {
      'name': category.name,
      'type': category.type.name,
      'color_value': category.colorValue,
      'icon_code_point': category.iconCodePoint,
      'is_default': category.isDefault ? 1 : 0,
    });
  }

  Future<int> updateCategory(CategoryItem category) async {
    final db = await _databaseService.database;
    return await db.update(
      'categories',
      {
        'name': category.name,
        'color_value': category.colorValue,
        'icon_code_point': category.iconCodePoint,
      },
      where: 'id = ?',
      whereArgs: [category.id],
    );
  }

  Future<int> deleteCategory(int id) async {
    final db = await _databaseService.database;
    return await db.delete('categories', where: 'id = ?', whereArgs: [id]);
  }
}
