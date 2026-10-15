import 'transaction_item.dart';

enum RecurringFrequency {
  daily,
  weekly,
  monthly,
  yearly;

  String get labelTh {
    switch (this) {
      case RecurringFrequency.daily:
        return 'ทุกวัน';
      case RecurringFrequency.weekly:
        return 'ทุกสัปดาห์';
      case RecurringFrequency.monthly:
        return 'ทุกเดือน';
      case RecurringFrequency.yearly:
        return 'ทุกปี';
    }
  }

  DateTime calculateNextDate(DateTime currentDate) {
    switch (this) {
      case RecurringFrequency.daily:
        return currentDate.add(const Duration(days: 1));
      case RecurringFrequency.weekly:
        return currentDate.add(const Duration(days: 7));
      case RecurringFrequency.monthly:
        return DateTime(
          currentDate.year,
          currentDate.month + 1,
          currentDate.day,
          currentDate.hour,
          currentDate.minute,
        );
      case RecurringFrequency.yearly:
        return DateTime(
          currentDate.year + 1,
          currentDate.month,
          currentDate.day,
          currentDate.hour,
          currentDate.minute,
        );
    }
  }
}

class RecurringRule {
  final int? id;
  final String name;
  final TransactionType type;
  final double amount;
  final int walletId;
  final int? toWalletId;
  final int? categoryId;
  final RecurringFrequency frequency;
  final DateTime startDate;
  final DateTime? endDate;
  final DateTime nextDueDate;
  final bool isActive;
  final String? note;

  // Joined display attributes
  final String? walletName;
  final String? categoryName;
  final int? categoryColor;
  final int? categoryIcon;

  const RecurringRule({
    this.id,
    required this.name,
    required this.type,
    required this.amount,
    required this.walletId,
    this.toWalletId,
    this.categoryId,
    required this.frequency,
    required this.startDate,
    this.endDate,
    required this.nextDueDate,
    this.isActive = true,
    this.note,
    this.walletName,
    this.categoryName,
    this.categoryColor,
    this.categoryIcon,
  });

  RecurringRule copyWith({
    int? id,
    String? name,
    TransactionType? type,
    double? amount,
    int? walletId,
    int? toWalletId,
    int? categoryId,
    RecurringFrequency? frequency,
    DateTime? startDate,
    DateTime? endDate,
    DateTime? nextDueDate,
    bool? isActive,
    String? note,
    String? walletName,
    String? categoryName,
    int? categoryColor,
    int? categoryIcon,
  }) {
    return RecurringRule(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      walletId: walletId ?? this.walletId,
      toWalletId: toWalletId ?? this.toWalletId,
      categoryId: categoryId ?? this.categoryId,
      frequency: frequency ?? this.frequency,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      nextDueDate: nextDueDate ?? this.nextDueDate,
      isActive: isActive ?? this.isActive,
      note: note ?? this.note,
      walletName: walletName ?? this.walletName,
      categoryName: categoryName ?? this.categoryName,
      categoryColor: categoryColor ?? this.categoryColor,
      categoryIcon: categoryIcon ?? this.categoryIcon,
    );
  }
}
