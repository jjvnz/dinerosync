import 'package:dinerosync/models/transaction.dart';
import 'package:dinerosync/utils/number_formatter.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import '../providers/finance_provider.dart';
import '../widgets/new_transaction_item.dart';
import '../widgets/transaction_form.dart';

class TransactionsScreen extends StatelessWidget {
  const TransactionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Transacciones',
          style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Implement search functionality
            },
          ),
        ],
      ),
      body: Consumer<FinanceProvider>(
        builder: (context, provider, child) {
          final groupedTransactions = provider.groupedTransactions;

          if (groupedTransactions.isEmpty) {
            return _buildEmptyState(context);
          }

          return ListView.separated(
            padding: const EdgeInsets.only(bottom: 100), // Padding para el FAB
            itemCount: groupedTransactions.keys.length,
            separatorBuilder: (context, index) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final dateKey = groupedTransactions.keys.elementAt(index);
              final transactionsForDay = groupedTransactions[dateKey]!;

              return _buildDayGroup(context, dateKey, transactionsForDay);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTransactionSheet(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildDayGroup(
    BuildContext context,
    String dateKey,
    List<Transaction> transactions,
  ) {
    double dayTotal = transactions.fold(
      0,
      (sum, t) =>
          t.type == TransactionType.income ? sum + t.amount : sum - t.amount,
    );

    return ExpansionTile(
      tilePadding: const EdgeInsets.symmetric(horizontal: 16),
      title: Text(
        dateKey,
        style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.bold, fontSize: 16),
      ),
      subtitle: Text(
        '${dayTotal >= 0 ? '+' : ''}${NumberFormatter.formatCurrency(dayTotal)}',
        style: TextStyle(
          fontFamily: 'Inter',
          color: dayTotal >= 0 ? Colors.green : Colors.red,
          fontWeight: FontWeight.w600,
        ),
      ),
      children: transactions.map((transaction) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
          child: NewTransactionItem(transaction: transaction),
        );
      }).toList(),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long,
              size: 80,
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 24),
            Text(
              '¡Aquí aparecerán tus transacciones!',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Empieza a registrar tus gastos e ingresos para ver tu actividad financiera.',
              style: TextStyle(
                fontFamily: 'Inter',
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => _showAddTransactionSheet(context),
              icon: const Icon(Icons.add),
              label: const Text('Añadir Transacción'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddTransactionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => const TransactionForm(),
    );
  }
}
