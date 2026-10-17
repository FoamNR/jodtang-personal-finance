import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/app_colors.dart';
import '../../../core/icon_helper.dart';
import '../../../core/thai_formatters.dart';
import '../../../../data/repositories/category_repository.dart';
import '../../../../data/repositories/transaction_repository.dart';
import '../../../../data/repositories/wallet_repository.dart';
import '../../../../data/services/receipt_storage_service.dart';
import '../../../../domain/models/category_item.dart';
import '../../../../domain/models/transaction_item.dart';
import '../../../../domain/models/wallet.dart';
import 'receipt_viewer_dialog.dart';

class AddEditTransactionView extends StatefulWidget {
  final TransactionItem? transactionToEdit;
  final TransactionType initialType;

  const AddEditTransactionView({
    super.key,
    this.transactionToEdit,
    this.initialType = TransactionType.expense,
  });

  @override
  State<AddEditTransactionView> createState() => _AddEditTransactionViewState();
}

class _AddEditTransactionViewState extends State<AddEditTransactionView> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  late TransactionType _selectedType;
  late DateTime _selectedDate;
  int? _selectedWalletId;
  int? _selectedToWalletId;
  int? _selectedCategoryId;
  String? _receiptRelativePath;
  File? _newPickedReceiptFile;

  List<Wallet> _wallets = [];
  List<CategoryItem> _categories = [];
  bool _isLoading = true;
  bool _isSaving = false;

  final WalletRepository _walletRepo = WalletRepository();
  final CategoryRepository _categoryRepo = CategoryRepository();
  final TransactionRepository _transactionRepo = TransactionRepository();
  final ReceiptStorageService _receiptStorage = ReceiptStorageService();
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _selectedType = widget.transactionToEdit?.type ?? widget.initialType;
    _selectedDate = widget.transactionToEdit?.date ?? DateTime.now();

    if (widget.transactionToEdit != null) {
      final tx = widget.transactionToEdit!;
      _amountController.text = tx.amount.toStringAsFixed(2);
      _noteController.text = tx.note ?? '';
      _selectedWalletId = tx.walletId;
      _selectedToWalletId = tx.toWalletId;
      _selectedCategoryId = tx.categoryId;
      _receiptRelativePath = tx.receiptImagePath;
    }

    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final wallets = await _walletRepo.getAllWallets();
    final categories = await _categoryRepo.getAllCategories();

    setState(() {
      _wallets = wallets;
      _categories = categories;
      if (_selectedWalletId == null && _wallets.isNotEmpty) {
        _selectedWalletId = _wallets.first.id;
      }
      if (_selectedType == TransactionType.transfer && _wallets.length > 1) {
        if (_selectedToWalletId == null || _selectedToWalletId == _selectedWalletId) {
          _selectedToWalletId = _wallets.firstWhere((w) => w.id != _selectedWalletId).id;
        }
      }
      if (_selectedCategoryId == null && _selectedType != TransactionType.transfer) {
        final matchingCats = _categories.where((c) =>
            _selectedType == TransactionType.expense ? c.type == CategoryType.expense : c.type == CategoryType.income);
        if (matchingCats.isNotEmpty) {
          _selectedCategoryId = matchingCats.first.id;
        }
      }
      _isLoading = false;
    });
  }

  /// Calculates the effective available balance of a wallet, taking into account
  /// any existing transaction currently being edited.
  double _getAvailableBalance(int? walletId) {
    if (walletId == null) return 0.0;
    final wallet = _wallets.where((w) => w.id == walletId).firstOrNull;
    if (wallet == null) return 0.0;
    double balance = wallet.currentBalance;

    if (widget.transactionToEdit != null) {
      final edit = widget.transactionToEdit!;
      if (edit.type == TransactionType.transfer) {
        if (edit.walletId == walletId) {
          // Source wallet in old tx: funds were deducted, so restore them
          balance += edit.amount;
        }
        if (edit.toWalletId == walletId) {
          // Destination wallet in old tx: funds were added, so revert them
          balance -= edit.amount;
        }
      } else if (edit.type == TransactionType.expense) {
        if (edit.walletId == walletId) {
          balance += edit.amount;
        }
      } else if (edit.type == TransactionType.income) {
        if (edit.walletId == walletId) {
          balance -= edit.amount;
        }
      }
    }
    return balance;
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picked = await _picker.pickImage(source: source, imageQuality: 80);
      if (picked != null) {
        setState(() {
          _newPickedReceiptFile = File(picked.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('ไม่สามารถเลือกรูปได้: $e')),
        );
      }
    }
  }

  Future<void> _selectDateTime() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null && mounted) {
      final pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDate),
      );

      if (pickedTime != null) {
        setState(() {
          _selectedDate = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      } else {
        setState(() {
          _selectedDate = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            _selectedDate.hour,
            _selectedDate.minute,
          );
        });
      }
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedWalletId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('กรุณาเลือกกระเป๋าเงิน')),
      );
      return;
    }

    if (_selectedType == TransactionType.transfer) {
      if (_wallets.length < 2) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('ต้องมีกระเป๋าเงินอย่างน้อย 2 บัญชีเพื่อทำรายการโอน')),
        );
        return;
      }
      if (_selectedToWalletId == null || _selectedToWalletId == _selectedWalletId) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('กรุณาเลือกกระเป๋าเงินปลายทางที่ไม่ซ้ำกัน')),
        );
        return;
      }
    } else {
      if (_selectedCategoryId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('กรุณาเลือกหมวดหมู่')),
        );
        return;
      }
    }

    final amount = double.tryParse(_amountController.text.replaceAll(',', ''));
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('กรุณาระบุจำนวนเงินที่ถูกต้อง')),
      );
      return;
    }

    if (_selectedType == TransactionType.transfer) {
      final availableBalance = _getAvailableBalance(_selectedWalletId!);
      if (amount > availableBalance) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'ยอดเงินในกระเป๋าต้นทางไม่เพียงพอ (คงเหลือ ${ThaiFormatters.formatCurrency(availableBalance)})',
            ),
            backgroundColor: AppColors.expense,
          ),
        );
        return;
      }
    }

    setState(() => _isSaving = true);

    try {
      String? finalSlipPath = _receiptRelativePath;
      if (_newPickedReceiptFile != null) {
        // If there was an old slip, delete it
        if (_receiptRelativePath != null) {
          await _receiptStorage.deleteReceiptImage(_receiptRelativePath);
        }
        finalSlipPath = await _receiptStorage.saveReceiptImage(_newPickedReceiptFile!);
      }

      final item = TransactionItem(
        id: widget.transactionToEdit?.id,
        type: _selectedType,
        amount: amount,
        date: _selectedDate,
        walletId: _selectedWalletId!,
        toWalletId: _selectedType == TransactionType.transfer ? _selectedToWalletId : null,
        categoryId: _selectedType != TransactionType.transfer ? _selectedCategoryId : null,
        note: _noteController.text.trim().isEmpty ? null : _noteController.text.trim(),
        receiptImagePath: finalSlipPath,
        createdAt: widget.transactionToEdit?.createdAt ?? DateTime.now(),
      );

      if (widget.transactionToEdit == null) {
        await _transactionRepo.addTransaction(item);
      } else {
        await _transactionRepo.updateTransaction(item);
      }

      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('เกิดข้อผิดพลาดในการบันทึก: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _delete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('ยืนยันการลบ'),
        content: const Text('คุณต้องการลบรายการนี้ใช่หรือไม่?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('ยกเลิก'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.expense),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('ลบรายการ'),
          ),
        ],
      ),
    );

    if (confirm == true && widget.transactionToEdit != null) {
      setState(() => _isSaving = true);
      if (widget.transactionToEdit!.receiptImagePath != null) {
        await _receiptStorage.deleteReceiptImage(widget.transactionToEdit!.receiptImagePath);
      }
      await _transactionRepo.deleteTransaction(widget.transactionToEdit!.id!);
      if (mounted) {
        Navigator.of(context).pop(true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.transactionToEdit != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'แก้ไขรายการ' : 'บันทึกรายการ'),
        actions: [
          if (isEditing)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: AppColors.expense),
              onPressed: _delete,
            ),
        ],
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
                    // Type Selector Tabs
                    _buildTypeSelector(),
                    const SizedBox(height: 20),

                    // Amount Field
                    _buildAmountField(),
                    const SizedBox(height: 16),

                    // Date & Time Picker Tile
                    _buildDateTimeTile(),
                    const SizedBox(height: 16),

                    // Wallet Pickers
                    _buildWalletPickers(),
                    const SizedBox(height: 16),

                    // Category Picker (Hidden for Transfer)
                    if (_selectedType != TransactionType.transfer) ...[
                      _buildCategoryPicker(),
                      const SizedBox(height: 16),
                    ],

                    // Note Field
                    _buildNoteField(),
                    const SizedBox(height: 20),

                    // Receipt / Slip Attachment Section
                    _buildReceiptSection(),
                    const SizedBox(height: 32),

                    // Save Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : _save,
                        child: _isSaving
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                              )
                            : Text(isEditing ? 'บันทึกการแก้ไข' : 'บันทึกรายการ'),
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildTypeSelector() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          _typeTab(TransactionType.expense, 'รายจ่าย', AppColors.expense),
          _typeTab(TransactionType.income, 'รายรับ', AppColors.income),
          _typeTab(TransactionType.transfer, 'โอนเงิน', AppColors.transfer),
        ],
      ),
    );
  }

  Widget _typeTab(TransactionType type, String title, Color activeColor) {
    final isSelected = _selectedType == type;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedType = type;
            if (type == TransactionType.transfer) {
              if (_wallets.length > 1 && (_selectedToWalletId == null || _selectedToWalletId == _selectedWalletId)) {
                final otherWallets = _wallets.where((w) => w.id != _selectedWalletId).toList();
                if (otherWallets.isNotEmpty) {
                  _selectedToWalletId = otherWallets.first.id;
                }
              }
            } else {
              final catType = type == TransactionType.expense ? CategoryType.expense : CategoryType.income;
              final matching = _categories.where((c) => c.type == catType);
              if (matching.isNotEmpty && !_categories.any((c) => c.id == _selectedCategoryId && c.type == catType)) {
                _selectedCategoryId = matching.first.id;
              }
            }
          });
          _formKey.currentState?.validate();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? activeColor : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          alignment: Alignment.center,
          child: Text(
            title,
            style: TextStyle(
              color: isSelected
                  ? Colors.white
                  : (Theme.of(context).brightness == Brightness.dark
                      ? AppColors.textSecondaryDark
                      : Colors.grey.shade700),
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAmountField() {
    Color color;
    switch (_selectedType) {
      case TransactionType.expense:
        color = AppColors.expense;
        break;
      case TransactionType.income:
        color = AppColors.income;
        break;
      case TransactionType.transfer:
        color = AppColors.transfer;
        break;
    }

    final double? availableForTransfer = (_selectedType == TransactionType.transfer && _selectedWalletId != null)
        ? _getAvailableBalance(_selectedWalletId!)
        : null;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'จำนวนเงิน (บาท)',
                  style: TextStyle(
                    fontSize: 13,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ),
                ),
                if (availableForTransfer != null)
                  Text(
                    'โอนได้สูงสุด ${ThaiFormatters.formatCurrency(availableForTransfer)}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: availableForTransfer <= 0 ? AppColors.expense : AppColors.transfer,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  '฿',
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: color),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    controller: _amountController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    autofocus: widget.transactionToEdit == null,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: color),
                    decoration: const InputDecoration(
                      hintText: '0.00',
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      filled: false,
                      contentPadding: EdgeInsets.zero,
                    ),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) return 'กรุณาระบุจำนวนเงิน';
                      final num = double.tryParse(val.replaceAll(',', ''));
                      if (num == null || num <= 0) return 'จำนวนเงินต้องมากกว่า 0';
                      if (_selectedType == TransactionType.transfer && _selectedWalletId != null) {
                        final available = _getAvailableBalance(_selectedWalletId!);
                        if (num > available) {
                          return 'ยอดเงินไม่เพียงพอ (คงเหลือ ${ThaiFormatters.formatCurrency(available)})';
                        }
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateTimeTile() {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.calendar_today_outlined, color: AppColors.primary),
        title: const Text('วันที่และเวลา'),
        subtitle: Text(ThaiFormatters.formatThaiDate(_selectedDate, includeTime: true)),
        trailing: const Icon(Icons.chevron_right),
        onTap: _selectDateTime,
      ),
    );
  }

  Widget _buildWalletPickers() {
    if (_selectedType == TransactionType.transfer) {
      if (_wallets.length < 2) {
        return Card(
          color: Colors.amber.withValues(alpha: 0.15),
          child: const Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: Colors.amber),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'ต้องมีกระเป๋าเงินอย่างน้อย 2 บัญชีเพื่อทำรายการโอน',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ),
        );
      }

      final sourceAvailable = _selectedWalletId != null ? _getAvailableBalance(_selectedWalletId!) : 0.0;
      final isSourceInsufficient = _selectedWalletId != null && sourceAvailable <= 0;

      final safeSelectedWalletId = _wallets.any((w) => w.id == _selectedWalletId) ? _selectedWalletId : null;
      final safeSelectedToWalletId = _wallets.any((w) => w.id == _selectedToWalletId) ? _selectedToWalletId : null;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: DropdownButtonFormField<int>(
                key: ValueKey('source_wallet_$safeSelectedWalletId'),
                initialValue: safeSelectedWalletId,
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'จากกระเป๋าเงิน (ต้นทาง)',
                  prefixIcon: Icon(Icons.arrow_upward, color: AppColors.expense),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  filled: false,
                ),
                items: _wallets.map((w) {
                  final bal = _getAvailableBalance(w.id);
                  return DropdownMenuItem<int>(
                    value: w.id,
                    child: Text(
                      '${w.name} (คงเหลือ ${ThaiFormatters.formatCurrency(bal)})',
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  );
                }).toList(),
                validator: (val) {
                  if (val == null) return 'กรุณาเลือกกระเป๋าเงินต้นทาง';
                  return null;
                },
                onChanged: (val) {
                  setState(() {
                    _selectedWalletId = val;
                    if (_selectedToWalletId == val) {
                      final otherWallets = _wallets.where((w) => w.id != val).toList();
                      _selectedToWalletId = otherWallets.isNotEmpty ? otherWallets.first.id : null;
                    }
                  });
                  _formKey.currentState?.validate();
                },
              ),
            ),
          ),
          if (isSourceInsufficient)
            const Padding(
              padding: EdgeInsets.only(top: 4, left: 12, bottom: 4),
              child: Row(
                children: [
                  Icon(Icons.error_outline, size: 14, color: AppColors.expense),
                  SizedBox(width: 6),
                  Text(
                    'ยอดเงินคงเหลือในกระเป๋านี้ไม่เพียงพอสำหรับการโอน',
                    style: TextStyle(fontSize: 12, color: AppColors.expense, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: DropdownButtonFormField<int>(
                key: ValueKey('to_wallet_$safeSelectedToWalletId'),
                initialValue: safeSelectedToWalletId,
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'ไปยังกระเป๋าเงิน (ปลายทาง)',
                  prefixIcon: Icon(Icons.arrow_downward, color: AppColors.income),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  filled: false,
                ),
                items: _wallets.map((w) {
                  final isSource = w.id == _selectedWalletId;
                  return DropdownMenuItem<int>(
                    value: w.id,
                    enabled: !isSource,
                    child: Text(
                      '${w.name} (คงเหลือ ${ThaiFormatters.formatCurrency(w.currentBalance)})${isSource ? ' - กระเป๋าต้นทาง' : ''}',
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: TextStyle(
                        color: isSource ? Colors.grey : null,
                      ),
                    ),
                  );
                }).toList(),
                validator: (val) {
                  if (_selectedType == TransactionType.transfer) {
                    if (val == null) return 'กรุณาเลือกกระเป๋าเงินปลายทาง';
                    if (val == _selectedWalletId) return 'กรุณาเลือกกระเป๋าเงินปลายทางที่ไม่ซ้ำกัน';
                  }
                  return null;
                },
                onChanged: (val) {
                  setState(() => _selectedToWalletId = val);
                  _formKey.currentState?.validate();
                },
              ),
            ),
          ),
        ],
      );
    }

    final safeWalletId = _wallets.any((w) => w.id == _selectedWalletId) ? _selectedWalletId : null;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: DropdownButtonFormField<int>(
          key: ValueKey('single_wallet_$safeWalletId'),
          initialValue: safeWalletId,
          isExpanded: true,
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
              child: Text(
                '${w.name} (คงเหลือ ${ThaiFormatters.formatCurrency(w.currentBalance)})',
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            );
          }).toList(),
          validator: (val) {
            if (val == null) return 'กรุณาเลือกกระเป๋าเงิน';
            return null;
          },
          onChanged: (val) {
            setState(() => _selectedWalletId = val);
          },
        ),
      ),
    );
  }

  Widget _buildCategoryPicker() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final catType = _selectedType == TransactionType.expense ? CategoryType.expense : CategoryType.income;
    final relevantCategories = _categories.where((c) => c.type == catType).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'หมวดหมู่',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: relevantCategories.map((c) {
            final isSelected = _selectedCategoryId == c.id;
            final catColor = Color(c.colorValue);

            return ChoiceChip(
              avatar: Icon(
                IconHelper.getIconData(c.iconCodePoint),
                size: 16,
                color: isSelected ? Colors.white : catColor,
              ),
              label: Text(c.name),
              selected: isSelected,
              selectedColor: catColor,
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
                if (selected) {
                  setState(() => _selectedCategoryId = c.id);
                }
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildNoteField() {
    return TextFormField(
      controller: _noteController,
      maxLines: 2,
      decoration: const InputDecoration(
        labelText: 'บันทึกช่วยจำ (Note)',
        hintText: 'เช่น ค่ากาแฟ, ช้อปปิ้งของใช้...',
        prefixIcon: Icon(Icons.edit_note_outlined),
      ),
    );
  }

  Widget _buildReceiptSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.receipt_outlined, color: AppColors.primary),
                    SizedBox(width: 8),
                    Text('แนบรูปสลิป / ใบเสร็จ', style: TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
                if (_newPickedReceiptFile != null || _receiptRelativePath != null)
                  TextButton.icon(
                    icon: const Icon(Icons.delete_outline, size: 16, color: AppColors.expense),
                    label: const Text('ลบรูป', style: TextStyle(color: AppColors.expense)),
                    onPressed: () {
                      setState(() {
                        _newPickedReceiptFile = null;
                        _receiptRelativePath = null;
                      });
                    },
                  ),
              ],
            ),
            const SizedBox(height: 12),
            if (_newPickedReceiptFile != null) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  _newPickedReceiptFile!,
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ] else if (_receiptRelativePath != null) ...[
              FutureBuilder<File?>(
                future: _receiptStorage.getReceiptFile(_receiptRelativePath),
                builder: (context, snapshot) {
                  final file = snapshot.data;
                  if (file != null && file.existsSync()) {
                    return GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (_) => ReceiptViewerDialog(relativePath: _receiptRelativePath!),
                        );
                      },
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(
                              file,
                              height: 180,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.zoom_in, color: Colors.white, size: 18),
                                SizedBox(width: 4),
                                Text('แตะเพื่อดูรูปเต็ม', style: TextStyle(color: Colors.white, fontSize: 12)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  return const Text('ไม่พบรูปภาพ');
                },
              ),
            ] else ...[
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.camera_alt_outlined),
                      label: const Text('ถ่ายรูป'),
                      onPressed: () => _pickImage(ImageSource.camera),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.photo_library_outlined),
                      label: const Text('เลือกจากอัลบั้ม'),
                      onPressed: () => _pickImage(ImageSource.gallery),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
