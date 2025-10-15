import 'package:dinerosync/models/category.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/transaction.dart';
import '../providers/finance_provider.dart';
import 'transaction_form.dart';
import '../utils/number_formatter.dart';

/// Widget that represents a transaction item in the list.
///
/// Displays [Transaction] information in an interactive card that allows
/// viewing details, editing, and deleting the transaction through
/// swipe gestures.
class TransactionItem extends StatelessWidget {
  /// The transaction to be displayed in this item.
  final Transaction transaction;

  /// Creates a new transaction item.
  ///
  /// Requires a valid [transaction] to display its information.
  const TransactionItem({super.key, required this.transaction});

  /// Builds the visual interface of the transaction item.
  ///
  /// Creates a swipeable card that displays transaction information
  /// with differentiated colors based on type (income/expense).
  @override
  Widget build(BuildContext context) {
    final isIncome = transaction.type == TransactionType.income;
    final colorScheme = Theme.of(context).colorScheme;
    final accentColor = isIncome ? Colors.green : Colors.red;

    return Dismissible(
      key: Key(transaction.id),
      background: _buildDismissBackground(context),
      secondaryBackground: _buildDismissBackground(context, isSecondary: true),
      confirmDismiss: (direction) => _confirmDismiss(context),
      onDismissed: (direction) => _handleDismiss(context),
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 4.0),
        elevation: 0.5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        color: colorScheme.surface,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => _showTransactionDetails(context, transaction),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                // Icono mejorado
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha:0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    isIncome ? Icons.arrow_upward : Icons.arrow_downward,
                    color: accentColor,
                    size: 24,
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
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: transaction.category.color.withValues(alpha:0.12),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Icon(
                              transaction.category.icon,
                              size: 12,
                              color: transaction.category.color,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              transaction.category.name,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurface.withValues(alpha:0.7),
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            Icons.access_time_rounded,
                            size: 12,
                            color: colorScheme.onSurface.withValues(alpha:0.5),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            DateFormat('dd MMM, HH:mm').format(transaction.date),
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurface.withValues(alpha:0.7),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),

                // Monto y tipo con mejor diseño
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      NumberFormatter.formatCurrency(transaction.amount),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: accentColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: accentColor.withValues(alpha:0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        isIncome ? 'Ingreso' : 'Gasto',
                        style: TextStyle(
                          fontSize: 12,
                          color: accentColor,
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

  /// Builds the visual background for the swipe gesture.
  ///
  /// Shows a visual deletion indicator when the user swipes the item.
  /// The [isSecondary] parameter determines the content alignment.
  Widget _buildDismissBackground(
    BuildContext context, {
    bool isSecondary = false,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha:0.15),
        borderRadius: BorderRadius.circular(14),
      ),
      alignment: isSecondary ? Alignment.centerLeft : Alignment.centerRight,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isSecondary) ...[
            const Icon(Icons.delete_outline, color: Colors.red, size: 24),
            const SizedBox(width: 8),
            const Text(
              'Eliminar',
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.w600,
              ),
            ),
          ] else ...[
            const Text(
              'Eliminar',
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.delete_outline, color: Colors.red, size: 24),
          ]
        ],
      ),
    );
  }

  /// Shows a confirmation dialog to delete the transaction.
  ///
  /// Returns `true` if the user confirms deletion, `false` if canceled,
  /// or `null` if the dialog is dismissed.
  Future<bool?> _confirmDismiss(BuildContext context) async {
    return await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text('Eliminar transacción'),
        content: const Text(
          '¿Estás seguro de que quieres eliminar esta transacción?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton.tonal(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red.withValues(alpha:0.1),
            ),
            child: const Text(
              'Eliminar',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  /// Handles transaction deletion after confirming the gesture.
  ///
  /// Removes the transaction from [FinanceProvider] and shows a
  /// [SnackBar] with an undo option.
  void _handleDismiss(BuildContext context) {
    Provider.of<FinanceProvider>(
      context,
      listen: false,
    ).deleteTransaction(transaction.id);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Transacción eliminada'),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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

  /// Shows complete transaction details in a modal.
  ///
  /// Presents detailed information of the [transaction] in a
  /// [ModalBottomSheet] with options to close or edit.
  void _showTransactionDetails(BuildContext context, Transaction transaction) {
    final isIncome = transaction.type == TransactionType.income;
    final colorScheme = Theme.of(context).colorScheme;
    final accentColor = isIncome ? Colors.green : Colors.red;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(28),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha:0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle para arrastrar mejorado
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: colorScheme.outline.withValues(alpha:0.3),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 24),

            // Encabezado con mejor jerarquía visual
            Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha:0.12),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    isIncome ? Icons.arrow_upward : Icons.arrow_downward,
                    color: accentColor,
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
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            size: 14,
                            color: colorScheme.onSurface.withValues(alpha:0.6),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            DateFormat('EEEE, d MMMM y').format(transaction.date),
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurface.withValues(alpha:0.7),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Icon(
                            Icons.access_time,
                            size: 14,
                            color: colorScheme.onSurface.withValues(alpha:0.6),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            DateFormat('HH:mm').format(transaction.date),
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurface.withValues(alpha:0.7),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Detalles en tarjetas con mejor diseño
            Card(
              margin: EdgeInsets.zero,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: colorScheme.outline.withValues(alpha:0.1)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Detalles de la transacción',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildDetailRow(
                      context,
                      'Monto',
                      Text(
                        NumberFormatter.formatCurrency(transaction.amount),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: accentColor,
                        ),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Divider(),
                    ),
                    _buildDetailRow(
                      context,
                      'Tipo',
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: accentColor.withValues(alpha:0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              isIncome ? 'Ingreso' : 'Gasto',
                              style: TextStyle(
                                color: accentColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Divider(),
                    ),
                    _buildDetailRow(
                      context,
                      'Categoría',
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: transaction.category.color.withValues(alpha:0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              transaction.category.icon,
                              color: transaction.category.color,
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            transaction.category.name,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Botones de acción mejorados
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded),
                    label: const Text('Cerrar'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _showEditForm(context, transaction);
                    },
                    icon: const Icon(Icons.edit_rounded),
                    label: const Text('Editar'),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Builds a detail row with label and value.
  ///
  /// Creates a formatted row that displays a [label] and its corresponding
  /// [value] with appropriate theme styling.
  Widget _buildDetailRow(BuildContext context, String label, Widget value) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha:0.7),
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: DefaultTextStyle(
            style: Theme.of(context).textTheme.bodyLarge!,
            child: value,
          ),
        ),
      ],
    );
  }

/// Shows the edit form for the transaction.
///
/// Presents a [TransactionForm] in a modal to edit the [transaction].
/// Uses [WidgetsBinding.instance.addPostFrameCallback] to ensure
/// the context is valid before showing the modal.
void _showEditForm(BuildContext context, Transaction transaction) {
  // Wait for next frame to ensure valid context
  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (!context.mounted) return;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black54,
      builder: (BuildContext sheetContext) {
        return GestureDetector(
          onTap: () => Navigator.pop(sheetContext),
          behavior: HitTestBehavior.opaque,
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
              ),
              child: Container(
                margin: const EdgeInsets.only(left: 16, right: 16, top: 24),
                decoration: BoxDecoration(
                  color: Theme.of(sheetContext).colorScheme.surface,
                  borderRadius: BorderRadius.circular(28),
                ),
                child: TransactionForm(transaction: transaction),
              ),
            ),
          ),
        );
      },
    );
  });
}
}
