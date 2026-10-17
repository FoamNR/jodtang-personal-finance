import 'package:flutter/material.dart';
import '../../../core/app_colors.dart';
import '../../../core/custom_card.dart';
import '../../../core/empty_state.dart';
import '../../../core/icon_helper.dart';
import '../../../core/thai_formatters.dart';
import '../../../../domain/models/wallet.dart';
import '../view_models/wallet_view_model.dart';
import 'add_edit_wallet_dialog.dart';

class WalletListView extends StatelessWidget {
  final WalletViewModel viewModel;

  const WalletListView({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('จัดการกระเป๋าเงิน'),
          ),
          body: viewModel.isLoading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                  onRefresh: () => viewModel.loadWallets(),
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Total Balance Card
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF2563EB), Color(0xFF3B82F6)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'ยอดรวมทุกกระเป๋า',
                                style: TextStyle(color: Colors.white70, fontSize: 13),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                ThaiFormatters.formatCurrency(viewModel.totalBalance),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'ทั้งหมด ${viewModel.wallets.length} บัญชี/กระเป๋า',
                                style: const TextStyle(color: Colors.white70, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        Text(
                          'รายการกระเป๋าเงิน',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 12),

                        if (viewModel.wallets.isEmpty)
                          const EmptyState(
                            icon: Icons.account_balance_wallet_outlined,
                            title: 'ไม่มีกระเป๋าเงิน',
                            subtitle: 'กดปุ่มด้านล่างเพื่อเพิ่มกระเป๋าเงินใบแรก',
                          )
                        else
                          ...viewModel.wallets.map((wallet) => _buildWalletItem(context, wallet)),

                        const SizedBox(height: 80),
                      ],
                    ),
                  ),
                ),
          floatingActionButton: FloatingActionButton.extended(
            icon: const Icon(Icons.add),
            label: const Text('เพิ่มกระเป๋า'),
            onPressed: () => _openAddEditDialog(context),
          ),
        );
      },
    );
  }

  Widget _buildWalletItem(BuildContext context, Wallet wallet) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = Color(wallet.colorValue);

    return CustomCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              IconHelper.getIconData(wallet.iconCodePoint),
              color: color,
              size: 26,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  wallet.name,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 2),
                Text(
                  'ตั้งต้น: ${ThaiFormatters.formatCurrency(wallet.initialBalance)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                ThaiFormatters.formatCurrency(wallet.currentBalance),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: wallet.currentBalance >= 0
                      ? (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight)
                      : AppColors.expense,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, size: 18),
                    visualDensity: VisualDensity.compact,
                    onPressed: () => _openAddEditDialog(context, wallet),
                  ),
                  if (viewModel.wallets.length > 1)
                    IconButton(
                      icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.expense),
                      visualDensity: VisualDensity.compact,
                      onPressed: () => _confirmDelete(context, wallet),
                    ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _openAddEditDialog(BuildContext context, [Wallet? wallet]) async {
    final result = await showDialog<Wallet>(
      context: context,
      builder: (_) => AddEditWalletDialog(walletToEdit: wallet),
    );

    if (result != null) {
      await viewModel.saveWallet(result);
    }
  }

  Future<void> _confirmDelete(BuildContext context, Wallet wallet) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('ยืนยันการลบกระเป๋าเงิน'),
        content: Text('คุณต้องการลบกระเป๋าเงิน "${wallet.name}" ใช่หรือไม่?\nรายการที่เชื่อมโยงกับกระเป๋านี้อาจถูกลบด้วย'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('ยกเลิก')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.expense),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('ลบกระเป๋า'),
          ),
        ],
      ),
    );

    if (confirm == true && wallet.id != null) {
      await viewModel.deleteWallet(wallet.id!);
    }
  }
}
