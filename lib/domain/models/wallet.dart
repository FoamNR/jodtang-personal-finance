class Wallet {
  final int? id;
  final String name;
  final double initialBalance;
  final double currentBalance;
  final int colorValue;
  final int iconCodePoint;
  final bool isArchived;

  const Wallet({
    this.id,
    required this.name,
    required this.initialBalance,
    this.currentBalance = 0.0,
    required this.colorValue,
    required this.iconCodePoint,
    this.isArchived = false,
  });

  Wallet copyWith({
    int? id,
    String? name,
    double? initialBalance,
    double? currentBalance,
    int? colorValue,
    int? iconCodePoint,
    bool? isArchived,
  }) {
    return Wallet(
      id: id ?? this.id,
      name: name ?? this.name,
      initialBalance: initialBalance ?? this.initialBalance,
      currentBalance: currentBalance ?? this.currentBalance,
      colorValue: colorValue ?? this.colorValue,
      iconCodePoint: iconCodePoint ?? this.iconCodePoint,
      isArchived: isArchived ?? this.isArchived,
    );
  }
}
