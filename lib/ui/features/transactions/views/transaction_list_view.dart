import 'package:flutter/material.dart';

import '../../../core/app_colors.dart';
import '../../../core/custom_card.dart';
import '../../../core/empty_state.dart';
import '../../../core/icon_helper.dart';
import '../../../core/thai_formatters.dart';
import '../../../../domain/models/transaction_item.dart';
import '../view_models/transaction_view_model.dart';
import 'add_edit_transaction_view.dart';

class TransactionListView extends StatelessWidget {
  final TransactionViewModel viewModel;
  final VoidCallback? onTransactionChanged;

  const TransactionListView({
    super.key,
    required this.viewModel,
    this.onTransactionChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: const Text('ประวัติรายการ'),
            actions: [
              IconButton(
                icon: const Icon(Icons.add_circle_outline_rounded),
                tooltip: 'จดรายการใหม่',
                onPressed: () => _navigateToAdd(context),
              ),
              IconButton(
                icon: const Icon(Icons.date_range_outlined),
                tooltip: 'กรองตามช่วงวันที่',
                onPressed: () => _pickDateRange(context),
              ),
              if (viewModel.filterType != null ||
                  viewModel.filterWalletId != null ||
                  viewModel.filterCategoryId != null ||
                  viewModel.startDate != null)
                IconButton(
                  icon: const Icon(Icons.filter_alt_off_outlined),
                  tooltip: 'ล้างตัวกรอง',
                  onPressed: () => viewModel.clearFilters(),
                ),
            ],
          ),
          body: Column(
            children: [
              // Search Input
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'ค้นหาจากบันทึกช่วยจำ (Note)...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: viewModel.searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () => viewModel.setSearchQuery(''),
                          )
                        : null,
                    filled: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                  ),
                  onChanged: (val) => viewModel.setSearchQuery(val),
                ),
              ),

              // Filter Chips Row
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                child: Row(
                  children: [
                    _filterChip(
                      context,
                      label: 'ทั้งหมด',
                      isSelected: viewModel.filterType == null,
                      onSelected: () => viewModel.setFilterType(null),
                    ),
                    const SizedBox(width: 8),
                    _filterChip(
                      context,
                      label: 'รายจ่าย',
                      isSelected:
                          viewModel.filterType == TransactionType.expense,
                      selectedColor: AppColors.expense,
                      onSelected: () =>
                          viewModel.setFilterType(TransactionType.expense),
                    ),
                    const SizedBox(width: 8),
                    _filterChip(
                      context,
                      label: 'รายรับ',
                      isSelected:
                          viewModel.filterType == TransactionType.income,
                      selectedColor: AppColors.income,
                      onSelected: () =>
                          viewModel.setFilterType(TransactionType.income),
                    ),
                    const SizedBox(width: 8),
                    _filterChip(
                      context,
                      label: 'โอนเงิน',
                      isSelected:
                          viewModel.filterType == TransactionType.transfer,
                      selectedColor: AppColors.transfer,
                      onSelected: () =>
                          viewModel.setFilterType(TransactionType.transfer),
                    ),
                  ],
                ),
              ),

              // Date Range Indicator if active
              if (viewModel.startDate != null && viewModel.endDate != null)
                Container(
                  width: double.infinity,
                  color: AppColors.primary.withValues(alpha: 0.12),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'ช่วงเวลา: ${ThaiFormatters.formatThaiDate(viewModel.startDate!)} - ${ThaiFormatters.formatThaiDate(viewModel.endDate!)}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => viewModel.setDateRange(null, null),
                        child: const Icon(Icons.close, size: 16),
                      ),
                    ],
                  ),
                ),

              // Transactions List
              Expanded(
                child: viewModel.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : viewModel.transactions.isEmpty
                    ? (viewModel.searchQuery.isEmpty &&
                              viewModel.filterType == null &&
                              viewModel.filterWalletId == null &&
                              viewModel.filterCategoryId == null &&
                              viewModel.startDate == null)
                          ? EmptyState(
                              icon: Icons.receipt_long_outlined,
                              title: 'ยังไม่มีรายการ',
                              subtitle: 'เริ่มจดบันทึกรายรับหรือรายจ่ายรายการแรกของคุณได้เลย',
                              actionButton: ElevatedButton.icon(
                                icon: const Icon(Icons.add_rounded),
                                label: const Text('จดรายการ'),
                                onPressed: () => _navigateToAdd(context),
                              ),
                            )
                          : EmptyState(
                              icon: Icons.search_off_outlined,
                              title: 'ไม่พบรายการที่ตรงกับเงื่อนไข',
                              subtitle:
                                  'ลองเปลี่ยนคำค้นหาหรือล้างตัวกรองข้อมูล',
                              actionButton: ElevatedButton.icon(
                                icon: const Icon(Icons.refresh),
                                label: const Text('ล้างตัวกรอง'),
                                onPressed: () => viewModel.clearFilters(),
                              ),
                            )
                    : RefreshIndicator(
                        onRefresh: () => viewModel.loadTransactions(),
                        child: _buildGroupedList(context),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _navigateToAdd(BuildContext context) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => const AddEditTransactionView()),
    );
    if (result == true) {
      viewModel.loadTransactions();
      onTransactionChanged?.call();
    }
  }

  Widget _filterChip(
    BuildContext context, {
    required String label,
    required bool isSelected,
    Color? selectedColor,
    required VoidCallback onSelected,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = selectedColor ?? AppColors.primary;

    return GestureDetector(
      onTap: onSelected,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: isSelected
              ? LinearGradient(colors: [color, color.withValues(alpha: 0.85)])
              : null,
          color: isSelected
              ? null
              : (isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : Colors.white.withValues(alpha: 0.65)),
          border: Border.all(
            color: isSelected
                ? Colors.transparent
                : (isDark
                      ? Colors.white.withValues(alpha: 0.14)
                      : Colors.white.withValues(alpha: 0.6)),
            width: 1.2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.4),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected
                ? Colors.white
                : (isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimaryLight),
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Future<void> _pickDateRange(BuildContext context) async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      initialDateRange: viewModel.startDate != null && viewModel.endDate != null
          ? DateTimeRange(start: viewModel.startDate!, end: viewModel.endDate!)
          : null,
    );

    if (picked != null) {
      viewModel.setDateRange(picked.start, picked.end);
    }
  }

  Widget _buildGroupedList(BuildContext context) {
    // Group transactions by date string YYYY-MM-DD
    final groups = <String, List<TransactionItem>>{};
    for (var tx in viewModel.transactions) {
      final key =
          '${tx.date.year}-${tx.date.month.toString().padLeft(2, '0')}-${tx.date.day.toString().padLeft(2, '0')}';
      groups.putIfAbsent(key, () => []).add(tx);
    }
    final groupEntries = groups.entries.toList(growable: false);

    return ListView.builder(
      physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
      padding: EdgeInsets.only(
        bottom: 160 + MediaQuery.paddingOf(context).bottom,
        left: 16,
        right: 16,
        top: 8,
      ),
      itemCount: groupEntries.length,
      itemBuilder: (context, index) {
        final entry = groupEntries[index];
        final list = entry.value;
        final firstDate = list.first.date;

        // Daily sum
        double dayIncome = 0;
        double dayExpense = 0;
        for (var t in list) {
          if (t.isIncome) dayIncome += t.amount;
          if (t.isExpense) dayExpense += t.amount;
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    ThaiFormatters.formatDayHeader(firstDate),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: Colors.blueGrey,
                    ),
                  ),
                  Row(
                    children: [
                      if (dayIncome > 0)
                        Text(
                          '+${ThaiFormatters.formatCurrency(dayIncome)} ',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.income,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      if (dayExpense > 0)
                        Text(
                          '-${ThaiFormatters.formatCurrency(dayExpense)}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.expense,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            ...list.map((tx) => _buildTransactionCard(context, tx)),
            const SizedBox(height: 6),
          ],
        );
      },
    );
  }

  Widget _buildTransactionCard(BuildContext context, TransactionItem tx) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    Color typeColor;
    String prefix;

    switch (tx.type) {
      case TransactionType.expense:
        typeColor = AppColors.expense;
        prefix = '-';
        break;
      case TransactionType.income:
        typeColor = AppColors.income;
        prefix = '+';
        break;
      case TransactionType.transfer:
        typeColor = AppColors.transfer;
        prefix = '⇄ ';
        break;
    }

    final iconData = tx.categoryIcon != null
        ? IconHelper.getIconData(tx.categoryIcon!)
        : (tx.isTransfer ? Icons.swap_horiz : Icons.receipt_outlined);

    final iconColor = tx.categoryColor != null
        ? Color(tx.categoryColor!)
        : typeColor;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: RepaintBoundary(
        child: Dismissible(
          key: ValueKey(tx.id),
        direction: DismissDirection.endToStart,
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          decoration: BoxDecoration(
            color: AppColors.expense,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(Icons.delete_outline, color: Colors.white),
        ),
        confirmDismiss: (direction) async {
          return await showDialog<bool>(
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
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.expense,
                  ),
                  onPressed: () => Navigator.of(ctx).pop(true),
                  child: const Text('ลบ'),
                ),
              ],
            ),
          );
        },
        onDismissed: (_) {
          viewModel.deleteTransaction(tx);
          onTransactionChanged?.call();
        },
        child: CustomCard(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        onTap: () async {
          final res = await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => AddEditTransactionView(transactionToEdit: tx),
            ),
          );
          if (res == true) {
            viewModel.loadTransactions();
            onTransactionChanged?.call();
          }
        },
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(iconData, color: iconColor, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tx.isTransfer
                        ? '${tx.walletName ?? "กระเป๋า"} ➔ ${tx.toWalletName ?? "กระเป๋า"}'
                        : (tx.categoryName ?? tx.type.labelTh),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${tx.walletName ?? ""} • ${ThaiFormatters.formatThaiDate(tx.date, includeTime: true)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    ),
                  ),
                  if (tx.note != null && tx.note!.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      tx.note!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                        color: isDark ? AppColors.textSecondaryDark : Colors.grey,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '$prefix${ThaiFormatters.formatCurrency(tx.amount)}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: typeColor,
                  ),
                ),
                if (tx.receiptImagePath != null &&
                    tx.receiptImagePath!.isNotEmpty)
                  const Padding(
                    padding: EdgeInsets.only(top: 4),
                    child: Row(
                      children: [
                        Icon(Icons.image, size: 14, color: Colors.blueGrey),
                        SizedBox(width: 2),
                        Text(
                          'สลิป',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.blueGrey,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    ),
  ),
);
}
}
