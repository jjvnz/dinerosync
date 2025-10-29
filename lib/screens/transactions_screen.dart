import 'package:dinerosync/models/transaction.dart';
import 'package:dinerosync/utils/number_formatter.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../providers/finance_provider.dart';
import '../widgets/new_transaction_item.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  bool _isSearching = false;
  List<Transaction> _filteredTransactions = [];
  String _currentFilter = 'all';
  String _currentSort = 'recent';

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _filterTransactions(String query, FinanceProvider provider) {
    if (query.isEmpty) {
      setState(() {
        _filteredTransactions = [];
        _isSearching = false;
      });
      return;
    }

    List<Transaction> allTransactions = _applyFiltersAndSorting(
      provider.groupedTransactions.values.expand((list) => list).toList(),
    );

    setState(() {
      _filteredTransactions = allTransactions.where((transaction) {
        final description = transaction.description.toLowerCase();
        final category = transaction.category.toString().toLowerCase();
        final amount = NumberFormatter.formatCurrency(
          transaction.amount,
        ).toLowerCase();
        final queryLower = query.toLowerCase();

        return description.contains(queryLower) ||
            category.contains(queryLower) ||
            amount.contains(queryLower);
      }).toList();
      _isSearching = true;
    });
  }

  List<Transaction> _applyFiltersAndSorting(List<Transaction> transactions) {
    // Aplicar filtro
    List<Transaction> filtered = transactions.where((transaction) {
      switch (_currentFilter) {
        case 'income':
          return transaction.type == TransactionType.income;
        case 'expense':
          return transaction.type == TransactionType.expense;
        default:
          return true;
      }
    }).toList();

    // Aplicar ordenamiento
    filtered.sort((a, b) {
      switch (_currentSort) {
        case 'recent':
          return b.date.compareTo(a.date);
        case 'oldest':
          return a.date.compareTo(b.date);
        case 'amount_high':
          return b.amount.compareTo(a.amount);
        case 'amount_low':
          return a.amount.compareTo(b.amount);
        default:
          return b.date.compareTo(a.date);
      }
    });

    return filtered;
  }

  Map<String, List<Transaction>> _groupTransactionsByDate(
    List<Transaction> transactions,
  ) {
    final grouped = <String, List<Transaction>>{};

    for (final transaction in transactions) {
      final dateKey = DateFormat(
        'EEEE, d MMMM yyyy',
        'es_ES',
      ).format(transaction.date);
      grouped.putIfAbsent(dateKey, () => []).add(transaction);
    }

    return grouped;
  }

  void _showFilterBottomSheet(BuildContext context, FinanceProvider provider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _FilterBottomSheet(
        currentFilter: _currentFilter,
        currentSort: _currentSort,
        onFilterChanged: (filter, sort) {
          setState(() {
            _currentFilter = filter;
            _currentSort = sort;
          });
          Navigator.pop(context);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: _buildAppBar(context),
      body: Consumer<FinanceProvider>(
        builder: (context, provider, child) {
          if (_isSearching) {
            return _buildSearchResults(context, _filteredTransactions);
          }

          final allTransactions = provider.groupedTransactions.values
              .expand((list) => list)
              .toList();
          final filteredTransactions = _applyFiltersAndSorting(allTransactions);
          final groupedTransactions = _groupTransactionsByDate(
            filteredTransactions,
          );

          if (groupedTransactions.isEmpty) {
            return _buildEmptyState(context);
          }

          return _buildTransactionList(context, groupedTransactions);
        },
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Theme.of(context).colorScheme.surface,
      elevation: 0,
      title: _isSearching
          ? _buildSearchField(context)
          : Text(
              'Transacciones',
              style: TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.w700,
                fontSize: 24,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
      actions: _buildAppBarActions(context),
    );
  }

  Widget _buildSearchField(BuildContext context) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(20),
      ),
      child: TextField(
        controller: _searchController,
        focusNode: _searchFocusNode,
        autofocus: true,
        decoration: InputDecoration(
          hintText: 'Buscar transacciones...',
          hintStyle: TextStyle(
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.5),
            fontFamily: 'Inter',
          ),
          border: InputBorder.none,
          prefixIcon: Icon(
            Icons.search,
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.5),
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 8),
        ),
        style: const TextStyle(fontFamily: 'Inter'),
        onChanged: (query) =>
            _filterTransactions(query, context.read<FinanceProvider>()),
      ),
    );
  }

  List<Widget> _buildAppBarActions(BuildContext context) {
    return [
      if (_isSearching)
        IconButton(
          icon: Icon(
            Icons.close,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          onPressed: () {
            setState(() {
              _searchController.clear();
              _isSearching = false;
              _filteredTransactions = [];
            });
          },
        )
      else
        IconButton(
          icon: Icon(
            Icons.search,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          onPressed: () {
            setState(() {
              _isSearching = true;
            });
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _searchFocusNode.requestFocus();
            });
          },
        ),
      if (!_isSearching)
        IconButton(
          icon: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: (_currentFilter != 'all' || _currentSort != 'recent')
                  ? Theme.of(context).colorScheme.primary
                  : Colors.transparent,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.filter_list,
              color: (_currentFilter != 'all' || _currentSort != 'recent')
                  ? Theme.of(context).colorScheme.onPrimary
                  : Theme.of(context).colorScheme.onSurface,
              size: 20,
            ),
          ),
          onPressed: () =>
              _showFilterBottomSheet(context, context.read<FinanceProvider>()),
        ),
    ];
  }

  Widget _buildTransactionList(
    BuildContext context,
    Map<String, List<Transaction>> groupedTransactions,
  ) {
    return Column(
      children: [
        // Header con resumen
        _buildSummaryHeader(context, groupedTransactions),
        const SizedBox(height: 8),
        // Lista de transacciones
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.only(bottom: 100),
            itemCount: groupedTransactions.keys.length,
            separatorBuilder: (context, index) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final dateKey = groupedTransactions.keys.elementAt(index);
              final transactionsForDay = groupedTransactions[dateKey]!;
              return _buildDayGroup(context, dateKey, transactionsForDay);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryHeader(
    BuildContext context,
    Map<String, List<Transaction>> groupedTransactions,
  ) {
    final allTransactions = groupedTransactions.values
        .expand((list) => list)
        .toList();
    final totalIncome = allTransactions
        .where((t) => t.type == TransactionType.income)
        .fold(0.0, (sum, t) => sum + t.amount);
    final totalExpense = allTransactions
        .where((t) => t.type == TransactionType.expense)
        .fold(0.0, (sum, t) => sum + t.amount);
    final netAmount = totalIncome - totalExpense;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
            Theme.of(context).colorScheme.secondary.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildSummaryItem(
            context,
            'Ingresos',
            totalIncome,
            Colors.green,
            Icons.arrow_upward,
          ),
          _buildSummaryItem(
            context,
            'Gastos',
            totalExpense,
            Colors.red,
            Icons.arrow_downward,
          ),
          _buildSummaryItem(
            context,
            'Neto',
            netAmount,
            netAmount >= 0 ? Colors.green : Colors.red,
            netAmount >= 0 ? Icons.trending_up : Icons.trending_down,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(
    BuildContext context,
    String title,
    double amount,
    Color color,
    IconData icon,
  ) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 16, color: color),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 12,
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          NumberFormatter.formatCurrency(amount),
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildSearchResults(
    BuildContext context,
    List<Transaction> transactions,
  ) {
    if (transactions.isEmpty && _searchController.text.isNotEmpty) {
      return _buildEmptySearchState(context);
    }

    final groupedSearchResults = _groupTransactionsByDate(transactions);

    return Column(
      children: [
        // Resultados de búsqueda header
        Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(Icons.search, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '${transactions.length} resultado${transactions.length != 1 ? 's' : ''} encontrado${transactions.length != 1 ? 's' : ''}',
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        // Lista de resultados
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.only(bottom: 100),
            itemCount: groupedSearchResults.keys.length,
            separatorBuilder: (context, index) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final dateKey = groupedSearchResults.keys.elementAt(index);
              final transactionsForDay = groupedSearchResults[dateKey]!;
              return _buildDayGroup(context, dateKey, transactionsForDay);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDayGroup(
    BuildContext context,
    String dateKey,
    List<Transaction> transactions,
  ) {
    final dayTotal = transactions.fold(
      0.0,
      (sum, t) =>
          t.type == TransactionType.income ? sum + t.amount : sum - t.amount,
    );

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                Theme.of(context).colorScheme.secondary.withValues(alpha: 0.1),
              ],
            ),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.calendar_today,
            color: Theme.of(context).colorScheme.primary,
            size: 18,
          ),
        ),
        title: Text(
          _capitalizeFirstLetter(dateKey),
          style: const TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: dayTotal >= 0
                        ? Colors.green.withValues(alpha: 0.1)
                        : Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${dayTotal >= 0 ? '+' : ''}${NumberFormatter.formatCurrency(dayTotal)}',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      color: dayTotal >= 0 ? Colors.green : Colors.red,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${transactions.length} transacciones',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.6),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: Icon(
          Icons.expand_more,
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
        ),
        children: [
          const Divider(height: 1, indent: 20, endIndent: 20),
          ...transactions.map((transaction) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: NewTransactionItem(transaction: transaction),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 80),
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                  Theme.of(
                    context,
                  ).colorScheme.secondary.withValues(alpha: 0.05),
                ],
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.receipt_long,
              size: 64,
              color: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 32),
          Text(
            '¡Comienza a registrar tu actividad!',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'Añade tus primeros gastos e ingresos para llevar un control detallado de tus finanzas personales.',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 16,
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.7),
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          Column(
            children: [
              _buildFeatureItem(
                context,
                Icons.analytics,
                'Seguimiento visual',
                'Observa tus patrones de gasto con gráficos claros',
              ),
              const SizedBox(height: 12),
              _buildFeatureItem(
                context,
                Icons.category,
                'Categorización inteligente',
                'Organiza automáticamente tus transacciones',
              ),
              const SizedBox(height: 12),
              _buildFeatureItem(
                context,
                Icons.insights,
                'Insights personalizados',
                'Recibe consejos basados en tu comportamiento',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptySearchState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 80,
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No se encontraron resultados',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Intenta con otros términos de búsqueda',
            style: TextStyle(
              fontFamily: 'Inter',
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(
    BuildContext context,
    IconData icon,
    String title,
    String description,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 20,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.6),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _capitalizeFirstLetter(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }
}

class _FilterBottomSheet extends StatefulWidget {
  final String currentFilter;
  final String currentSort;
  final Function(String, String) onFilterChanged;

  const _FilterBottomSheet({
    required this.currentFilter,
    required this.currentSort,
    required this.onFilterChanged,
  });

  @override
  State<_FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<_FilterBottomSheet> {
  late String _selectedFilter;
  late String _selectedSort;

  @override
  void initState() {
    super.initState();
    _selectedFilter = widget.currentFilter;
    _selectedSort = widget.currentSort;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Filtrar Transacciones',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Tipo de transacción',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildFilterChip(
                'Todas',
                'all',
                _selectedFilter,
                Icons.all_inclusive,
              ),
              _buildFilterChip(
                'Ingresos',
                'income',
                _selectedFilter,
                Icons.arrow_upward,
              ),
              _buildFilterChip(
                'Gastos',
                'expense',
                _selectedFilter,
                Icons.arrow_downward,
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            'Ordenar por',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildFilterChip(
                'Más recientes',
                'recent',
                _selectedSort,
                Icons.access_time,
              ),
              _buildFilterChip(
                'Más antiguos',
                'oldest',
                _selectedSort,
                Icons.history,
              ),
              _buildFilterChip(
                'Monto (alto)',
                'amount_high',
                _selectedSort,
                Icons.attach_money,
              ),
              _buildFilterChip(
                'Monto (bajo)',
                'amount_low',
                _selectedSort,
                Icons.money_off,
              ),
            ],
          ),
          const SizedBox(height: 32),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    setState(() {
                      _selectedFilter = 'all';
                      _selectedSort = 'recent';
                    });
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Restablecer',
                    style: TextStyle(fontFamily: 'Inter'),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: () {
                    widget.onFilterChanged(_selectedFilter, _selectedSort);
                  },
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Aplicar',
                    style: TextStyle(fontFamily: 'Inter'),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildFilterChip(
    String label,
    String value,
    String selectedValue,
    IconData icon,
  ) {
    final isSelected = value == selectedValue;
    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [Icon(icon, size: 16), const SizedBox(width: 4), Text(label)],
      ),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          if (['all', 'income', 'expense'].contains(value)) {
            _selectedFilter = value;
          } else {
            _selectedSort = value;
          }
        });
      },
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHigh,
      selectedColor: Theme.of(
        context,
      ).colorScheme.primary.withValues(alpha: 0.1),
      checkmarkColor: Theme.of(context).colorScheme.primary,
      labelStyle: TextStyle(
        fontFamily: 'Inter',
        color: isSelected
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).colorScheme.onSurface,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
    );
  }
}
