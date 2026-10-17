import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/app_colors.dart';
import '../../../core/custom_card.dart';
import '../../../core/empty_state.dart';
import '../../../core/glass_container.dart';
import '../../../core/icon_helper.dart';
import '../../../core/thai_formatters.dart';
import '../../../../domain/models/transaction_item.dart';
import '../view_models/dashboard_view_model.dart';

class DashboardView extends StatelessWidget {
  final DashboardViewModel viewModel;
  final VoidCallback? onAddExpense;
  final VoidCallback? onAddIncome;
  final VoidCallback? onAddTransfer;
  final Function(TransactionItem)? onTransactionTap;
  final VoidCallback? onViewAllTransactions;

  const DashboardView({
    super.key,
    required this.viewModel,
    this.onAddExpense,
    this.onAddIncome,
    this.onAddTransfer,
    this.onTransactionTap,
    this.onViewAllTransactions,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final overlayStyle = SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
      statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
    );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: overlayStyle,
      child: SafeArea(
        bottom: false,
        child: ListenableBuilder(
          listenable: viewModel,
          builder: (context, _) {
            if (viewModel.isLoading && viewModel.recentTransactions.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            final summary = viewModel.summary;

            return RefreshIndicator(
              onRefresh: () => viewModel.loadData(),
              child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.fromLTRB(
              16,
              12,
              16,
              130 + MediaQuery.paddingOf(context).bottom,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Month Selector
                _buildMonthSelector(context),
                const SizedBox(height: 16),

                // Main Total Balance Card
                _buildTotalBalanceCard(context, summary.totalBalance),
                const SizedBox(height: 16),

                // Income & Expense Summary Cards
                _buildIncomeExpenseRow(context, summary.totalIncome, summary.totalExpense),
                const SizedBox(height: 20),

                // Quick Action Buttons
                _buildQuickActionButtons(context),
                const SizedBox(height: 24),

                // Recent Transactions Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'รายการล่าสุด',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    if (viewModel.recentTransactions.isNotEmpty && onViewAllTransactions != null)
                      TextButton(
                        onPressed: onViewAllTransactions,
                        child: const Text('ดูทั้งหมด'),
                      ),
                  ],
                ),
                const SizedBox(height: 8),

                // Recent Transactions List
                if (viewModel.recentTransactions.isEmpty)
                  EmptyState(
                    icon: Icons.receipt_long_outlined,
                    title: 'ยังไม่มีรายการบันทึกในเดือนนี้',
                    subtitle: 'กดปุ่มด้านบนเพื่อเริ่มจดรายรับหรือรายจ่ายได้ทันที',
                  )
                else
                  ...viewModel.recentTransactions.map((tx) => _buildTransactionTile(context, tx)),

                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    ),
  ),
);
  }

  Widget _buildMonthSelector(BuildContext context) {
    return GlassContainer(
      borderRadius: 24,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left_rounded, size: 26),
            onPressed: () => viewModel.changeMonth(-1),
          ),
          Row(
            children: [
              const Icon(Icons.calendar_month_rounded, size: 18, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                ThaiFormatters.formatMonthYear(viewModel.selectedDate),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.3,
                    ),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right_rounded, size: 26),
            onPressed: () => viewModel.changeMonth(1),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalBalanceCard(BuildContext context, double totalBalance) {
    return GlassContainer(
      borderRadius: 26,
      blur: 24,
      padding: const EdgeInsets.all(22),
      customGradient: const LinearGradient(
        colors: [Color(0xD9059669), Color(0xD910B981)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      customBorder: Border.all(
        color: Colors.white.withValues(alpha: 0.45),
        width: 1.4,
      ),
      customShadow: [
        BoxShadow(
          color: const Color(0xFF10B981).withValues(alpha: 0.35),
          blurRadius: 22,
          offset: const Offset(0, 8),
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'ยอดเงินคงเหลือรวมทั้งหมด',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.22),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.40),
                    width: 1,
                  ),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.account_balance_wallet_rounded,
                      size: 14,
                      color: Colors.white,
                    ),
                    SizedBox(width: 5),
                    Text(
                      'จดตัง',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            ThaiFormatters.formatCurrency(totalBalance),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 34,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIncomeExpenseRow(BuildContext context, double income, double expense) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      children: [
        // Income Card
        Expanded(
          child: CustomCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.income.withValues(alpha: 0.14),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.arrow_downward, size: 16, color: AppColors.income),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'รายรับเดือนนี้',
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  ThaiFormatters.formatCurrency(income),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.income,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),

        // Expense Card
        Expanded(
          child: CustomCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.expense.withValues(alpha: 0.14),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.arrow_upward, size: 16, color: AppColors.expense),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'รายจ่ายเดือนนี้',
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  ThaiFormatters.formatCurrency(expense),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.expense,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActionButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _QuickActionButton(
            label: 'จดรายจ่าย',
            icon: Icons.remove_circle_outline,
            color: AppColors.expense,
            onTap: onAddExpense,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _QuickActionButton(
            label: 'จดรายรับ',
            icon: Icons.add_circle_outline,
            color: AppColors.income,
            onTap: onAddIncome,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _QuickActionButton(
            label: 'โอนเงิน',
            icon: Icons.swap_horiz,
            color: AppColors.transfer,
            onTap: onAddTransfer,
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionTile(BuildContext context, TransactionItem tx) {
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

    final iconColor = tx.categoryColor != null ? Color(tx.categoryColor!) : typeColor;

    return CustomCard(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      onTap: () => onTransactionTap?.call(tx),
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
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
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
              if (tx.receiptImagePath != null && tx.receiptImagePath!.isNotEmpty)
                const Padding(
                  padding: EdgeInsets.only(top: 4),
                  child: Row(
                    children: [
                      Icon(Icons.image, size: 14, color: Colors.blueGrey),
                      SizedBox(width: 2),
                      Text('สลิป', style: TextStyle(fontSize: 10, color: Colors.blueGrey)),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const _QuickActionButton({
    required this.label,
    required this.icon,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      borderRadius: 18,
      blur: 16,
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      onTap: onTap,
      customBorder: Border.all(
        color: color.withValues(alpha: 0.28),
        width: 1.2,
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withValues(alpha: 0.14),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
