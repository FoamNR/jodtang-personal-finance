enum CategoryType {
  expense,
  income;

  String get labelTh {
    switch (this) {
      case CategoryType.expense:
        return 'รายจ่าย';
      case CategoryType.income:
        return 'รายรับ';
    }
  }
}

class CategoryItem {
  final int? id;
  final String name;
  final CategoryType type;
  final int colorValue;
  final int iconCodePoint;
  final bool isDefault;

  const CategoryItem({
    this.id,
    required this.name,
    required this.type,
    required this.colorValue,
    required this.iconCodePoint,
    this.isDefault = false,
  });

  CategoryItem copyWith({
    int? id,
    String? name,
    CategoryType? type,
    int? colorValue,
    int? iconCodePoint,
    bool? isDefault,
  }) {
    return CategoryItem(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      colorValue: colorValue ?? this.colorValue,
      iconCodePoint: iconCodePoint ?? this.iconCodePoint,
      isDefault: isDefault ?? this.isDefault,
    );
  }
}
