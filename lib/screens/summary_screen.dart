import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';

import '../providers/finance_provider.dart';
import '../utils/number_formatter.dart';
import '../widgets/custom_date_range_picker.dart';

class SummaryScreen extends StatefulWidget {
  const SummaryScreen({super.key});

  @override
  State<SummaryScreen> createState() => _SummaryScreenState();
}

class _SummaryScreenState extends State<SummaryScreen> {
  final List<String> _filters = ['Semana', 'Mes', 'Año', 'Personalizado'];
  String _selectedFilter = 'Mes';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Resumen Financiero',
          style: TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.analytics, color: theme.colorScheme.primary),
            onPressed: () {},
          ),
        ],
      ),
      body: Consumer<FinanceProvider>(
        builder: (context, provider, child) {
          final expensesByCategory = provider.getExpensesByCategoryForFilter(
            _selectedFilter,
          );
          final cashFlowData = provider.getCashFlowForFilter(_selectedFilter);
          final totalExpenses = expensesByCategory.values.fold(
            0.0,
            (sum, val) => sum + val,
          );
          final totalCashFlow = cashFlowData.fold(
            0.0,
            (sum, data) => sum + data.amount,
          );

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildMetricsGrid(provider, theme),
                const SizedBox(height: 24),
                _buildFilterSection(theme),
                const SizedBox(height: 24),
                _buildExpenseChart(theme, expensesByCategory, totalExpenses),
                const SizedBox(height: 24),
                _buildCashFlowChart(theme, cashFlowData, totalCashFlow),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMetricsGrid(FinanceProvider provider, ThemeData theme) {
    final totalIncome = provider.getTotalIncomeForFilter(_selectedFilter);
    final totalExpenses = provider.getTotalExpensesForFilter(_selectedFilter);
    final netFlow = totalIncome - totalExpenses;

    return Row(
      children: [
        Expanded(
          child: _buildMetricCard(
            theme,
            title: 'Ingresos',
            amount: totalIncome,
            icon: Icons.arrow_upward,
            color: Colors.green,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildMetricCard(
            theme,
            title: 'Gastos',
            amount: totalExpenses,
            icon: Icons.arrow_downward,
            color: Colors.red,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildMetricCard(
            theme,
            title: 'Flujo Neto',
            amount: netFlow,
            icon: Icons.trending_up,
            color: netFlow >= 0 ? Colors.blue : Colors.orange,
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCard(
    ThemeData theme, {
    required String title,
    required double amount,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 18, color: color),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            NumberFormatter.formatCurrency(amount),
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Período de Análisis',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest.withValues(
              alpha: 0.5,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: _filters.map((filter) {
              final isSelected = filter == _selectedFilter;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: Material(
                    color: isSelected
                        ? theme.colorScheme.primary
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    child: InkWell(
                      onTap: () => _onFilterSelected(filter),
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 8,
                        ),
                        child: Text(
                          filter,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: isSelected
                                ? Colors.white
                                : theme.colorScheme.onSurface.withValues(
                                    alpha: 0.7,
                                  ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildExpenseChart(
    ThemeData theme,
    Map<dynamic, double> data,
    double total,
  ) {
    if (data.isEmpty) {
      return _buildChartCard(
        theme,
        title: 'Distribución de Gastos',
        subtitle: 'Por categoría',
        amount: NumberFormatter.formatCurrency(total),
        child: _buildEmptyState(
          icon: Icons.pie_chart_outline,
          message: 'No hay datos de gastos\nen este período',
        ),
      );
    }

    final chartData = data.entries.map((e) {
      final categoryName = e.key.toString().split('.').last;
      return ChartData(categoryName, e.value, _getCategoryColor(categoryName));
    }).toList();

    return _buildChartCard(
      theme,
      title: 'Distribución de Gastos',
      subtitle: 'Por categoría',
      amount: NumberFormatter.formatCurrency(total),
      child: SizedBox(
        height: 220,
        child: SfCircularChart(
          margin: EdgeInsets.zero,
          legend: Legend(
            isVisible: true,
            overflowMode: LegendItemOverflowMode.wrap,
            position: LegendPosition.bottom,
            textStyle: TextStyle(
              fontFamily: 'Inter',
              fontSize: 11,
              color: theme.colorScheme.onSurface,
            ),
          ),
          series: <DoughnutSeries<ChartData, String>>[
            DoughnutSeries<ChartData, String>(
              dataSource: chartData,
              xValueMapper: (ChartData data, _) => data.category,
              yValueMapper: (ChartData data, _) => data.amount,
              pointColorMapper: (ChartData data, _) => data.color,
              dataLabelMapper: (ChartData data, _) =>
                  '${(data.amount / total * 100).toStringAsFixed(1)}%',
              dataLabelSettings: const DataLabelSettings(
                isVisible: true,
                labelPosition: ChartDataLabelPosition.inside,
                textStyle: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
              enableTooltip: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCashFlowChart(
    ThemeData theme,
    List<CashFlowData> data,
    double total,
  ) {
    if (data.isEmpty) {
      return _buildChartCard(
        theme,
        title: 'Flujo de Efectivo',
        subtitle: 'Tendencia temporal',
        amount: NumberFormatter.formatCurrency(total),
        child: _buildEmptyState(
          icon: Icons.timeline,
          message: 'No hay datos de flujo\nen este período',
        ),
      );
    }

    return _buildChartCard(
      theme,
      title: 'Flujo de Efectivo',
      subtitle: 'Tendencia temporal',
      amount: NumberFormatter.formatCurrency(total),
      child: SizedBox(
        height: 220,
        child: SfCartesianChart(
          margin: EdgeInsets.zero,
          primaryXAxis: CategoryAxis(
            labelStyle: TextStyle(
              fontFamily: 'Inter',
              fontSize: 10,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          primaryYAxis: NumericAxis(
            labelStyle: TextStyle(
              fontFamily: 'Inter',
              fontSize: 10,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
            numberFormat: NumberFormat.compactCurrency(symbol: '\$'),
          ),
          tooltipBehavior: TooltipBehavior(enable: true),
          series: <CartesianSeries<CashFlowData, String>>[
            LineSeries<CashFlowData, String>(
              dataSource: data,
              xValueMapper: (CashFlowData sales, _) => sales.period,
              yValueMapper: (CashFlowData sales, _) => sales.amount,
              color: theme.colorScheme.primary,
              width: 3,
              markerSettings: const MarkerSettings(isVisible: true),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartCard(
    ThemeData theme, {
    required String title,
    required String subtitle,
    required String amount,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  amount,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildEmptyState({required IconData icon, required String message}) {
    final theme = Theme.of(context);
    return SizedBox(
      height: 120,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 40,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Inter',
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.teal,
      Colors.pink,
      Colors.indigo,
    ];
    return colors[category.hashCode % colors.length];
  }

  void _onFilterSelected(String filter) {
    if (filter == 'Personalizado') {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => CustomDateRangePicker(
          initialRange: Provider.of<FinanceProvider>(
            context,
            listen: false,
          ).dateFilter,
          onConfirm: (range) {
            Provider.of<FinanceProvider>(
              context,
              listen: false,
            ).setDateFilter(range);
            setState(() => _selectedFilter = filter);
          },
        ),
      );
    } else {
      Provider.of<FinanceProvider>(context, listen: false).setDateFilter(null);
      setState(() => _selectedFilter = filter);
    }
  }
}

class ChartData {
  ChartData(this.category, this.amount, this.color);
  final String category;
  final double amount;
  final Color color;
}
