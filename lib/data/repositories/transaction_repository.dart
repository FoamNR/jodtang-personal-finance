import '../../domain/models/dashboard_summary.dart';
import '../../domain/models/transaction_item.dart';
import '../services/database_service.dart';

class TransactionRepository {
  final DatabaseService _databaseService;

  TransactionRepository({DatabaseService? databaseService})
      : _databaseService = databaseService ?? DatabaseService();

  Future<List<TransactionItem>> getTransactions({
    DateTime? startDate,
    DateTime? endDate,
    int? walletId,
    int? categoryId,
    TransactionType? type,
    String? searchQuery,
    int? limit,
    int? offset,
  }) async {
    final db = await _databaseService.database;

    final whereClauses = <String>[];
    final whereArgs = <dynamic>[];

    if (startDate != null) {
      whereClauses.add('t.date >= ?');
      whereArgs.add(startDate.toIso8601String());
    }
    if (endDate != null) {
      whereClauses.add('t.date <= ?');
      whereArgs.add(endDate.toIso8601String());
    }
    if (walletId != null) {
      whereClauses.add('(t.wallet_id = ? OR t.to_wallet_id = ?)');
      whereArgs.add(walletId);
      whereArgs.add(walletId);
    }
    if (categoryId != null) {
      whereClauses.add('t.category_id = ?');
      whereArgs.add(categoryId);
    }
    if (type != null) {
      whereClauses.add('t.type = ?');
      whereArgs.add(type.name);
    }
    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      whereClauses.add('t.note LIKE ?');
      whereArgs.add('%${searchQuery.trim()}%');
    }

    final whereString = whereClauses.isNotEmpty ? 'WHERE ${whereClauses.join(' AND ')}' : '';
    final limitString = limit != null ? 'LIMIT $limit OFFSET ${offset ?? 0}' : '';

    final query = '''
      SELECT 
        t.*,
        w.name AS wallet_name,
        tw.name AS to_wallet_name,
        c.name AS category_name,
        c.color_value AS category_color,
        c.icon_code_point AS category_icon
      FROM transactions t
      LEFT JOIN wallets w ON t.wallet_id = w.id
      LEFT JOIN wallets tw ON t.to_wallet_id = tw.id
      LEFT JOIN categories c ON t.category_id = c.id
      $whereString
      ORDER BY t.date DESC, t.id DESC
      $limitString
    ''';

    final result = await db.rawQuery(query, whereArgs);

