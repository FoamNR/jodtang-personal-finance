import 'package:sqflite/sqflite.dart';
import '../../domain/models/wallet.dart';
import '../services/database_service.dart';

class WalletRepository {
  final DatabaseService _databaseService;

  WalletRepository({DatabaseService? databaseService})
      : _databaseService = databaseService ?? DatabaseService();

  Future<List<Wallet>> getAllWallets({bool includeArchived = false}) async {
    final db = await _databaseService.database;
    final where = includeArchived ? null : 'is_archived = 0';
    final maps = await db.query('wallets', where: where, orderBy: 'id ASC');

    final wallets = <Wallet>[];
    for (var map in maps) {
      final walletId = map['id'] as int;
      final initialBalance = (map['initial_balance'] as num).toDouble();
      final currentBalance = await calculateWalletBalance(walletId, initialBalance, db);

      wallets.add(Wallet(
        id: walletId,
        name: map['name'] as String,
        initialBalance: initialBalance,
        currentBalance: currentBalance,
        colorValue: map['color_value'] as int,
        iconCodePoint: map['icon_code_point'] as int,
        isArchived: (map['is_archived'] as int) == 1,
      ));
    }
    return wallets;
  }

  Future<double> calculateWalletBalance(int walletId, double initialBalance, [Database? dbInstance]) async {
    final db = dbInstance ?? await _databaseService.database;

    // Income
    final incomeResult = await db.rawQuery('''
      SELECT SUM(amount) as total FROM transactions
      WHERE wallet_id = ? AND type = 'income'
    ''', [walletId]);
    final income = (incomeResult.first['total'] as num?)?.toDouble() ?? 0.0;

    // Expense
    final expenseResult = await db.rawQuery('''
      SELECT SUM(amount) as total FROM transactions
      WHERE wallet_id = ? AND type = 'expense'
    ''', [walletId]);
    final expense = (expenseResult.first['total'] as num?)?.toDouble() ?? 0.0;

    // Transfer in (to_wallet_id = this wallet)
    final transferInResult = await db.rawQuery('''
      SELECT SUM(amount) as total FROM transactions
      WHERE to_wallet_id = ? AND type = 'transfer'
    ''', [walletId]);
    final transferIn = (transferInResult.first['total'] as num?)?.toDouble() ?? 0.0;

    // Transfer out (wallet_id = this wallet and type = 'transfer')
    final transferOutResult = await db.rawQuery('''
      SELECT SUM(amount) as total FROM transactions
      WHERE wallet_id = ? AND type = 'transfer'
    ''', [walletId]);
    final transferOut = (transferOutResult.first['total'] as num?)?.toDouble() ?? 0.0;

    return initialBalance + income - expense + transferIn - transferOut;
  }

  Future<int> addWallet(Wallet wallet) async {
    final db = await _databaseService.database;
    return await db.insert('wallets', {
      'name': wallet.name,
      'initial_balance': wallet.initialBalance,
      'color_value': wallet.colorValue,
      'icon_code_point': wallet.iconCodePoint,
      'is_archived': wallet.isArchived ? 1 : 0,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  Future<int> updateWallet(Wallet wallet) async {
    final db = await _databaseService.database;
    return await db.update(
      'wallets',
      {
        'name': wallet.name,
        'initial_balance': wallet.initialBalance,
        'color_value': wallet.colorValue,
        'icon_code_point': wallet.iconCodePoint,
        'is_archived': wallet.isArchived ? 1 : 0,
      },
      where: 'id = ?',
      whereArgs: [wallet.id],
    );
  }

  Future<int> deleteWallet(int id) async {
    final db = await _databaseService.database;
    return await db.delete('wallets', where: 'id = ?', whereArgs: [id]);
  }
}
