import 'package:dinerosync/models/category.dart';
import 'package:dinerosync/models/transaction.dart';
import 'package:dinerosync/providers/finance_provider.dart';
import 'package:dinerosync/utils/number_formatter.dart';
import 'package:dinerosync/widgets/transaction_form.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class NewTransactionItem extends StatelessWidget {
  final Transaction transaction;

  const NewTransactionItem({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isIncome = transaction.type == TransactionType.income;
    final accentColor = isIncome ? Colors.green : Colors.red;

    return Dismissible(
      key: Key(transaction.id),
      background: _buildSwipeBackground(
        context,
        alignment: Alignment.centerLeft,
        color: Colors.blue,
        icon: Icons.edit_rounded,
        label: 'Editar',
      ),
      secondaryBackground: _buildSwipeBackground(
        context,
        alignment: Alignment.centerRight,
        color: Colors.red,
        icon: Icons.delete_rounded,
        label: 'Eliminar',
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.endToStart) {
          // Eliminar
          return await _showDeleteConfirmation(context);
        }
        if (direction == DismissDirection.startToEnd) {
          // Editar
          _navigateToEditForm(context);
          return false; // No descartar el ítem, solo navegar
        }
        return false;
      },
      onDismissed: (direction) {
        if (direction == DismissDirection.endToStart) {
          _handleDelete(context);
        }
      },
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 4.0),
        elevation: 0.5,
        color: colorScheme.surface,
        surfaceTintColor: colorScheme.surfaceTint,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _showTransactionDetails(context),
          child: Container(
            decoration: BoxDecoration(
              border: Border(
                left: BorderSide(color: accentColor.withValues(alpha: 0.6), width: 4),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Icono con gradiente mejorado
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          transaction.category.color.withValues(alpha: 0.15),
                          transaction.category.color.withValues(alpha: 0.05),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      transaction.category.icon,
                      color: transaction.category.color,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Información principal
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          transaction.description,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Inter',
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            // Chip de categoría
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: transaction.category.color.withValues(
                                  alpha: 0.1,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    transaction.category.icon,
                                    size: 12,
                                    color: transaction.category.color,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    transaction.category.name,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: colorScheme.onSurface.withValues(
                                        alpha: 0.8,
                                      ),
                                      fontWeight: FontWeight.w500,
                                      fontFamily: 'Inter',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Hora de la transacción
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: colorScheme.surfaceContainerHigh,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.access_time_rounded,
                                    size: 10,
                                    color: colorScheme.onSurface.withValues(
                                      alpha: 0.5,
                                    ),
                                  ),
                                  const SizedBox(width: 2),
                                  Text(
                                    DateFormat(
                                      'HH:mm',
                                    ).format(transaction.date),
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: colorScheme.onSurface.withValues(
                                        alpha: 0.7,
                                      ),
                                      fontFamily: 'Inter',
                                      fontSize: 10,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Monto y tipo
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${isIncome ? '+' : '-'}${NumberFormatter.formatCurrency(transaction.amount)}',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: accentColor,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: accentColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: accentColor.withValues(alpha: 0.2),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          isIncome ? 'INGRESO' : 'GASTO',
                          style: TextStyle(
                            fontSize: 10,
                            color: accentColor,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'Inter',
                            letterSpacing: 0.5,
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
      ),
    );
  }

  void _navigateToEditForm(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => TransactionForm(transaction: transaction),
        fullscreenDialog: true,
      ),
    );
  }

  Widget _buildSwipeBackground(
    BuildContext context, {
    required Alignment alignment,
    required Color color,
    required IconData icon,
    required String label,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      alignment: alignment,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 28),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontFamily: 'Inter',
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Future<bool> _showDeleteConfirmation(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            backgroundColor: Theme.of(context).colorScheme.surface,
            surfaceTintColor: Theme.of(context).colorScheme.surfaceTint,
            icon: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.delete_rounded,
                color: Colors.red,
                size: 32,
              ),
            ),
            title: const Text(
              'Eliminar transacción',
              style: TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            content: const Text(
              '¿Estás seguro de que quieres eliminar esta transacción? Esta acción no se puede deshacer.',
              style: TextStyle(fontFamily: 'Inter'),
              textAlign: TextAlign.center,
            ),
            actions: [
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(ctx).pop(false),
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text(
                        'Cancelar',
                        style: TextStyle(fontFamily: 'Inter'),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: () => Navigator.of(ctx).pop(true),
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text(
                        'Eliminar',
                        style: TextStyle(fontFamily: 'Inter'),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ) ??
        false;
  }

  void _handleDelete(BuildContext context) {
    final provider = Provider.of<FinanceProvider>(context, listen: false);
    provider.deleteTransaction(transaction.id);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          'Transacción eliminada',
          style: TextStyle(fontFamily: 'Inter'),
        ),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerHigh,
        action: SnackBarAction(
          label: 'Deshacer',
          textColor: Theme.of(context).colorScheme.primary,
          onPressed: () {
            provider.addTransaction(transaction);
          },
        ),
      ),
    );
  }

  void _showTransactionDetails(BuildContext context) {
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
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle para arrastrar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: colorScheme.outline.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Encabezado
            Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        transaction.category.color.withValues(alpha: 0.15),
                        transaction.category.color.withValues(alpha: 0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Icon(
                    transaction.category.icon,
                    color: transaction.category.color,
                    size: 32,
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
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Inter',
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 12,
                        runSpacing: 6,
                        children: [
                          _buildInfoChip(
                            context,
                            Icons.calendar_today,
                            DateFormat('EEE, d MMM y').format(transaction.date),
                          ),
                          _buildInfoChip(
                            context,
                            Icons.access_time,
                            DateFormat('HH:mm').format(transaction.date),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Tarjeta de detalles
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Detalles de la transacción',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Inter',
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildDetailItem(
                    context,
                    'Monto',
                    Text(
                      '${isIncome ? '+' : '-'}${NumberFormatter.formatCurrency(transaction.amount)}',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: accentColor,
                        fontFamily: 'Inter',
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildDetailItem(
                    context,
                    'Tipo',
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: accentColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: accentColor.withValues(alpha: 0.2)),
                      ),
                      child: Text(
                        isIncome ? 'INGRESO' : 'GASTO',
                        style: TextStyle(
                          color: accentColor,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                          fontFamily: 'Inter',
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildDetailItem(
                    context,
                    'Categoría',
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: transaction.category.color.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            transaction.category.icon,
                            color: transaction.category.color,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          transaction.category.name,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                fontWeight: FontWeight.w500,
                                fontFamily: 'Inter',
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Botones de acción
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      side: BorderSide(
                        color: colorScheme.outline.withValues(alpha: 0.3),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.close_rounded, size: 20),
                        SizedBox(width: 8),
                        Text('Cerrar', style: TextStyle(fontFamily: 'Inter')),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: FilledButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _navigateToEditForm(context);
                    },
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.edit_rounded, size: 20),
                        SizedBox(width: 8),
                        Text('Editar', style: TextStyle(fontFamily: 'Inter')),
                      ],
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

  Widget _buildInfoChip(BuildContext context, IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12,
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
              fontFamily: 'Inter',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(BuildContext context, String label, Widget value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
            fontWeight: FontWeight.w500,
            fontFamily: 'Inter',
          ),
        ),
        const SizedBox(height: 8),
        value,
      ],
    );
  }
}
