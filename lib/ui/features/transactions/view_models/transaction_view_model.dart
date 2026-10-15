import 'package:flutter/foundation.dart';
import '../../../../data/repositories/category_repository.dart';
import '../../../../data/repositories/transaction_repository.dart';
import '../../../../data/repositories/wallet_repository.dart';
import '../../../../data/services/receipt_storage_service.dart';
import '../../../../domain/models/category_item.dart';
import '../../../../domain/models/transaction_item.dart';
import '../../../../domain/models/wallet.dart';

class TransactionViewModel extends ChangeNotifier {
  final TransactionRepository _transactionRepository;
  final WalletRepository _walletRepository;
  final CategoryRepository _categoryRepository;
  final ReceiptStorageService _receiptStorageService;

  TransactionViewModel({
    TransactionRepository? transactionRepository,
    WalletRepository? walletRepository,
    CategoryRepository? categoryRepository,
    ReceiptStorageService? receiptStorageService,
  })  : _transactionRepository = transactionRepository ?? TransactionRepository(),
        _walletRepository = walletRepository ?? WalletRepository(),
        _categoryRepository = categoryRepository ?? CategoryRepository(),
        _receiptStorageService = receiptStorageService ?? ReceiptStorageService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<TransactionItem> _transactions = [];
  List<TransactionItem> get transactions => _transactions;

  List<Wallet> _wallets = [];
  List<Wallet> get wallets => _wallets;

  List<CategoryItem> _categories = [];
  List<CategoryItem> get categories => _categories;

  // Filters
  TransactionType? _filterType;
  TransactionType? get filterType => _filterType;

  int? _filterWalletId;
  int? get filterWalletId => _filterWalletId;

  int? _filterCategoryId;
  int? get filterCategoryId => _filterCategoryId;

  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  DateTime? _startDate;
  DateTime? get startDate => _startDate;

  DateTime? _endDate;
  DateTime? get endDate => _endDate;

  Future<void> init() async {
    await loadFilterOptions();
    await loadTransactions();
  }

  Future<void> loadFilterOptions() async {
    try {
      _wallets = await _walletRepository.getAllWallets();
      _categories = await _categoryRepository.getAllCategories();
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading filter options: $e');
    }
  }

  Future<void> loadTransactions() async {
    _isLoading = true;
    notifyListeners();

    try {
      _transactions = await _transactionRepository.getTransactions(
        type: _filterType,
        walletId: _filterWalletId,
        categoryId: _filterCategoryId,
        searchQuery: _searchQuery,
        startDate: _startDate,
        endDate: _endDate,
      );
    } catch (e) {
      debugPrint('Error loading transactions: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setFilterType(TransactionType? type) {
    _filterType = type;
    loadTransactions();
  }

  void setFilterWallet(int? walletId) {
    _filterWalletId = walletId;
    loadTransactions();
  }

  void setFilterCategory(int? categoryId) {
    _filterCategoryId = categoryId;
    loadTransactions();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    loadTransactions();
  }

  void setDateRange(DateTime? start, DateTime? end) {
    _startDate = start;
    _endDate = end;
    loadTransactions();
  }

  void clearFilters() {
    _filterType = null;
    _filterWalletId = null;
    _filterCategoryId = null;
    _searchQuery = '';
    _startDate = null;
    _endDate = null;
    loadTransactions();
  }

  Future<void> deleteTransaction(TransactionItem tx) async {
    if (tx.id != null) {
      if (tx.receiptImagePath != null) {
        await _receiptStorageService.deleteReceiptImage(tx.receiptImagePath);
      }
      await _transactionRepository.deleteTransaction(tx.id!);
      await loadTransactions();
    }
  }
}
