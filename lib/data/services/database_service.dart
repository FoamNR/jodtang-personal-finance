import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  static Database? _database;
  static const String dbName = 'jod_tang.db';

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
      // Initialize FFI for desktop
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    final String dbPath = await getDatabaseFilePath();
    return await openDatabase(
      dbPath,
      version: 1,
      onCreate: _onCreate,
      onConfigure: _onConfigure,
    );
  }

  Future<String> getDatabaseFilePath() async {
    if (!kIsWeb && Platform.isWindows) {
      final appDocDir = await getApplicationDocumentsDirectory();
      final dir = Directory(p.join(appDocDir.path, 'JodTang'));
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }
      return p.join(dir.path, dbName);
    } else {
      final databasesPath = await getDatabasesPath();
      return p.join(databasesPath, dbName);
    }
  }

  Future<void> _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  Future<void> _onCreate(Database db, int version) async {
    // 1. Wallets table
    await db.execute('''
      CREATE TABLE wallets (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        initial_balance REAL NOT NULL DEFAULT 0.0,
        color_value INTEGER NOT NULL,
        icon_code_point INTEGER NOT NULL,
        is_archived INTEGER NOT NULL DEFAULT 0,
        created_at TEXT NOT NULL
      )
    ''');

    // 2. Categories table
    await db.execute('''
      CREATE TABLE categories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        type TEXT NOT NULL,
        color_value INTEGER NOT NULL,
        icon_code_point INTEGER NOT NULL,
        is_default INTEGER NOT NULL DEFAULT 0
      )
    ''');

    // 3. Transactions table
    await db.execute('''
      CREATE TABLE transactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        type TEXT NOT NULL,
        amount REAL NOT NULL,
        date TEXT NOT NULL,
        wallet_id INTEGER NOT NULL,
        to_wallet_id INTEGER,
        category_id INTEGER,
        note TEXT,
        receipt_image_path TEXT,
        created_at TEXT NOT NULL,
        FOREIGN KEY (wallet_id) REFERENCES wallets (id) ON DELETE CASCADE,
        FOREIGN KEY (to_wallet_id) REFERENCES wallets (id) ON DELETE SET NULL,
        FOREIGN KEY (category_id) REFERENCES categories (id) ON DELETE SET NULL
      )
    ''');

    // 4. Recurring rules table
    await db.execute('''
      CREATE TABLE recurring_rules (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        type TEXT NOT NULL,
        amount REAL NOT NULL,
        wallet_id INTEGER NOT NULL,
        to_wallet_id INTEGER,
        category_id INTEGER,
        frequency TEXT NOT NULL,
        start_date TEXT NOT NULL,
        end_date TEXT,
        next_due_date TEXT NOT NULL,
        is_active INTEGER NOT NULL DEFAULT 1,
        note TEXT,
        FOREIGN KEY (wallet_id) REFERENCES wallets (id) ON DELETE CASCADE,
        FOREIGN KEY (to_wallet_id) REFERENCES wallets (id) ON DELETE SET NULL,
        FOREIGN KEY (category_id) REFERENCES categories (id) ON DELETE SET NULL
      )
    ''');

    // 5. App settings table
    await db.execute('''
      CREATE TABLE app_settings (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL
      )
    ''');

    // Seed default data
    await _seedDefaultData(db);
  }

  Future<void> _seedDefaultData(Database db) async {
    final nowIso = DateTime.now().toIso8601String();

    // Default Wallets
    await db.insert('wallets', {
      'name': 'เงินสด',
      'initial_balance': 0.0,
      'color_value': Colors.green.value,
      'icon_code_point': Icons.payments_outlined.codePoint,
      'is_archived': 0,
      'created_at': nowIso,
    });

    await db.insert('wallets', {
      'name': 'บัญชีธนาคาร',
      'initial_balance': 0.0,
      'color_value': Colors.blue.value,
      'icon_code_point': Icons.account_balance_outlined.codePoint,
      'is_archived': 0,
      'created_at': nowIso,
    });

    // Default Expense Categories
    final defaultExpenseCategories = [
      {'name': 'อาหารและเครื่องดื่ม', 'color': Colors.orange.value, 'icon': Icons.restaurant.codePoint},
      {'name': 'การเดินทาง', 'color': Colors.blue.value, 'icon': Icons.directions_car.codePoint},
      {'name': 'ช้อปปิ้ง', 'color': Colors.pink.value, 'icon': Icons.shopping_bag_outlined.codePoint},
      {'name': 'ที่อยู่อาศัย & ค่าน้ำไฟ', 'color': Colors.amber.value, 'icon': Icons.home_outlined.codePoint},
      {'name': 'สุขภาพ & การแพทย์', 'color': Colors.red.value, 'icon': Icons.medical_services_outlined.codePoint},
      {'name': 'ความบันเทิง', 'color': Colors.purple.value, 'icon': Icons.movie_outlined.codePoint},
      {'name': 'การศึกษา', 'color': Colors.indigo.value, 'icon': Icons.school_outlined.codePoint},
      {'name': 'อื่นๆ', 'color': Colors.grey.value, 'icon': Icons.more_horiz.codePoint},
    ];

    for (var cat in defaultExpenseCategories) {
      await db.insert('categories', {
        'name': cat['name'],
        'type': 'expense',
        'color_value': cat['color'],
        'icon_code_point': cat['icon'],
        'is_default': 1,
      });
    }

    // Default Income Categories
    final defaultIncomeCategories = [
      {'name': 'เงินเดือน', 'color': Colors.green.value, 'icon': Icons.account_balance_wallet_outlined.codePoint},
      {'name': 'โบนัส', 'color': Colors.amber.value, 'icon': Icons.card_giftcard.codePoint},
      {'name': 'รายได้เสริม / ฟรีแลนซ์', 'color': Colors.teal.value, 'icon': Icons.work_outline.codePoint},
      {'name': 'เงินปันผล / ดอกเบี้ย', 'color': Colors.cyan.value, 'icon': Icons.trending_up.codePoint},
      {'name': 'อื่นๆ', 'color': Colors.grey.value, 'icon': Icons.attach_money.codePoint},
    ];

    for (var cat in defaultIncomeCategories) {
      await db.insert('categories', {
        'name': cat['name'],
        'type': 'income',
        'color_value': cat['color'],
        'icon_code_point': cat['icon'],
        'is_default': 1,
      });
    }
  }

  Future<void> closeDatabase() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }

  Future<void> resetAllData() async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.delete('transactions');
      await txn.delete('recurring_rules');
      await txn.delete('wallets');
      await txn.delete('categories');
      await txn.delete('app_settings');
    });
    await _seedDefaultData(db);
  }
}
