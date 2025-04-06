import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../providers/finance_provider.dart';
import '../models/category.dart';
import '../utils/number_formatter.dart';

class FinancialSummary extends StatelessWidget {
  const FinancialSummary({super.key});

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
                        color: colorScheme.onSurface.withValues(alpha: 0.6)),
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

class _VerticalDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 40,
      color: Theme.of(context).dividerColor.withValues(alpha: 0.2),
      margin: const EdgeInsets.symmetric(horizontal: 8),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final String title;
  final double amount;
  final Color color;
  final IconData icon;

  const _SummaryItem({
    required this.title,
    required this.amount,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.0),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 8),
          Text(title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
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

class _ExpensesChart extends StatelessWidget {
  final Map<Category, double> expensesByCategory;

  const _ExpensesChart({required this.expensesByCategory});

  @override
  Widget build(BuildContext context) {
    if (expensesByCategory.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.pie_chart_outline,
              size: 48,
              color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.5)),
            const SizedBox(height: 16),
            Text('No hay datos de gastos',
              style: TextStyle(
                color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.7),
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
          dataLabelSettings: DataLabelSettings(
            isVisible: true,
            labelPosition: ChartDataLabelPosition.inside,
            textStyle: const TextStyle(
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

class ChartData {
  final String category;
  final double amount;
  final Color color;
  final IconData icon;

  ChartData(this.category, this.amount, this.color, this.icon);
}