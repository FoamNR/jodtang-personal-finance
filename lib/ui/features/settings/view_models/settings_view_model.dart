import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import '../../../../data/repositories/transaction_repository.dart';
import '../../../../data/services/backup_export_service.dart';
import '../../../../data/services/security_service.dart';

class SettingsViewModel extends ChangeNotifier {
  final SecurityService _securityService;
  final BackupExportService _backupService;
  final TransactionRepository _transactionRepository;

  SettingsViewModel({
    SecurityService? securityService,
    BackupExportService? backupService,
    TransactionRepository? transactionRepository,
  })  : _securityService = securityService ?? SecurityService(),
        _backupService = backupService ?? BackupExportService(),
        _transactionRepository = transactionRepository ?? TransactionRepository();

  bool _isPinEnabled = false;
  bool get isPinEnabled => _isPinEnabled;

  bool _isBiometricEnabled = false;
  bool get isBiometricEnabled => _isBiometricEnabled;

  bool _canCheckBiometrics = false;
  bool get canCheckBiometrics => _canCheckBiometrics;

  bool _isProcessing = false;
  bool get isProcessing => _isProcessing;

  Future<void> init() async {
    _isPinEnabled = await _securityService.isPinEnabled();
    _isBiometricEnabled = await _securityService.isBiometricEnabled();
    _canCheckBiometrics = await _securityService.canCheckBiometrics();
    notifyListeners();
  }

  Future<void> disablePin() async {
    await _securityService.disablePin();
    _isPinEnabled = false;
    _isBiometricEnabled = false;
    notifyListeners();
  }

  Future<void> setBiometrics(bool enabled) async {
    await _securityService.setBiometricEnabled(enabled);
    _isBiometricEnabled = enabled;
    notifyListeners();
  }

  Future<String> exportCsv() async {
    _isProcessing = true;
    notifyListeners();

    try {
      final transactions = await _transactionRepository.getTransactions();
      final path = await _backupService.exportTransactionsCsv(transactions: transactions);
      await _backupService.shareFile(path, 'รายงานประวัติรายการ จดตัง (CSV)');
      return path;
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }

  Future<String> backupFullZip() async {
    _isProcessing = true;
    notifyListeners();

    try {
      final zipPath = await _backupService.createZipBackup();
      await _backupService.shareFile(zipPath, 'ไฟล์สำรองข้อมูล จดตัง (ZIP)');
      return zipPath;
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }

  Future<bool> restoreFromZip() async {
    final files = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['zip'],
    );

    if (files.isNotEmpty && files.first.path != null) {
      _isProcessing = true;
      notifyListeners();

      try {
        final file = File(files.first.path!);
        final success = await _backupService.restoreFromZip(file);
        return success;
      } finally {
        _isProcessing = false;
        notifyListeners();
      }
    }
    return false;
  }

  Future<void> resetAll() async {
    _isProcessing = true;
    notifyListeners();

    try {
      await _backupService.resetAll();
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }
}
