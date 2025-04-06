import 'package:dinerosync/models/category.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/transaction.dart';
import '../providers/finance_provider.dart';
import 'transaction_form.dart';
import '../utils/number_formatter.dart';

class TransactionItem extends StatelessWidget {
  final Transaction transaction;

  const TransactionItem({required this.transaction});

  @override
  Widget build(BuildContext context) {
    final isIncome = transaction.type == TransactionType.income;
    final colorScheme = Theme.of(context).colorScheme;

    return Dismissible(
      key: Key(transaction.id),
      background: _buildDismissBackground(context),
      secondaryBackground: _buildDismissBackground(context, isSecondary: true),
      confirmDismiss: (direction) => _confirmDismiss(context),
      onDismissed: (direction) => _handleDismiss(context),
      child: Card(
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        color: colorScheme.surface,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _showTransactionDetails(context, transaction),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Icono
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color:
                        isIncome
                            ? Colors.green.withValues(alpha: 0.0)
                            : Colors.red.withValues(alpha: 0.0),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    isIncome ? Icons.arrow_upward : Icons.arrow_downward,
                    color: isIncome ? Colors.green : Colors.red,
                  ),
                ),
                const SizedBox(width: 16),

                // Descripción y detalles
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        transaction.description,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(
                            transaction.category.icon,
                            size: 16,
                            color: transaction.category.color,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              transaction.category.name,
                              style: Theme.of(
                                context,
                              ).textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurface.withValues(
                                  alpha: 0.6,
                                ),
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                          const SizedBox(width: 4), // Small spacing before date
                          Text(
                            DateFormat(
                              'dd MMM, HH:mm',
                            ).format(transaction.date),
                            style: Theme.of(
                              context,
                            ).textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurface.withValues(
                                alpha: 0.6,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),

                // Monto y tipo
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      NumberFormatter.formatCurrency(transaction.amount),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: isIncome ? Colors.green : Colors.red,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color:
                            isIncome
                                ? Colors.green.withValues(alpha: 0.0)
                                : Colors.red.withValues(alpha: 0.0),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        isIncome ? 'Ingreso' : 'Gasto',
                        style: TextStyle(
                          fontSize: 12,
                          color: isIncome ? Colors.green : Colors.red,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDismissBackground(
    BuildContext context, {
    bool isSecondary = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: isSecondary ? Alignment.centerLeft : Alignment.centerRight,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Icon(Icons.delete, color: Colors.red, size: 24),
    );
  }

  Future<bool?> _confirmDismiss(BuildContext context) async {
    return await showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Eliminar transacción'),
            content: const Text(
              '¿Estás seguro de que quieres eliminar esta transacción?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                child: const Text(
                  'Eliminar',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );
  }

  void _handleDismiss(BuildContext context) {
    Provider.of<FinanceProvider>(
      context,
      listen: false,
    ).deleteTransaction(transaction.id);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Transacción eliminada'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        action: SnackBarAction(
          label: 'Deshacer',
          textColor: Theme.of(context).colorScheme.primary,
          onPressed: () {
            Provider.of<FinanceProvider>(
              context,
              listen: false,
            ).addTransaction(transaction);
          },
        ),
      ),
    );
  }

  void _showTransactionDetails(BuildContext context, Transaction transaction) {
    final isIncome = transaction.type == TransactionType.income;
    final colorScheme = Theme.of(context).colorScheme;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder:
          (context) => Container(
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle para arrastrar
                Center(
                  child: Container(
                    width: 48,
                    height: 4,
                    decoration: BoxDecoration(
                      color: colorScheme.outline.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Encabezado
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color:
                            isIncome
                                ? Colors.green.withValues(alpha: 0.0)
                                : Colors.red.withValues(alpha: 0.0),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        isIncome ? Icons.arrow_upward : Icons.arrow_downward,
                        color: isIncome ? Colors.green : Colors.red,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            transaction.description,
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.bold),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            DateFormat(
                              'EEEE, d MMMM y - HH:mm',
                            ).format(transaction.date),
                            style: Theme.of(
                              context,
                            ).textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurface.withValues(
                                alpha: 0.6,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Detalles en tarjetas
                Card(
                  margin: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _buildDetailRow(
                          context,
                          'Monto',
                          Text(
                            NumberFormatter.formatCurrency(transaction.amount),
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: isIncome ? Colors.green : Colors.red,
                            ),
                          ),
                        ),
                        const Divider(height: 24),
                        _buildDetailRow(
                          context,
                          'Tipo',
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      isIncome
                                          ? Colors.green.withValues(alpha: 0.0)
                                          : Colors.red.withValues(alpha: 0.0),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  isIncome ? 'Ingreso' : 'Gasto',
                                  style: TextStyle(
                                    color: isIncome ? Colors.green : Colors.red,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Divider(height: 24),
                        _buildDetailRow(
                          context,
                          'Categoría',
                          Row(
                            children: [
                              Icon(
                                transaction.category.icon,
                                color: transaction.category.color,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(transaction.category.name),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Botones de acción
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Cerrar'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _showEditForm(context, transaction);
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Editar'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, Widget value) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: DefaultTextStyle(
            style: Theme.of(context).textTheme.bodyMedium!,
            child: value,
          ),
        ),
      ],
    );
  }

  void _showEditForm(BuildContext context, Transaction transaction) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (_) => Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              left: 16,
              right: 16,
              top: 24,
            ),
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
              ),
              child: TransactionForm(transaction: transaction),
            ),
          ),
    );
  }
}
