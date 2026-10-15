import 'package:flutter/foundation.dart';
import '../../../../data/repositories/recurring_repository.dart';
import '../../../../domain/models/recurring_rule.dart';

class RecurringViewModel extends ChangeNotifier {
  final RecurringRepository _recurringRepository;

  RecurringViewModel({RecurringRepository? recurringRepository})
      : _recurringRepository = recurringRepository ?? RecurringRepository();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<RecurringRule> _rules = [];
  List<RecurringRule> get rules => _rules;

  Future<void> loadRules() async {
    _isLoading = true;
    notifyListeners();

    try {
      _rules = await _recurringRepository.getAllRecurringRules();
    } catch (e) {
      debugPrint('Error loading recurring rules: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> saveRule(RecurringRule rule) async {
    if (rule.id == null) {
      await _recurringRepository.addRecurringRule(rule);
    } else {
      await _recurringRepository.updateRecurringRule(rule);
    }
    await loadRules();
  }

  Future<void> toggleActive(RecurringRule rule, bool active) async {
    final updated = rule.copyWith(isActive: active);
    await _recurringRepository.updateRecurringRule(updated);
    await loadRules();
  }

  Future<void> deleteRule(int id) async {
    await _recurringRepository.deleteRecurringRule(id);
    await loadRules();
  }

  Future<int> executeDueRulesNow() async {
    final count = await _recurringRepository.checkAndExecuteDueRules();
    await loadRules();
    return count;
  }
}
