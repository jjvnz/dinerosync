import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

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
          'Resumen',
          style: GoogleFonts.inter(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.account_circle), onPressed: () {}),
        ],
      ),
      body: Consumer<FinanceProvider>(
        builder: (context, provider, child) {
          // Usamos los métodos que calculan los datos según el filtro seleccionado
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
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildBalanceCard(provider, theme),
                const SizedBox(height: 16),
                // --- SECCIÓN CLAVE: FILTROS ---
                _buildFilterChips(theme),
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

  Widget _buildBalanceCard(FinanceProvider provider, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Balance Total',
            style: GoogleFonts.inter(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            NumberFormatter.formatCurrency(provider.balance),
            style: GoogleFonts.inter(fontSize: 40, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  // --- MÉTODO CORREGIDO PARA LOS FILTROS ---
  Widget _buildFilterChips(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Período de Análisis',
          style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: _filters.map((filter) {
              final isSelected = filter == _selectedFilter;
              return Padding(
                padding: const EdgeInsets.only(right: 12.0),
                child: FilterChip(
                  label: Text(filter),
                  selected: isSelected,
                  onSelected: (_) => _onFilterSelected(filter),
                  backgroundColor: theme.colorScheme.surfaceContainerHighest,
                  selectedColor: theme.colorScheme.primary,
                  labelStyle: GoogleFonts.inter(
                    color: isSelected
                        ? Colors.white
                        : theme.colorScheme.onSurface,
                  ),
                  side: BorderSide(
                    color: isSelected
                        ? theme.colorScheme.primary
                        : theme.colorScheme.outline,
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
        title: 'Gastos por Categoría',
        amount: '\$0',
        child: const Center(
          child: Text('No hay datos de gastos en este período.'),
        ),
      );
    }
    final chartData = data.entries
        .map(
          (e) =>
              ChartData(e.key.toString().split('.').last, e.value, Colors.blue),
        )
        .toList();
    return _buildChartCard(
      theme,
      title: 'Gastos por Categoría',
      amount: NumberFormatter.formatCurrency(total),
      child: SizedBox(
        height: 200,
        child: SfCircularChart(
          legend: Legend(
            isVisible: true,
            overflowMode: LegendItemOverflowMode.wrap,
            textStyle: GoogleFonts.inter(fontSize: 12),
          ),
          series: <DoughnutSeries<ChartData, String>>[
            DoughnutSeries<ChartData, String>(
              dataSource: chartData,
              xValueMapper: (ChartData data, _) => data.category,
              yValueMapper: (ChartData data, _) => data.amount,
              pointColorMapper: (ChartData data, _) => data.color,
              dataLabelSettings: const DataLabelSettings(
                isVisible: true,
                labelPosition: ChartDataLabelPosition.inside,
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
        title: 'Flujo de Dinero',
        amount: '\$0',
        child: const Center(
          child: Text('No hay datos de flujo de dinero en este período.'),
        ),
      );
    }
    return _buildChartCard(
      theme,
      title: 'Flujo de Dinero',
      amount: NumberFormatter.formatCurrency(total),
      child: SizedBox(
        height: 200,
        child: SfCartesianChart(
          primaryXAxis: CategoryAxis(
            labelStyle: GoogleFonts.inter(fontSize: 10),
          ),
          primaryYAxis: NumericAxis(
            labelStyle: GoogleFonts.inter(fontSize: 10),
          ),
          series: <SplineSeries<CashFlowData, String>>[
            SplineSeries<CashFlowData, String>(
              dataSource: data,
              xValueMapper: (CashFlowData sales, _) => sales.period,
              yValueMapper: (CashFlowData sales, _) => sales.amount,
              color: theme.colorScheme.primary,
              enableTooltip: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartCard(
    ThemeData theme, {
    required String title,
    required String amount,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Text(
            amount,
            style: GoogleFonts.inter(fontSize: 32, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  void _onFilterSelected(String filter) {
    if (filter == 'Personalizado') {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
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
      // Al seleccionar un filtro predefinido, limpiamos cualquier rango personalizado
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
