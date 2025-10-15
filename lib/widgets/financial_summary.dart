import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../providers/finance_provider.dart';
import '../models/category.dart';
import '../utils/number_formatter.dart';

/// Widget that displays a comprehensive financial summary.
///
/// Shows income, expenses, balance, and expense distribution chart
/// based on data from [FinanceProvider]. Includes an information
/// dialog to explain the summary components.
class FinancialSummary extends StatelessWidget {
  /// Creates a new financial summary widget.
  const FinancialSummary({super.key});

  /// Builds the financial summary interface.
  ///
  /// Creates two cards: one with income/expenses/balance summary
  /// and another with expense distribution chart.
  @override
  Widget build(BuildContext context) {
    final financeProvider = Provider.of<FinanceProvider>(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          color: colorScheme.surfaceContainerHighest,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Resumen Financiero',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.info_outline,
                        color: colorScheme.onSurface.withAlpha(153)),
                      onPressed: () => _showSummaryInfo(context),
                      iconSize: 20,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _SummaryItem(
                      title: 'Ingresos',
                      amount: financeProvider.totalIncome,
                      color: Colors.green,
                      icon: Icons.arrow_upward,
                    ),
                    _VerticalDivider(),
                    _SummaryItem(
                      title: 'Gastos',
                      amount: financeProvider.totalExpenses,
                      color: Colors.red,
                      icon: Icons.arrow_downward,
                    ),
                    _VerticalDivider(),
                    _SummaryItem(
                      title: 'Balance',
                      amount: financeProvider.balance,
                      color: financeProvider.balance >= 0
                          ? Colors.green
                          : Colors.red,
                      icon: financeProvider.balance >= 0
                          ? Icons.trending_up
                          : Icons.trending_down,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          color: colorScheme.surfaceContainerHighest,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Distribución de Gastos',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 200,
                  child: _ExpensesChart(
                      expensesByCategory: financeProvider.expensesByCategory),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Shows an information dialog explaining the summary.
  ///
  /// Displays details about what the financial summary represents
  /// and how the data is calculated.
  void _showSummaryInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Información del Resumen'),
        content: const Text(
            'Este resumen muestra tus ingresos, gastos y balance total '
            'según el período seleccionado. Los gráficos muestran cómo se '
            'distribuyen tus gastos por categoría.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }
}

/// Private widget that creates a vertical divider line.
///
/// Used to separate summary items in the financial overview.
class _VerticalDivider extends StatelessWidget {
  /// Builds a thin vertical line with theme-appropriate color.
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 40,
      color: Theme.of(context).dividerColor.withAlpha(51),
      margin: const EdgeInsets.symmetric(horizontal: 8),
    );
  }
}

/// Private widget that displays a single financial summary item.
///
/// Shows an icon, title, and formatted amount with consistent styling.
class _SummaryItem extends StatelessWidget {
  /// The display title for this summary item.
  final String title;
  
  /// The monetary amount to display.
  final double amount;
  
  /// The color theme for the icon and amount text.
  final Color color;
  
  /// The icon to display above the title.
  final IconData icon;

  /// Creates a new summary item.
  ///
  /// All parameters are required to properly display the financial data.
  const _SummaryItem({
    required this.title,
    required this.amount,
    required this.color,
    required this.icon,
  });

  /// Builds the summary item with icon, title, and amount.
  ///
  /// Creates a column layout with consistent spacing and theming.
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withAlpha(0),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 8),
          Text(title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withAlpha(153),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            NumberFormatter.formatCurrency(amount),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// Private widget that displays expense distribution as a doughnut chart.
///
/// Shows expenses grouped by category with percentages and tooltips.
/// Displays an empty state when no expense data is available.
class _ExpensesChart extends StatelessWidget {
  /// Map of categories to their total expense amounts.
  final Map<Category, double> expensesByCategory;

  /// Creates a new expenses chart.
  ///
  /// Requires [expensesByCategory] data to generate the visualization.
  const _ExpensesChart({required this.expensesByCategory});

  /// Builds the expense distribution chart.
  ///
  /// Returns either a doughnut chart with expense data or an empty
  /// state message when no expenses are available.
  @override
  Widget build(BuildContext context) {
    if (expensesByCategory.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.pie_chart_outline,
              size: 48,
              color: Theme.of(context).colorScheme.outline.withAlpha(128)),
            const SizedBox(height: 16),
            Text('No hay datos de gastos',
              style: TextStyle(
                color: Theme.of(context).colorScheme.outline.withAlpha(179),
              ),
            ),
          ],
        ),
      );
    }

    final chartData = expensesByCategory.entries.map((entry) {
      return ChartData(
        entry.key.name,
        entry.value,
        entry.key.color,
        entry.key.icon,
      );
    }).toList();

    return SfCircularChart(
      margin: EdgeInsets.zero,
      legend: Legend(
        isVisible: true,
        position: LegendPosition.bottom,
        overflowMode: LegendItemOverflowMode.wrap,
        textStyle: TextStyle(
          fontSize: 12,
          color: Theme.of(context).colorScheme.onSurface,
        ),
        iconHeight: 12,
        iconWidth: 12,
      ),
      series: <CircularSeries>[
        DoughnutSeries<ChartData, String>(
          dataSource: chartData,
          xValueMapper: (ChartData data, _) => data.category,
          yValueMapper: (ChartData data, _) => data.amount,
          pointColorMapper: (ChartData data, _) => data.color,
          dataLabelMapper: (ChartData data, _) =>
              '${(data.amount / expensesByCategory.values.fold(0, (a, b) => a + b) * 100).toStringAsFixed(0)}%',
          dataLabelSettings: const DataLabelSettings(
            isVisible: true,
            labelPosition: ChartDataLabelPosition.inside,
            textStyle: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
            showZeroValue: false,
          ),
          radius: '70%',
          innerRadius: '60%',
          explode: true,
          explodeAll: false,
          enableTooltip: true,
        )
      ],
      tooltipBehavior: TooltipBehavior(
        enable: true,
        format: 'point.x: \$point.y',
        textStyle: const TextStyle(color: Colors.white),
      ),
    );
  }
}

/// Data model for chart visualization.
///
/// Represents a single data point in the expense distribution chart
/// with category information, amount, and visual styling.
class ChartData {
  /// The category name for display.
  final String category;
  
  /// The expense amount for this category.
  final double amount;
  
  /// The color to use for this data point.
  final Color color;
  
  /// The icon associated with this category.
  final IconData icon;

  /// Creates chart data for a category.
  ///
  /// All parameters are required for proper chart rendering.
  ChartData(this.category, this.amount, this.color, this.icon);
}