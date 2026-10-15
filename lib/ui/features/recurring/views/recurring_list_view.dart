import 'package:flutter/material.dart';
import '../../../core/app_colors.dart';
import '../../../core/custom_card.dart';
import '../../../core/empty_state.dart';
import '../../../core/icon_helper.dart';
import '../../../core/thai_formatters.dart';
import '../../../../domain/models/recurring_rule.dart';
import '../../../../domain/models/transaction_item.dart';
import '../view_models/recurring_view_model.dart';
import 'add_edit_recurring_view.dart';

class RecurringListView extends StatelessWidget {
  final RecurringViewModel viewModel;

  const RecurringListView({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('รายการประจำอัตโนมัติ'),
            actions: [
              IconButton(
                icon: const Icon(Icons.sync),
                tooltip: 'ตรวจสอบและบันทึกรายการที่ครบกำหนดทันที',
                onPressed: () async {
                  final count = await viewModel.executeDueRulesNow();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(count > 0 ? 'สร้างรายการใหม่แล้ว $count รายการ' : 'ไม่มีรายการที่ครบกำหนดในขณะนี้')),
                    );
                  }
                },
              ),
            ],
          ),
          body: viewModel.isLoading
              ? const Center(child: CircularProgressIndicator())
              : viewModel.rules.isEmpty
                  ? EmptyState(
                      icon: Icons.repeat,
                      title: 'ยังไม่มีรายการประจำ',
                      subtitle: 'สร้างแม่แบบเพื่อบันทึกค่าใช้จ่ายประจำอัตโนมัติ เช่น ค่าหอพัก, ค่าเน็ต, เงินเดือน',
                      actionButton: ElevatedButton.icon(
                        icon: const Icon(Icons.add),
                        label: const Text('สร้างรายการประจำแรก'),
                        onPressed: () => _openAddEdit(context),
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: () => viewModel.loadRules(),
                      child: ListView.builder(
                        padding: const EdgeInsets.only(top: 12, bottom: 80, left: 16, right: 16),
                        itemCount: viewModel.rules.length,
                        itemBuilder: (context, index) {
                          final rule = viewModel.rules[index];
                          return _buildRuleCard(context, rule);
                        },
                      ),
                    ),
          floatingActionButton: FloatingActionButton.extended(
            icon: const Icon(Icons.add),
            label: const Text('สร้างรายการประจำ'),
            onPressed: () => _openAddEdit(context),
          ),
        );
      },
    );
  }

  Widget _buildRuleCard(BuildContext context, RecurringRule rule) {
    final color = rule.categoryColor != null ? Color(rule.categoryColor!) : AppColors.primary;

    return CustomCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  rule.categoryIcon != null ? IconHelper.getIconData(rule.categoryIcon!) : Icons.repeat,
                  color: color,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      rule.name,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${rule.frequency.labelTh} • ${rule.walletName ?? "กระเป๋า"}',
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondaryLight),
                    ),
                  ],
                ),
              ),
              Switch(
                value: rule.isActive,
                activeThumbColor: AppColors.primary,
                onChanged: (val) => viewModel.toggleActive(rule, val),
              ),
            ],
          ),
          const Divider(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('กำหนดรอบถัดไป', style: TextStyle(fontSize: 11, color: Colors.grey)),
                  const SizedBox(height: 2),
                  Text(
                    ThaiFormatters.formatThaiDate(rule.nextDueDate),
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                  ),
                ],
              ),
              Text(
                '${rule.type == TransactionType.expense ? "-" : "+"}${ThaiFormatters.formatCurrency(rule.amount)}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: rule.type == TransactionType.expense ? AppColors.expense : AppColors.income,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                icon: const Icon(Icons.edit_outlined, size: 16),
                label: const Text('แก้ไข'),
                onPressed: () => _openAddEdit(context, rule),
              ),
              TextButton.icon(
                icon: const Icon(Icons.delete_outline, size: 16, color: AppColors.expense),
                label: const Text('ลบ', style: TextStyle(color: AppColors.expense)),
                onPressed: () => _confirmDelete(context, rule),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _openAddEdit(BuildContext context, [RecurringRule? rule]) async {
    final result = await Navigator.of(context).push<RecurringRule>(
      MaterialPageRoute(builder: (_) => AddEditRecurringView(ruleToEdit: rule)),
    );

    if (result != null) {
      await viewModel.saveRule(result);
    }
  }

  Future<void> _confirmDelete(BuildContext context, RecurringRule rule) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('ยืนยันการลบรายการประจำ'),
        content: Text('คุณต้องการลบรายการประจำ "${rule.name}" ใช่หรือไม่?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('ยกเลิก')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.expense),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('ลบรายการ'),
          ),
        ],
      ),
    );

    if (confirm == true && rule.id != null) {
      await viewModel.deleteRule(rule.id!);
    }
  }
}
