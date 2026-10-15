enum TransactionType {
  expense,
  income,
  transfer;

  String get labelTh {
    switch (this) {
      case TransactionType.expense:
        return 'รายจ่าย';
      case TransactionType.income:
        return 'รายรับ';
      case TransactionType.transfer:
        return 'โอนเงิน';
    }
  }
}

class TransactionItem {
  final int? id;
  final TransactionType type;
  final double amount;
  final DateTime date;
  final int walletId;
  final int? toWalletId;
  final int? categoryId;
  final String? note;
  final String? receiptImagePath; // Relative path inside app storage
  final DateTime createdAt;

  // Joined presentation data (optional)
  final String? walletName;
  final String? toWalletName;
  final String? categoryName;
  final int? categoryColor;
  final int? categoryIcon;

  const TransactionItem({
    this.id,
    required this.type,
    required this.amount,
    required this.date,
    required this.walletId,
    this.toWalletId,
    this.categoryId,
    this.note,
    this.receiptImagePath,
    required this.createdAt,
    this.walletName,
    this.toWalletName,
    this.categoryName,
    this.categoryColor,
    this.categoryIcon,
  });

  bool get isExpense => type == TransactionType.expense;
  bool get isIncome => type == TransactionType.income;
  bool get isTransfer => type == TransactionType.transfer;

  TransactionItem copyWith({
    int? id,
    TransactionType? type,
    double? amount,
    DateTime? date,
    int? walletId,
    int? toWalletId,
    int? categoryId,
    String? note,
    String? receiptImagePath,
    DateTime? createdAt,
    String? walletName,
    String? toWalletName,
    String? categoryName,
    int? categoryColor,
    int? categoryIcon,
  }) {
    return TransactionItem(
      id: id ?? this.id,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      walletId: walletId ?? this.walletId,
      toWalletId: toWalletId ?? this.toWalletId,
      categoryId: categoryId ?? this.categoryId,
      note: note ?? this.note,
      receiptImagePath: receiptImagePath ?? this.receiptImagePath,
      createdAt: createdAt ?? this.createdAt,
      walletName: walletName ?? this.walletName,
      toWalletName: toWalletName ?? this.toWalletName,
      categoryName: categoryName ?? this.categoryName,
      categoryColor: categoryColor ?? this.categoryColor,
      categoryIcon: categoryIcon ?? this.categoryIcon,
    );
  }
}
