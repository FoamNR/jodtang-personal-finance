import 'dart:convert';
import 'dart:io';
import 'package:archive/archive_io.dart';
import 'package:csv/csv.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../domain/models/transaction_item.dart';
import 'database_service.dart';
import 'receipt_storage_service.dart';

class BackupExportService {
  final DatabaseService _databaseService;
  final ReceiptStorageService _receiptStorageService;

  BackupExportService({
    DatabaseService? databaseService,
    ReceiptStorageService? receiptStorageService,
  })  : _databaseService = databaseService ?? DatabaseService(),
        _receiptStorageService = receiptStorageService ?? ReceiptStorageService();

  /// Export transactions to CSV with UTF-8 BOM (for Excel Thai support)
  Future<String> exportTransactionsCsv({
    required List<TransactionItem> transactions,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final rows = <List<dynamic>>[];

    // CSV Header in Thai
    rows.add([
      'รหัสรายการ',
      'ประเภท',
      'วันที่และเวลา',
      'จำนวนเงิน (บาท)',
      'กระเป๋าเงิน',
      'โอนไปยังกระเป๋า',
      'หมวดหมู่',
      'บันทึกช่วยจำ',
      'แนบรูปสลิป',
    ]);

    final dateFormat = DateFormat('yyyy-MM-dd HH:mm');

    for (var tx in transactions) {
      rows.add([
        tx.id ?? '',
        tx.type.labelTh,
        dateFormat.format(tx.date),
        tx.amount.toStringAsFixed(2),
        tx.walletName ?? '',
        tx.toWalletName ?? '',
        tx.categoryName ?? '',
        tx.note ?? '',
        (tx.receiptImagePath != null && tx.receiptImagePath!.isNotEmpty) ? 'มี' : 'ไม่มี',
      ]);
    }

    final fullCsvContent = const CsvEncoder(addBom: true).convert(rows);

    final tempDir = await getTemporaryDirectory();
    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final file = File(p.join(tempDir.path, 'jod_tang_export_$timestamp.csv'));
    await file.writeAsBytes(utf8.encode(fullCsvContent));

    return file.path;
  }

  /// Create full backup zip (.db + slips folder)
  Future<String> createZipBackup() async {
    final dbPath = await _databaseService.getDatabaseFilePath();
    final dbFile = File(dbPath);
    if (!await dbFile.exists()) {
      throw Exception('ไม่พบไฟล์ฐานข้อมูล');
    }

    final archive = Archive();

    // 1. Add database file to archive
    final dbBytes = await dbFile.readAsBytes();
    archive.addFile(ArchiveFile(DatabaseService.dbName, dbBytes.length, dbBytes));

    // 2. Add slips files to archive
    final slipsDir = await _receiptStorageService.getSlipsDirectory();
    if (await slipsDir.exists()) {
      final list = slipsDir.listSync();
      for (var entity in list) {
        if (entity is File) {
          final fileName = p.basename(entity.path);
          final bytes = await entity.readAsBytes();
          archive.addFile(ArchiveFile('slips/$fileName', bytes.length, bytes));
        }
      }
    }

    // Encode to zip
    final zipEncoder = ZipEncoder();
    final zipData = zipEncoder.encode(archive);

    final tempDir = await getTemporaryDirectory();
    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final zipFilePath = p.join(tempDir.path, 'jod_tang_backup_$timestamp.zip');
    final zipFile = File(zipFilePath);
    await zipFile.writeAsBytes(zipData);

    return zipFilePath;
  }

  /// Share a backup file or csv
  Future<void> shareFile(String filePath, String subject) async {
    final xFile = XFile(filePath);
    await Share.shareXFiles([xFile], text: subject);
  }

  /// Restore from Zip backup
  Future<bool> restoreFromZip(File zipFile) async {
    try {
      final bytes = await zipFile.readAsBytes();
      final archive = ZipDecoder().decodeBytes(bytes);

      // Close current db connection
      await _databaseService.closeDatabase();

      final dbPath = await _databaseService.getDatabaseFilePath();
      final slipsDir = await _receiptStorageService.getSlipsDirectory();

      for (var file in archive) {
        if (file.isFile) {
          final filename = file.name;
          if (filename == DatabaseService.dbName) {
            final targetDb = File(dbPath);
            await targetDb.writeAsBytes(file.content as List<int>);
          } else if (filename.startsWith('slips/')) {
            final cleanName = p.basename(filename);
            final targetSlip = File(p.join(slipsDir.path, cleanName));
            await targetSlip.writeAsBytes(file.content as List<int>);
          }
        }
      }

      // Reinitialize database
      await _databaseService.database;
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Reset all data and delete all receipt images
  Future<void> resetAll() async {
    await _databaseService.resetAllData();
    await _receiptStorageService.clearAllReceipts();
  }
}
