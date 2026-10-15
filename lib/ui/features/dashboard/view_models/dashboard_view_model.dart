import 'package:flutter/foundation.dart';
import '../../../../data/repositories/recurring_repository.dart';
import '../../../../data/repositories/transaction_repository.dart';
import '../../../../domain/models/dashboard_summary.dart';
import '../../../../domain/models/transaction_item.dart';

class DashboardViewModel extends ChangeNotifier {
  final TransactionRepository _transactionRepository;
  final RecurringRepository _recurringRepository;

  DashboardViewModel({
    TransactionRepository? transactionRepository,
    RecurringRepository? recurringRepository,
  })  : _transactionRepository = transactionRepository ?? TransactionRepository(),
        _recurringRepository = recurringRepository ?? RecurringRepository();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  DateTime _selectedDate = DateTime.now();
  DateTime get selectedDate => _selectedDate;

  DashboardSummary _summary = const DashboardSummary();
  DashboardSummary get summary => _summary;

  List<TransactionItem> _recentTransactions = [];
  List<TransactionItem> get recentTransactions => _recentTransactions;

  Future<void> init() async {
    // Check and execute due recurring transactions on launch
    try {
      await _recurringRepository.checkAndExecuteDueRules();
    } catch (_) {}
    await loadData();
  }

  Future<void> loadData() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Calculate first and last moment of the selected month
      final startOfMonth = DateTime(_selectedDate.year, _selectedDate.month, 1);
      final nextMonth = DateTime(_selectedDate.year, _selectedDate.month + 1, 1);
      final endOfMonth = nextMonth.subtract(const Duration(milliseconds: 1));

      _summary = await _transactionRepository.getDashboardSummary(
        startDate: startOfMonth,
        endDate: endOfMonth,
      );

      _recentTransactions = await _transactionRepository.getTransactions(
        limit: 10,
      );
    } catch (e) {
      debugPrint('Error loading dashboard: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void changeMonth(int offset) {
    _selectedDate = DateTime(_selectedDate.year, _selectedDate.month + offset, 1);
    loadData();
  }
}
