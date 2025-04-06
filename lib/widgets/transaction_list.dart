import 'package:dinerosync/models/transaction.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/finance_provider.dart';
import 'transaction_item.dart';

class TransactionList extends StatelessWidget {
  const TransactionList({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final provider = Provider.of<FinanceProvider>(context);
    final transactions = provider.transactions;

    if (transactions.isEmpty) {
      return _buildEmptyState(theme, colorScheme);
    }

    return _buildTransactionList(transactions);
  }

  Widget _buildEmptyState(ThemeData theme, ColorScheme colorScheme) {
    final emptyStateColor = Color.alphaBlend(
      colorScheme.outline.withAlpha(127),
      colorScheme.surface,
    );

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long,
            size: 60,
            color: emptyStateColor,
          ),
          const SizedBox(height: 16),
          Text(
            'No hay transacciones registradas',
            style: theme.textTheme.titleMedium?.copyWith(
              color: emptyStateColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Presiona el botón + para agregar una',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: emptyStateColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionList(List<Transaction> transactions) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: transactions.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final transaction = transactions[index];
        return TransactionItem(transaction: transaction);
      },
    );
  }
}