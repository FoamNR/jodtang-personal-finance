import '../../domain/models/recurring_rule.dart';
import '../../domain/models/transaction_item.dart';
import '../services/database_service.dart';
import '../services/notification_service.dart';

class RecurringRepository {
  final DatabaseService _databaseService;
  final NotificationService _notificationService;

  RecurringRepository({
    DatabaseService? databaseService,
    NotificationService? notificationService,
  })  : _databaseService = databaseService ?? DatabaseService(),
        _notificationService = notificationService ?? NotificationService();

  Future<List<RecurringRule>> getAllRecurringRules() async {
    final db = await _databaseService.database;

    final query = '''
      SELECT 
        r.*,
        w.name AS wallet_name,
        c.name AS category_name,
        c.color_value AS category_color,
        c.icon_code_point AS category_icon
      FROM recurring_rules r
      LEFT JOIN wallets w ON r.wallet_id = w.id
      LEFT JOIN categories c ON r.category_id = c.id
      ORDER BY r.is_active DESC, r.next_due_date ASC
    ''';

    final result = await db.rawQuery(query);

    return result.map((row) {
      return RecurringRule(
        id: row['id'] as int,
        name: row['name'] as String,
        type: TransactionType.values.byName(row['type'] as String),
        amount: (row['amount'] as num).toDouble(),
        walletId: row['wallet_id'] as int,
        toWalletId: row['to_wallet_id'] as int?,
        categoryId: row['category_id'] as int?,
        frequency: RecurringFrequency.values.byName(row['frequency'] as String),
        startDate: DateTime.parse(row['start_date'] as String),
        endDate: row['end_date'] != null ? DateTime.parse(row['end_date'] as String) : null,
        nextDueDate: DateTime.parse(row['next_due_date'] as String),
        isActive: (row['is_active'] as int) == 1,
        note: row['note'] as String?,
        walletName: row['wallet_name'] as String?,
        categoryName: row['category_name'] as String?,
        categoryColor: row['category_color'] as int?,
        categoryIcon: row['category_icon'] as int?,
      );
    }).toList();
  }

  Future<int> addRecurringRule(RecurringRule rule) async {
    final db = await _databaseService.database;
    return await db.insert('recurring_rules', {
      'name': rule.name,
      'type': rule.type.name,
      'amount': rule.amount,
      'wallet_id': rule.walletId,
      'to_wallet_id': rule.toWalletId,
      'category_id': rule.categoryId,
      'frequency': rule.frequency.name,
      'start_date': rule.startDate.toIso8601String(),
      'end_date': rule.endDate?.toIso8601String(),
      'next_due_date': rule.nextDueDate.toIso8601String(),
      'is_active': rule.isActive ? 1 : 0,
      'note': rule.note,
    });
  }

  Future<int> updateRecurringRule(RecurringRule rule) async {
    final db = await _databaseService.database;
    return await db.update(
      'recurring_rules',
      {
        'name': rule.name,
        'type': rule.type.name,
        'amount': rule.amount,
        'wallet_id': rule.walletId,
        'to_wallet_id': rule.toWalletId,
        'category_id': rule.categoryId,
        'frequency': rule.frequency.name,
        'start_date': rule.startDate.toIso8601String(),
        'end_date': rule.endDate?.toIso8601String(),
        'next_due_date': rule.nextDueDate.toIso8601String(),
        'is_active': rule.isActive ? 1 : 0,
        'note': rule.note,
      },
      where: 'id = ?',
      whereArgs: [rule.id],
    );
  }

  Future<int> deleteRecurringRule(int id) async {
    final db = await _databaseService.database;
    return await db.delete('recurring_rules', where: 'id = ?', whereArgs: [id]);
  }

  /// Checks for any active recurring rules whose nextDueDate is <= now,
  /// automatically creates the corresponding transaction, advances the nextDueDate,
  /// and sends a local notification alert.
  Future<int> checkAndExecuteDueRules() async {
    final db = await _databaseService.database;
    final now = DateTime.now();
    final nowIso = now.toIso8601String();

    final dueRows = await db.query(
      'recurring_rules',
      where: 'is_active = 1 AND next_due_date <= ?',
      whereArgs: [nowIso],
    );

    int executedCount = 0;

    for (var row in dueRows) {
      final rule = RecurringRule(
        id: row['id'] as int,
        name: row['name'] as String,
        type: TransactionType.values.byName(row['type'] as String),
        amount: (row['amount'] as num).toDouble(),
        walletId: row['wallet_id'] as int,
        toWalletId: row['to_wallet_id'] as int?,
        categoryId: row['category_id'] as int?,
        frequency: RecurringFrequency.values.byName(row['frequency'] as String),
        startDate: DateTime.parse(row['start_date'] as String),
        endDate: row['end_date'] != null ? DateTime.parse(row['end_date'] as String) : null,
        nextDueDate: DateTime.parse(row['next_due_date'] as String),
        isActive: (row['is_active'] as int) == 1,
        note: row['note'] as String?,
      );

      // Create transaction
      await db.insert('transactions', {
        'type': rule.type.name,
        'amount': rule.amount,
        'date': rule.nextDueDate.toIso8601String(),
        'wallet_id': rule.walletId,
        'to_wallet_id': rule.toWalletId,
        'category_id': rule.categoryId,
        'note': '[รายการประจำ] ${rule.name}${rule.note != null && rule.note!.isNotEmpty ? ': ${rule.note}' : ''}',
        'receipt_image_path': null,
        'created_at': DateTime.now().toIso8601String(),
      });

      executedCount++;

      // Compute next date
      DateTime nextDate = rule.frequency.calculateNextDate(rule.nextDueDate);
      bool stillActive = true;
      if (rule.endDate != null && nextDate.isAfter(rule.endDate!)) {
        stillActive = false;
      }

      await db.update(
        'recurring_rules',
        {
          'next_due_date': nextDate.toIso8601String(),
          'is_active': stillActive ? 1 : 0,
        },
        where: 'id = ?',
        whereArgs: [rule.id],
      );
    }

    if (executedCount > 0) {
      await _notificationService.showNotification(
        id: 999,
        title: 'จดตัง: บันทึกรายการประจำอัตโนมัติแล้ว',
        body: 'ระบบได้บันทึกรายการประจำตามกำหนดจำนวน $executedCount รายการเรียบร้อยแล้ว',
      );
    }

    return executedCount;
  }
}
