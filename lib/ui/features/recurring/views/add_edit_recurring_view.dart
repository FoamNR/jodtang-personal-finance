import 'package:flutter/material.dart';
import '../../../core/app_colors.dart';
import '../../../core/icon_helper.dart';
import '../../../core/thai_formatters.dart';
import '../../../../data/repositories/category_repository.dart';
import '../../../../data/repositories/wallet_repository.dart';
import '../../../../domain/models/category_item.dart';
import '../../../../domain/models/recurring_rule.dart';
import '../../../../domain/models/transaction_item.dart';
import '../../../../domain/models/wallet.dart';

class AddEditRecurringView extends StatefulWidget {
  final RecurringRule? ruleToEdit;

  const AddEditRecurringView({super.key, this.ruleToEdit});

  @override
  State<AddEditRecurringView> createState() => _AddEditRecurringViewState();
}

class _AddEditRecurringViewState extends State<AddEditRecurringView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  TransactionType _selectedType = TransactionType.expense;
  RecurringFrequency _selectedFrequency = RecurringFrequency.monthly;
  DateTime _startDate = DateTime.now();
  DateTime? _endDate;
  int? _selectedWalletId;
  int? _selectedToWalletId;
  int? _selectedCategoryId;

  List<Wallet> _wallets = [];
  List<CategoryItem> _categories = [];
  bool _isLoading = true;

  final WalletRepository _walletRepo = WalletRepository();
  final CategoryRepository _categoryRepo = CategoryRepository();

  @override
  void initState() {
    super.initState();
    if (widget.ruleToEdit != null) {
      final r = widget.ruleToEdit!;
      _nameController.text = r.name;
      _amountController.text = r.amount.toStringAsFixed(2);
      _noteController.text = r.note ?? '';
      _selectedType = r.type;
      _selectedFrequency = r.frequency;
      _startDate = r.startDate;
      _endDate = r.endDate;
      _selectedWalletId = r.walletId;
      _selectedToWalletId = r.toWalletId;
      _selectedCategoryId = r.categoryId;
    }
    _loadData();
  }

  Future<void> _loadData() async {
    final wallets = await _walletRepo.getAllWallets();
    final categories = await _categoryRepo.getAllCategories();
    setState(() {
      _wallets = wallets;
      _categories = categories;
      if (_selectedWalletId == null && _wallets.isNotEmpty) {
        _selectedWalletId = _wallets.first.id;
      }
      if (_selectedCategoryId == null && _selectedType != TransactionType.transfer) {
        final matching = _categories.where((c) =>
            _selectedType == TransactionType.expense ? c.type == CategoryType.expense : c.type == CategoryType.income);
        if (matching.isNotEmpty) {
          _selectedCategoryId = matching.first.id;
        }
      }
      _isLoading = false;
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedWalletId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('กรุณาเลือกกระเป๋าเงิน')));
      return;
    }

    final amount = double.tryParse(_amountController.text.replaceAll(',', ''));
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('กรุณาระบุจำนวนเงินที่ถูกต้อง')));
      return;
    }

    final rule = RecurringRule(
      id: widget.ruleToEdit?.id,
      name: _nameController.text.trim(),
      type: _selectedType,
      amount: amount,
      walletId: _selectedWalletId!,
      toWalletId: _selectedType == TransactionType.transfer ? _selectedToWalletId : null,
      categoryId: _selectedType != TransactionType.transfer ? _selectedCategoryId : null,
      frequency: _selectedFrequency,
      startDate: _startDate,
      endDate: _endDate,
      nextDueDate: widget.ruleToEdit?.nextDueDate ?? _startDate,
      isActive: widget.ruleToEdit?.isActive ?? true,
      note: _noteController.text.trim().isEmpty ? null : _noteController.text.trim(),
    );

    Navigator.of(context).pop(rule);
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.ruleToEdit != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'แก้ไขรายการประจำ' : 'สร้างรายการประจำใหม่'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'ชื่อรายการประจำ *',
                        hintText: 'เช่น ค่าอินเทอร์เน็ต, ค่าเช่าหอ, เงินเดือน',
                      ),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) return 'กรุณาระบุชื่อรายการ';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Amount
                    TextFormField(
                      controller: _amountController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'จำนวนเงิน (บาท) *',
                        hintText: '0.00',
                        prefixText: '฿ ',
                      ),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) return 'กรุณาระบุจำนวนเงิน';
                        if (double.tryParse(val.replaceAll(',', '')) == null) return 'ตัวเลขไม่ถูกต้อง';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Frequency Dropdown
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: DropdownButtonFormField<RecurringFrequency>(
                          value: _selectedFrequency,
                          decoration: const InputDecoration(
                            labelText: 'ความถี่ในการเกิดซ้ำ',
                            prefixIcon: Icon(Icons.repeat, color: AppColors.primary),
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            filled: false,
                          ),
                          items: RecurringFrequency.values.map((f) {
                            return DropdownMenuItem(
                              value: f,
                              child: Text(f.labelTh),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) setState(() => _selectedFrequency = val);
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Start Date
                    Card(
                      child: ListTile(
                        leading: const Icon(Icons.play_circle_outline, color: AppColors.primary),
                        title: const Text('วันที่เริ่มต้น'),
                        subtitle: Text(ThaiFormatters.formatThaiDate(_startDate)),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: _startDate,
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          );
                          if (picked != null) {
                            setState(() => _startDate = picked);
                          }
                        },
                      ),
                    ),
                    const SizedBox(height: 8),

                    // End Date (Optional)
                    Card(
                      child: ListTile(
                        leading: const Icon(Icons.stop_circle_outlined, color: Colors.grey),
                        title: const Text('วันที่สิ้นสุด (ถ้ามี)'),
                        subtitle: Text(_endDate != null ? ThaiFormatters.formatThaiDate(_endDate!) : 'ทำซ้ำต่อเนื่องตลอดไป'),
                        trailing: _endDate != null
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () => setState(() => _endDate = null),
                              )
                            : const Icon(Icons.chevron_right),
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: _endDate ?? _startDate.add(const Duration(days: 365)),
                            firstDate: _startDate,
                            lastDate: DateTime(2100),
                          );
                          if (picked != null) {
                            setState(() => _endDate = picked);
                          }
                        },
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Wallet Dropdown
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: DropdownButtonFormField<int>(
                          value: _selectedWalletId,
                          decoration: const InputDecoration(
                            labelText: 'กระเป๋าเงิน',
                            prefixIcon: Icon(Icons.account_balance_wallet_outlined, color: AppColors.primary),
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            filled: false,
                          ),
                          items: _wallets.map((w) {
                            return DropdownMenuItem<int>(
                              value: w.id,
                              child: Text('${w.name} (คงเหลือ ${ThaiFormatters.formatCurrency(w.currentBalance)})'),
                            );
                          }).toList(),
                          onChanged: (val) => setState(() => _selectedWalletId = val),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Category Picker
                    const Text('หมวดหมู่', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _categories.where((c) => c.type == CategoryType.expense).map((c) {
                        final isSelected = _selectedCategoryId == c.id;
                        final color = Color(c.colorValue);
                        final isDark = Theme.of(context).brightness == Brightness.dark;

                        return ChoiceChip(
                          avatar: Icon(IconHelper.getIconData(c.iconCodePoint), size: 16, color: isSelected ? Colors.white : color),
                          label: Text(c.name),
                          selected: isSelected,
                          selectedColor: color,
                          backgroundColor: isDark
                              ? const Color(0xFF1E293B).withValues(alpha: 0.75)
                              : Colors.white.withValues(alpha: 0.75),
                          side: BorderSide(
                            color: isSelected
                                ? Colors.transparent
                                : (isDark
                                    ? Colors.white.withValues(alpha: 0.18)
                                    : Colors.black.withValues(alpha: 0.08)),
                            width: 1.0,
                          ),
                          labelStyle: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          ),
                          onSelected: (selected) {
                            if (selected) setState(() => _selectedCategoryId = c.id);
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),

                    // Note
                    TextFormField(
                      controller: _noteController,
                      decoration: const InputDecoration(
                        labelText: 'บันทึกช่วยจำ (ถ้ามี)',
                        prefixIcon: Icon(Icons.note_alt_outlined),
                      ),
                    ),
                    const SizedBox(height: 32),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _save,
                        child: Text(isEditing ? 'บันทึกการแก้ไข' : 'สร้างรายการประจำ'),
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
    );
  }
}
