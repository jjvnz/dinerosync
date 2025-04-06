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
    
    // Add padding around entire list for better edge spacing
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: transactions.isEmpty
          ? _buildEmptyState(theme, colorScheme)
          : _buildTransactionList(transactions, theme),
    );
  }

  Widget _buildEmptyState(ThemeData theme, ColorScheme colorScheme) {
    final emptyStateColor = Color.alphaBlend(
      colorScheme.outline.withAlpha(127),
      colorScheme.surface,
    );

    // Added Card with shadow for better visual hierarchy
    return Card(
      elevation: 1,
      margin: const EdgeInsets.symmetric(vertical: 20.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
        side: BorderSide(color: colorScheme.outline.withValues(alpha: 0.1)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long,
              size: 72, // Increased size for better visibility
              color: emptyStateColor,
            ),
            const SizedBox(height: 24), // Increased spacing
            Text(
              'No hay transacciones registradas',
              style: theme.textTheme.titleLarge?.copyWith( // Increased text size
                color: emptyStateColor,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12), // Adjusted spacing
            Text(
              'Presiona el botón + para agregar una',
              style: theme.textTheme.bodyLarge?.copyWith( // Increased text size
                color: emptyStateColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            // Added action button for better UX
            FilledButton.icon(
              onPressed: () {}, // Connect to add transaction function
              icon: const Icon(Icons.add),
              label: const Text('Nueva Transacción'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionList(List<Transaction> transactions, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Added section header for better organization
        Padding(
          padding: const EdgeInsets.only(left: 8.0, top: 16.0, bottom: 12.0),
          child: Text(
            'Transacciones Recientes',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: transactions.length,
          separatorBuilder: (context, index) => const Divider(height: 1), // Changed to divider for cleaner separation
          itemBuilder: (context, index) {
            final transaction = transactions[index];
            // Added Card wrapper for better visual hierarchy
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 4.0),
              elevation: 0.5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: TransactionItem(transaction: transaction),
              ),
            );
          },
        ),
        // Added bottom padding for better scrolling experience
        const SizedBox(height: 24),
      ],
    );
  }
}