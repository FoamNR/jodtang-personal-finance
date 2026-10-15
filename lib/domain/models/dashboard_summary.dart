class CategorySpending {
  final int categoryId;
  final String categoryName;
  final int colorValue;
  final int iconCodePoint;
  final double totalAmount;
  final double percentage;

  const CategorySpending({
    required this.categoryId,
    required this.categoryName,
    required this.colorValue,
    required this.iconCodePoint,
    required this.totalAmount,
    required this.percentage,
  });
}

class DashboardSummary {
  final double totalIncome;
  final double totalExpense;
  final double totalBalance;
  final List<CategorySpending> topCategoryExpenses;

  const DashboardSummary({
    this.totalIncome = 0.0,
    this.totalExpense = 0.0,
    this.totalBalance = 0.0,
    this.topCategoryExpenses = const [],
  });

  double get netSavings => totalIncome - totalExpense;
}
