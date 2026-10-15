import 'package:flutter/material.dart';
import '../../../core/app_colors.dart';
import '../../../core/icon_helper.dart';
import '../../../../domain/models/category_item.dart';

class AddEditCategoryDialog extends StatefulWidget {
  final CategoryItem? categoryToEdit;
  final CategoryType defaultType;

  const AddEditCategoryDialog({
    super.key,
    this.categoryToEdit,
    this.defaultType = CategoryType.expense,
  });

  @override
  State<AddEditCategoryDialog> createState() => _AddEditCategoryDialogState();
}

class _AddEditCategoryDialogState extends State<AddEditCategoryDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  late CategoryType _type;
  late int _selectedColor;
  late int _selectedIcon;

  @override
  void initState() {
    super.initState();
    if (widget.categoryToEdit != null) {
      _nameController.text = widget.categoryToEdit!.name;
      _type = widget.categoryToEdit!.type;
      _selectedColor = widget.categoryToEdit!.colorValue;
      _selectedIcon = widget.categoryToEdit!.iconCodePoint;
    } else {
      _type = widget.defaultType;
      _selectedColor = AppColors.palette[2].value;
      _selectedIcon = Icons.local_cafe.codePoint;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.categoryToEdit != null;

    return AlertDialog(
      title: Text(isEditing ? 'แก้ไขหมวดหมู่' : 'เพิ่มหมวดหมู่ใหม่'),
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
                  labelText: 'ชื่อหมวดหมู่ *',
                  hintText: 'เช่น ขนม/ของว่าง, ค่าน้ำมัน, ชานม',
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) return 'กรุณาระบุชื่อหมวดหมู่';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              const Text('เลือกสีหมวดหมู่', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
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
            final category = CategoryItem(
              id: widget.categoryToEdit?.id,
              name: _nameController.text.trim(),
              type: _type,
              colorValue: _selectedColor,
              iconCodePoint: _selectedIcon,
              isDefault: widget.categoryToEdit?.isDefault ?? false,
            );
            Navigator.of(context).pop(category);
          },
          child: const Text('บันทึก'),
        ),
      ],
    );
  }
}