    return result.map((row) {
      return TransactionItem(
        id: row['id'] as int,
        type: TransactionType.values.byName(row['type'] as String),
        amount: (row['amount'] as num).toDouble(),
        date: DateTime.parse(row['date'] as String),
        walletId: row['wallet_id'] as int,
        toWalletId: row['to_wallet_id'] as int?,
        categoryId: row['category_id'] as int?,
        note: row['note'] as String?,
        receiptImagePath: row['receipt_image_path'] as String?,
        createdAt: DateTime.parse(row['created_at'] as String),
        walletName: row['wallet_name'] as String?,
        toWalletName: row['to_wallet_name'] as String?,
        categoryName: row['category_name'] as String?,
        categoryColor: row['category_color'] as int?,
        categoryIcon: row['category_icon'] as int?,
      );
    }).toList();
  }

  Future<int> addTransaction(TransactionItem tx) async {
    final db = await _databaseService.database;
    return await db.insert('transactions', {
      'type': tx.type.name,
      'amount': tx.amount,
      'date': tx.date.toIso8601String(),
      'wallet_id': tx.walletId,
      'to_wallet_id': tx.toWalletId,
      'category_id': tx.categoryId,
      'note': tx.note,
      'receipt_image_path': tx.receiptImagePath,
      'created_at': tx.createdAt.toIso8601String(),
    });
  }

  Future<int> updateTransaction(TransactionItem tx) async {
    final db = await _databaseService.database;
    return await db.update(
      'transactions',
      {
        'type': tx.type.name,
        'amount': tx.amount,
        'date': tx.date.toIso8601String(),
        'wallet_id': tx.walletId,
        'to_wallet_id': tx.toWalletId,
        'category_id': tx.categoryId,
        'note': tx.note,
        'receipt_image_path': tx.receiptImagePath,
      },
      where: 'id = ?',
      whereArgs: [tx.id],
    );
  }

  Future<int> deleteTransaction(int id) async {
    final db = await _databaseService.database;
    return await db.delete('transactions', where: 'id = ?', whereArgs: [id]);
  }

  Future<DashboardSummary> getDashboardSummary({DateTime? startDate, DateTime? endDate}) async {
    final db = await _databaseService.database;

    final whereClauses = <String>[];
    final whereArgs = <dynamic>[];

    if (startDate != null) {
      whereClauses.add('date >= ?');
      whereArgs.add(startDate.toIso8601String());
    }
    if (endDate != null) {
      whereClauses.add('date <= ?');
      whereArgs.add(endDate.toIso8601String());
    }

    final whereString = whereClauses.isNotEmpty ? 'AND ${whereClauses.join(' AND ')}' : '';

    // Calculate total income for period
    final incomeRes = await db.rawQuery('''
      SELECT SUM(amount) as total FROM transactions
      WHERE type = 'income' $whereString
    ''', whereArgs);
    final totalIncome = (incomeRes.first['total'] as num?)?.toDouble() ?? 0.0;

    // Calculate total expense for period
    final expenseRes = await db.rawQuery('''
      SELECT SUM(amount) as total FROM transactions
      WHERE type = 'expense' $whereString
    ''', whereArgs);
    final totalExpense = (expenseRes.first['total'] as num?)?.toDouble() ?? 0.0;

    // Total balance of all active wallets
    final walletRes = await db.rawQuery('''
      SELECT SUM(initial_balance) as total_initial FROM wallets WHERE is_archived = 0
    ''');
    final totalInitial = (walletRes.first['total_initial'] as num?)?.toDouble() ?? 0.0;

    final allTimeIncomeRes = await db.rawQuery('''
      SELECT SUM(amount) as total FROM transactions WHERE type = 'income'
    ''');
    final allTimeIncome = (allTimeIncomeRes.first['total'] as num?)?.toDouble() ?? 0.0;

    final allTimeExpenseRes = await db.rawQuery('''
      SELECT SUM(amount) as total FROM transactions WHERE type = 'expense'
    ''');
    final allTimeExpense = (allTimeExpenseRes.first['total'] as num?)?.toDouble() ?? 0.0;

    final totalBalance = totalInitial + allTimeIncome - allTimeExpense;

    // Top category expenses
    final categoryExpenses = await getCategoryExpenses(startDate: startDate, endDate: endDate);

    return DashboardSummary(
      totalIncome: totalIncome,
      totalExpense: totalExpense,
      totalBalance: totalBalance,
      topCategoryExpenses: categoryExpenses,
    );
  }

  Future<List<CategorySpending>> getCategoryExpenses({DateTime? startDate, DateTime? endDate}) async {
    final db = await _databaseService.database;

    final whereClauses = <String>["t.type = 'expense'"];
    final whereArgs = <dynamic>[];

    if (startDate != null) {
      whereClauses.add('t.date >= ?');
      whereArgs.add(startDate.toIso8601String());
    }
    if (endDate != null) {
      whereClauses.add('t.date <= ?');
      whereArgs.add(endDate.toIso8601String());
    }

    final whereString = 'WHERE ${whereClauses.join(' AND ')}';

    final query = '''
      SELECT 
        c.id as category_id,
        c.name as category_name,
        c.color_value as color_value,
        c.icon_code_point as icon_code_point,
        SUM(t.amount) as total_amount
      FROM transactions t
      JOIN categories c ON t.category_id = c.id
      $whereString
      GROUP BY c.id
      ORDER BY total_amount DESC
    ''';

    final rows = await db.rawQuery(query, whereArgs);
    final totalAll = rows.fold<double>(0.0, (acc, r) => acc + ((r['total_amount'] as num?)?.toDouble() ?? 0.0));

    return rows.map((r) {
      final amt = (r['total_amount'] as num).toDouble();
      final pct = totalAll > 0 ? (amt / totalAll) * 100 : 0.0;
      return CategorySpending(
        categoryId: r['category_id'] as int,
        categoryName: r['category_name'] as String,
        colorValue: r['color_value'] as int,
        iconCodePoint: r['icon_code_point'] as int,
        totalAmount: amt,
        percentage: pct,
      );
    }).toList();
  }
}
