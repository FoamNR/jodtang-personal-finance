import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/app_colors.dart';
import '../../../core/custom_card.dart';
import '../../../core/theme_controller.dart';
import '../../categories/view_models/category_view_model.dart';
import '../../categories/views/category_list_view.dart';
import '../../recurring/view_models/recurring_view_model.dart';
import '../../recurring/views/recurring_list_view.dart';
import '../../security/views/pin_screen.dart';
import '../../wallets/view_models/wallet_view_model.dart';
import '../../wallets/views/wallet_list_view.dart';
import '../view_models/settings_view_model.dart';

class SettingsView extends StatelessWidget {
  final SettingsViewModel viewModel;
  final VoidCallback? onDataResetOrRestored;

  const SettingsView({
    super.key,
    required this.viewModel,
    this.onDataResetOrRestored,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('ตั้งค่าระบบ'),
          ),
          body: viewModel.isProcessing
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('กำลังดำเนินการ... กรุณารอสักครู่'),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(
                    16,
                    16,
                    16,
                    130 + MediaQuery.paddingOf(context).bottom,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Section 1: ข้อมูลและการจัดการ
                      _buildSectionHeader(context, 'การจัดการข้อมูล'),
                      CustomCard(
                        padding: EdgeInsets.zero,
                        child: Column(
                          children: [
                            ListTile(
                              leading: const Icon(Icons.account_balance_wallet_outlined, color: AppColors.primary),
                              title: const Text('จัดการกระเป๋าเงิน'),
                              subtitle: const Text('เพิ่ม/แก้ไข บัญชีและยอดตั้งต้น'),
                              trailing: const Icon(Icons.chevron_right),
                              onTap: () {
                                final walletVm = WalletViewModel()..loadWallets();
                                Navigator.of(context).push(
                                  MaterialPageRoute(builder: (_) => WalletListView(viewModel: walletVm)),
                                );
                              },
                            ),
                            const Divider(height: 1),
                            ListTile(
                              leading: const Icon(Icons.category_outlined, color: Colors.amber),
                              title: const Text('จัดการหมวดหมู่'),
                              subtitle: const Text('เพิ่ม/แก้ไข หมวดหมู่รายรับและรายจ่าย'),
                              trailing: const Icon(Icons.chevron_right),
                              onTap: () {
                                final catVm = CategoryViewModel()..loadCategories();
                                Navigator.of(context).push(
                                  MaterialPageRoute(builder: (_) => CategoryListView(viewModel: catVm)),
                                );
                              },
                            ),
                            const Divider(height: 1),
                            ListTile(
                              leading: const Icon(Icons.repeat, color: Colors.blue),
                              title: const Text('รายการประจำอัตโนมัติ'),
                              subtitle: const Text('จัดการบิลรายเดือนและค่าใช้จ่ายประจำ'),
                              trailing: const Icon(Icons.chevron_right),
                              onTap: () {
                                final recVm = RecurringViewModel()..loadRules();
                                Navigator.of(context).push(
                                  MaterialPageRoute(builder: (_) => RecurringListView(viewModel: recVm)),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Section: การแสดงผลและธีม
                      _buildSectionHeader(context, 'การแสดงผลและธีม'),
                      AnimatedBuilder(
                        animation: ThemeController(),
                        builder: (context, _) {
                          final isDark = ThemeController().isDark(context);
                          return CustomCard(
                            padding: EdgeInsets.zero,
                            child: SwitchListTile(
                              secondary: Icon(
                                isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                                color: isDark ? Colors.amber : Colors.orange,
                              ),
                              title: const Text('โหมดมืด (Dark Mode)'),
                              subtitle: Text(
                                isDark ? 'เปิดใช้งานธีมสีมืด (ถนอมสายตา)' : 'เปิดใช้งานธีมสีสว่าง',
                              ),
                              value: isDark,
                              onChanged: (val) {
                                HapticFeedback.selectionClick();
                                ThemeController().setDarkMode(val);
                              },
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 24),

                      // Section 2: ความปลอดภัยและล็อกแอป
                      _buildSectionHeader(context, 'ความปลอดภัยและการล็อกแอป'),
                      CustomCard(
                        padding: EdgeInsets.zero,
                        child: Column(
                          children: [
                            SwitchListTile(
                              secondary: const Icon(Icons.lock_outline, color: AppColors.primary),
                              title: const Text('ล็อกด้วยรหัส PIN'),
                              subtitle: const Text('ใส่รหัสผ่าน 4 หลักก่อนเข้าใช้งานแอป'),
                              value: viewModel.isPinEnabled,
                              onChanged: (val) async {
                                if (val) {
                                  // Open PIN setup
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => PinScreen(
                                        mode: PinScreenMode.create,
                                        onPinVerifiedOrCreated: (_) {
                                          viewModel.init();
                                          Navigator.of(context).pop();
                                        },
                                        onCancel: () => Navigator.of(context).pop(),
                                      ),
                                    ),
                                  );
                                } else {
                                  await viewModel.disablePin();
                                }
                              },
                            ),
                            if (viewModel.isPinEnabled) ...[
                              const Divider(height: 1),
                              ListTile(
                                leading: const Icon(Icons.pin_outlined, color: Colors.indigo),
                                title: const Text('เปลี่ยนรหัส PIN'),
                                trailing: const Icon(Icons.chevron_right),
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => PinScreen(
                                        mode: PinScreenMode.changeOld,
                                        onPinVerifiedOrCreated: (_) {
                                          viewModel.init();
                                          Navigator.of(context).pop();
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(content: Text('เปลี่ยนรหัส PIN เรียบร้อยแล้ว')),
                                          );
                                        },
                                        onCancel: () => Navigator.of(context).pop(),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Section 3: ส่งออกและสำรองข้อมูล
                      _buildSectionHeader(context, 'สำรองข้อมูลและส่งออก (Offline Data)'),
                      CustomCard(
                        padding: EdgeInsets.zero,
                        child: Column(
                          children: [
                            ListTile(
                              leading: const Icon(Icons.table_chart_outlined, color: Colors.green),
                              title: const Text('ส่งออกเป็นไฟล์ CSV (Excel / Sheets)'),
                              subtitle: const Text('รองรับภาษาไทย 100% ด้วย UTF-8 BOM'),
                              trailing: const Icon(Icons.share_outlined),
                              onTap: () async {
                                try {
                                  await viewModel.exportCsv();
                                } catch (e) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('ส่งออก CSV ล้มเหลว: $e')),
                                    );
                                  }
                                }
                              },
                            ),
                            const Divider(height: 1),
                            ListTile(
                              leading: const Icon(Icons.archive_outlined, color: Colors.deepPurple),
                              title: const Text('สำรองข้อมูลแบบสมบูรณ์ (.ZIP)'),
                              subtitle: const Text('รวมฐานข้อมูล (.db) และรูปสลิปทุกใบในก้อนเดียว'),
                              trailing: const Icon(Icons.cloud_upload_outlined),
                              onTap: () async {
                                try {
                                  await viewModel.backupFullZip();
                                } catch (e) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('สำรองข้อมูลล้มเหลว: $e')),
                                    );
                                  }
                                }
                              },
                            ),
                            const Divider(height: 1),
                            ListTile(
                              leading: const Icon(Icons.unarchive_outlined, color: Colors.orange),
                              title: const Text('กู้คืนข้อมูลจากไฟล์ (.ZIP)'),
                              subtitle: const Text('นำข้อมูลและรูปสลิปกลับคืนสู่เครื่องนี้'),
                              trailing: const Icon(Icons.download_outlined),
                              onTap: () async {
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    title: const Text('ยืนยันการกู้คืนข้อมูล'),
                                    content: const Text(
                                      'การกู้คืนข้อมูลจะเขียนทับข้อมูลปัจจุบันด้วยข้อมูลจากไฟล์สำรอง คุณแน่ใจหรือไม่?',
                                    ),
                                    actions: [
                                      TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('ยกเลิก')),
                                      ElevatedButton(
                                        onPressed: () => Navigator.of(ctx).pop(true),
                                        child: const Text('ดำเนินการต่อ'),
                                      ),
                                    ],
                                  ),
                                );

                                if (confirm == true) {
                                  final success = await viewModel.restoreFromZip();
                                  if (context.mounted) {
                                    if (success) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('กู้คืนข้อมูลสำเร็จเรียบร้อยแล้ว')),
                                      );
                                      onDataResetOrRestored?.call();
                                    } else {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('การกู้คืนล้มเหลวหรือไฟล์ไม่ถูกต้อง')),
                                      );
                                    }
                                  }
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Section 4: ล้างข้อมูล
                      _buildSectionHeader(context, 'จัดการข้อมูลระบบ'),
                      CustomCard(
                        padding: EdgeInsets.zero,
                        child: ListTile(
                          leading: const Icon(Icons.delete_forever_outlined, color: AppColors.expense),
                          title: const Text(
                            'ล้างข้อมูลทั้งหมด (Reset All Data)',
                            style: TextStyle(color: AppColors.expense, fontWeight: FontWeight.bold),
                          ),
                          subtitle: const Text('ลบประวัติรายการ รูปสลิป และรีเซ็ตข้อมูลเริ่มต้น'),
                          onTap: () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text('คำเตือน: ล้างข้อมูลทั้งหมด'),
                                content: const Text(
                                  'รายการธุรกรรมและรูปสลิปทั้งหมดจะถูกลบถาวร และรีเซ็ตระบบเป็นค่าเริ่มต้น คุณแน่ใจหรือไม่?',
                                ),
                                actions: [
                                  TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('ยกเลิก')),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.expense),
                                    onPressed: () => Navigator.of(ctx).pop(true),
                                    child: const Text('ล้างข้อมูลถาวร'),
                                  ),
                                ],
                              ),
                            );

                            if (confirm == true) {
                              await viewModel.resetAll();
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('ล้างข้อมูลเรียบร้อยแล้ว')),
                                );
                                onDataResetOrRestored?.call();
                              }
                            }
                          },
                        ),
                      ),
                      const SizedBox(height: 24),

                      // App Info Card
                      Center(
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.14),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.account_balance_wallet, color: AppColors.primary, size: 28),
                            ),
                            const SizedBox(height: 8),
                            const Text('จดตัง (Jod Tang)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            const SizedBox(height: 2),
                            Text(
                              'เวอร์ชัน 1.0.0 • บันทึกบัญชี Offline 100%',
                              style: TextStyle(
                                color: Theme.of(context).brightness == Brightness.dark
                                    ? AppColors.textSecondaryDark
                                    : Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
        );
      },
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: isDark ? AppColors.textSecondaryDark : Colors.grey.shade600,
        ),
      ),
    );
  }
}
