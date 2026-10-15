import 'package:flutter/foundation.dart';
import '../../../../data/repositories/transaction_repository.dart';
import '../../../../domain/models/dashboard_summary.dart';

class AnalyticsViewModel extends ChangeNotifier {
  final TransactionRepository _transactionRepository;

  AnalyticsViewModel({TransactionRepository? transactionRepository})
      : _transactionRepository = transactionRepository ?? TransactionRepository();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  DateTime _selectedDate = DateTime.now();
  DateTime get selectedDate => _selectedDate;

  DashboardSummary _summary = const DashboardSummary();
  DashboardSummary get summary => _summary;

  Future<void> init() async {
    await loadData();
  }

  Future<void> loadData() async {
    _isLoading = true;
    notifyListeners();

    try {
      final startOfMonth = DateTime(_selectedDate.year, _selectedDate.month, 1);
      final nextMonth = DateTime(_selectedDate.year, _selectedDate.month + 1, 1);
      final endOfMonth = nextMonth.subtract(const Duration(milliseconds: 1));

      _summary = await _transactionRepository.getDashboardSummary(
        startDate: startOfMonth,
        endDate: endOfMonth,
      );
    } catch (e) {
      debugPrint('Error loading analytics: $e');
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
