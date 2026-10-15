import 'package:flutter/material.dart';
import '../../../core/app_colors.dart';
import '../../../core/icon_helper.dart';
import '../../../../domain/models/wallet.dart';

class AddEditWalletDialog extends StatefulWidget {
  final Wallet? walletToEdit;

  const AddEditWalletDialog({super.key, this.walletToEdit});

  @override
  State<AddEditWalletDialog> createState() => _AddEditWalletDialogState();
}

class _AddEditWalletDialogState extends State<AddEditWalletDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _initialBalanceController = TextEditingController();

  late int _selectedColor;
  late int _selectedIcon;

  @override
  void initState() {
    super.initState();
    if (widget.walletToEdit != null) {
      _nameController.text = widget.walletToEdit!.name;
      _initialBalanceController.text = widget.walletToEdit!.initialBalance.toStringAsFixed(2);
      _selectedColor = widget.walletToEdit!.colorValue;
      _selectedIcon = widget.walletToEdit!.iconCodePoint;
    } else {
      _initialBalanceController.text = '0.00';
      _selectedColor = AppColors.palette.first.value;
      _selectedIcon = Icons.account_balance_wallet_outlined.codePoint;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.walletToEdit != null;

    return AlertDialog(
      title: Text(isEditing ? 'แก้ไขกระเป๋าเงิน' : 'เพิ่มกระเป๋าเงินใหม่'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'ชื่อกระเป๋าเงิน *',
                  hintText: 'เช่น เงินสด, ธนาคารกสิกร, TrueMoney',
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) return 'กรุณาระบุชื่อกระเป๋า';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _initialBalanceController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'ยอดเงินตั้งต้น (บาท) *',
                  hintText: '0.00',
                  prefixText: '฿ ',
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) return 'กรุณาระบุยอดตั้งต้น';
                  if (double.tryParse(val.replaceAll(',', '')) == null) return 'ตัวเลขไม่ถูกต้อง';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              const Text('เลือกสีประจำกระเป๋า', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: AppColors.palette.map((color) {
                  final isSelected = _selectedColor == color.value;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedColor = color.value),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: isSelected ? Border.all(color: Colors.black, width: 2.5) : null,
                      ),
                      child: isSelected ? const Icon(Icons.check, size: 18, color: Colors.white) : null,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              const Text('เลือกไอคอน', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 8),
              SizedBox(
                height: 120,
                width: double.maxFinite,
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 6,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                  ),
                  itemCount: IconHelper.availableIcons.length,
                  itemBuilder: (context, idx) {
                    final icon = IconHelper.availableIcons[idx];
                    final isSelected = _selectedIcon == icon.codePoint;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedIcon = icon.codePoint),
                      child: Container(
                        decoration: BoxDecoration(
                          color: isSelected ? Color(_selectedColor).withOpacity(0.2) : Colors.grey.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: isSelected ? Border.all(color: Color(_selectedColor), width: 2) : null,
                        ),
                        child: Icon(icon, color: isSelected ? Color(_selectedColor) : Colors.grey.shade700, size: 22),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('ยกเลิก'),
        ),
        ElevatedButton(
          onPressed: () {
            if (!_formKey.currentState!.validate()) return;
            final initialBalance = double.parse(_initialBalanceController.text.replaceAll(',', ''));
            final wallet = Wallet(
              id: widget.walletToEdit?.id,
              name: _nameController.text.trim(),
              initialBalance: initialBalance,
              colorValue: _selectedColor,
              iconCodePoint: _selectedIcon,
            );
            Navigator.of(context).pop(wallet);
          },
          child: const Text('บันทึก'),
        ),
      ],
    );
  }
}
