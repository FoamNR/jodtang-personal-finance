import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../core/app_colors.dart';
import '../../../core/custom_card.dart';
import '../../../core/empty_state.dart';
import '../../../core/glass_container.dart';
import '../../../core/icon_helper.dart';
import '../../../core/thai_formatters.dart';
import '../view_models/analytics_view_model.dart';

class AnalyticsView extends StatelessWidget {
  final AnalyticsViewModel viewModel;

  const AnalyticsView({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) {
        final summary = viewModel.summary;
        final expenses = summary.topCategoryExpenses;

        return Scaffold(
          appBar: AppBar(
            title: const Text('วิเคราะห์และรายงาน'),
          ),
          body: RefreshIndicator(
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
                  GlassContainer(
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
                  ),
                  const SizedBox(height: 16),

                  // Net Saving Card
                  CustomCard(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'เงินออมสุทธิประจำเดือน',
                              style: TextStyle(fontSize: 14, color: AppColors.textSecondaryLight),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: (summary.netSavings >= 0 ? AppColors.income : AppColors.expense).withValues(alpha: 0.14),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                summary.netSavings >= 0 ? 'คงเหลือบวก' : 'ใช้เกินงบ',
                                style: TextStyle(
                                  color: summary.netSavings >= 0 ? AppColors.income : AppColors.expense,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Text(
                              ThaiFormatters.formatCurrency(summary.netSavings),
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: summary.netSavings >= 0 ? AppColors.income : AppColors.expense,
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Column(
                              children: [
                                const Text('รายรับรวม', style: TextStyle(fontSize: 12, color: Colors.grey)),
                                const SizedBox(height: 4),
                                Text(
                                  ThaiFormatters.formatCurrency(summary.totalIncome),
                                  style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.income),
                                ),
                              ],
                            ),
                            Container(height: 24, width: 1, color: Colors.grey.shade300),
                            Column(
                              children: [
                                const Text('รายจ่ายรวม', style: TextStyle(fontSize: 12, color: Colors.grey)),
                                const SizedBox(height: 4),
                                Text(
                                  ThaiFormatters.formatCurrency(summary.totalExpense),
                                  style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.expense),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Chart Section
                  if (expenses.isEmpty)
                    const EmptyState(
                      icon: Icons.pie_chart_outline,
                      title: 'ไม่มีข้อมูลรายจ่ายในเดือนนี้',
                      subtitle: 'เมื่อมีการบันทึกรายจ่าย กราฟแสดงสัดส่วนจะปรากฏที่นี่',
                    )
                  else ...[
                    Text(
                      'สัดส่วนรายจ่ายแยกตามหมวดหมู่',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 12),

                    // Donut Chart Container
                    CustomCard(
                      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                      child: Column(
                        children: [
                          SizedBox(
                            height: 200,
                            child: PieChart(
                              PieChartData(
                                sectionsSpace: 2,
                                centerSpaceRadius: 50,
                                sections: expenses.map((cat) {
                                  return PieChartSectionData(
                                    color: Color(cat.colorValue),
                                    value: cat.totalAmount,
                                    title: '${cat.percentage.toStringAsFixed(0)}%',
                                    radius: 40,
                                    titleStyle: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'รวมรายจ่าย: ${ThaiFormatters.formatCurrency(summary.totalExpense)}',
                            style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.expense),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Category Breakdown List
                    Text(
                      'รายละเอียดแต่ละหมวดหมู่',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),

                    ...expenses.map((cat) {
                      final catColor = Color(cat.colorValue);

                      return CustomCard(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: catColor.withValues(alpha: 0.14),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(
                                    IconHelper.getIconData(cat.iconCodePoint),
                                    color: catColor,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        cat.categoryName,
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'สัดส่วน ${cat.percentage.toStringAsFixed(1)}%',
                                        style: const TextStyle(fontSize: 11, color: AppColors.textSecondaryLight),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  ThaiFormatters.formatCurrency(cat.totalAmount),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                    color: AppColors.expense,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            // Progress bar
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: cat.percentage / 100,
                                minHeight: 6,
                                backgroundColor: Colors.grey.shade200,
                                valueColor: AlwaysStoppedAnimation<Color>(catColor),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],

                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
