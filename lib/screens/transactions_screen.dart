import 'package:dinerosync/models/transaction.dart';
import 'package:dinerosync/utils/number_formatter.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../providers/finance_provider.dart';
import '../widgets/new_transaction_item.dart';
import '../widgets/transaction_form.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  List<Transaction> _filteredTransactions = [];

  @override
  void dispose() {
    _searchController.dispose();
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

    final allTransactions = provider.groupedTransactions.values
        .expand((list) => list)
        .toList();

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: Consumer<FinanceProvider>(
        builder: (context, provider, child) {
          if (_isSearching) {
            return _buildSearchResults(context, _filteredTransactions);
          }

          final groupedTransactions = provider.groupedTransactions;

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
      title: _isSearching
          ? TextField(
              controller: _searchController,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Buscar transacciones...',
                hintStyle: TextStyle(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.5),
                ),
                border: InputBorder.none,
              ),
              style: const TextStyle(fontFamily: 'Inter'),
              onChanged: (query) =>
                  _filterTransactions(query, context.read<FinanceProvider>()),
            )
          : Text(
              'Transacciones',
              style: TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
      actions: [
        if (_isSearching)
          IconButton(
            icon: const Icon(Icons.close),
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
            icon: const Icon(Icons.search),
            onPressed: () {
              setState(() {
                _isSearching = true;
              });
            },
          ),
        if (!_isSearching)
          PopupMenuButton<String>(
            onSelected: (value) {
              _handleFilterSelection(value, context.read<FinanceProvider>());
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'all',
                child: Text('Todas las transacciones'),
              ),
              const PopupMenuItem(
                value: 'income',
                child: Text('Solo ingresos'),
              ),
              const PopupMenuItem(value: 'expense', child: Text('Solo gastos')),
              const PopupMenuItem(
                value: 'recent',
                child: Text('Más recientes primero'),
              ),
              const PopupMenuItem(
                value: 'oldest',
                child: Text('Más antiguos primero'),
              ),
            ],
            icon: const Icon(Icons.filter_list),
          ),
      ],
    );
  }

  Widget _buildTransactionList(
    BuildContext context,
    Map<String, List<Transaction>> groupedTransactions,
  ) {
    return ListView.separated(
      padding: const EdgeInsets.only(bottom: 100),
      itemCount: groupedTransactions.keys.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final dateKey = groupedTransactions.keys.elementAt(index);
        final transactionsForDay = groupedTransactions[dateKey]!;

        return _buildDayGroup(context, dateKey, transactionsForDay);
      },
    );
  }

  Widget _buildSearchResults(
    BuildContext context,
    List<Transaction> transactions,
  ) {
    if (transactions.isEmpty && _searchController.text.isNotEmpty) {
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

    final groupedSearchResults = _groupTransactionsByDate(transactions);

    return ListView.separated(
      padding: const EdgeInsets.only(bottom: 100),
      itemCount: groupedSearchResults.keys.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final dateKey = groupedSearchResults.keys.elementAt(index);
        final transactionsForDay = groupedSearchResults[dateKey]!;

        return _buildDayGroup(context, dateKey, transactionsForDay);
      },
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

    final incomeCount = transactions
        .where((t) => t.type == TransactionType.income)
        .length;
    final expenseCount = transactions
        .where((t) => t.type == TransactionType.expense)
        .length;

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
        tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.calendar_today,
            color: Theme.of(context).colorScheme.primary,
            size: 20,
          ),
        ),
        title: Text(
          _capitalizeFirstLetter(dateKey),
          style: const TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              '$incomeCount ingreso${incomeCount != 1 ? 's' : ''} • $expenseCount gasto${expenseCount != 1 ? 's' : ''}',
              style: TextStyle(
                fontFamily: 'Inter',
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.6),
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '${dayTotal >= 0 ? '+' : ''}${NumberFormatter.formatCurrency(dayTotal)}',
              style: TextStyle(
                fontFamily: 'Inter',
                color: dayTotal >= 0 ? Colors.green : Colors.red,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ],
        ),
        children: [
          const Divider(height: 1),
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
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          const SizedBox(height: 60),
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.receipt_long,
              size: 60,
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
              const SizedBox(height: 16),
              _buildFeatureItem(
                context,
                Icons.category,
                'Categorización inteligente',
                'Organiza automáticamente tus transacciones',
              ),
              const SizedBox(height: 16),
              _buildFeatureItem(
                context,
                Icons.insights,
                'Insights personalizados',
                'Recibe consejos basados en tu comportamiento',
              ),
            ],
          ),
          const SizedBox(height: 40),
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
            padding: const EdgeInsets.all(8),
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

  void _showAddTransactionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const TransactionForm(),
    );
  }

  void _handleFilterSelection(String value, FinanceProvider provider) {
    // Implement filter logic based on selection
    switch (value) {
      case 'income':
        // Filter to show only income
        break;
      case 'expense':
        // Filter to show only expenses
        break;
      case 'recent':
        // Sort by most recent
        break;
      case 'oldest':
        // Sort by oldest
        break;
      default:
        // Show all
        break;
    }
  }

  String _capitalizeFirstLetter(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }
}
