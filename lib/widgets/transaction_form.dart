import 'package:dinerosync/models/category.dart';
import 'package:dinerosync/models/transaction.dart';
import 'package:dinerosync/providers/finance_provider.dart';
import 'package:dinerosync/utils/number_formatter.dart';
import 'package:dinerosync/widgets/category_selector.dart';
import 'package:dinerosync/widgets/custom_keypad.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class TransactionForm extends StatefulWidget {
  final Transaction? transaction;
  const TransactionForm({super.key, this.transaction});

  @override
  State<TransactionForm> createState() => _TransactionFormState();
}

class _TransactionFormState extends State<TransactionForm> {
  final _descriptionController = TextEditingController();
  TransactionType _selectedType = TransactionType.expense;
  Category _selectedCategory = Category.food;
  DateTime _selectedDate = DateTime.now();
  String _amountString = '0';

  @override
  void initState() {
    super.initState();
    if (widget.transaction != null) {
      final t = widget.transaction!;
      _selectedType = t.type;
      _selectedCategory = t.category;
      _selectedDate = t.date;
      _amountString = t.amount.toStringAsFixed(2);
      _descriptionController.text = t.description;
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  void _onKeyPressed(String key) {
    setState(() {
      if (key == 'backspace') {
        if (_amountString.length > 1) {
          _amountString = _amountString.substring(0, _amountString.length - 1);
        } else {
          _amountString = '0';
        }
      } else {
        if (_amountString == '0' && key != '.') {
          _amountString = key;
        } else {
          _amountString += key;
        }
      }
    });
  }

  double get _amount {
    try {
      return double.parse(_amountString);
    } catch (e) {
      return 0.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DraggableScrollableSheet(
      initialChildSize: 0.95,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      expand: false,
      builder: (_, controller) => Container(
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        // --- NUEVA ESTRUCTURA CLAVE ---
        child: Column(
          mainAxisSize: MainAxisSize.min, // Ocupa el mínimo espacio posible
          children: [
            // 1. Header (tamaño fijo)
            _buildHeader(context),

            // 2. Contenido desplazable (ocupa el espacio disponible)
            Expanded(
              child: ListView(
                controller: controller,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _buildAmountDisplay(theme),
                  const SizedBox(height: 24),
                  _buildTypeSelector(theme),
                  const SizedBox(height: 24),
                  CategorySelector(
                    selectedCategory: _selectedCategory,
                    onCategorySelected: (cat) =>
                        setState(() => _selectedCategory = cat),
                  ),
                  const SizedBox(height: 24),
                  _buildDetailsSection(theme),
                  const SizedBox(
                    height: 16,
                  ), // Padding para que no toque el teclado
                ],
              ),
            ),

            // 3. Teclado numérico (tamaño fijo en la parte inferior)
            CustomKeypad(
              onKeyPressed: _onKeyPressed,
              onSubmit: () => _submitForm(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close),
          ),
          Text(
            widget.transaction == null
                ? 'Nueva Transacción'
                : 'Editar Transacción',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildAmountDisplay(ThemeData theme) {
    return Column(
      children: [
        Text(
          '\$${NumberFormatter.formatCurrency(_amount).replaceAll('\$', '')}',
          style: theme.textTheme.displayLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildTypeSelector(ThemeData theme) {
    return SegmentedButton<TransactionType>(
      segments: const [
        ButtonSegment(
          value: TransactionType.income,
          icon: Icon(Icons.arrow_upward),
          label: Text('Ingreso'),
        ),
        ButtonSegment(
          value: TransactionType.expense,
          icon: Icon(Icons.arrow_downward),
          label: Text('Gasto'),
        ),
      ],
      selected: {_selectedType},
      onSelectionChanged: (Set<TransactionType> newSelection) {
        setState(() => _selectedType = newSelection.first);
      },
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.resolveWith<Color>((states) {
          if (states.contains(WidgetState.selected)) {
            return _selectedType == TransactionType.income
                ? Colors.green.withValues(alpha: 0.1)
                : Colors.red.withValues(alpha: 0.1);
          }
          return theme.colorScheme.surfaceContainerHighest;
        }),
      ),
    );
  }

  Widget _buildDetailsSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Descripción', style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        TextField(
          controller: _descriptionController,
          decoration: const InputDecoration(hintText: '¿Qué fue esto?'),
        ),
        const SizedBox(height: 16),
        Text('Fecha', style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        InkWell(
          onTap: () => _selectDate(context),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(DateFormat('dd MMMM yyyy').format(_selectedDate)),
                Icon(
                  Icons.calendar_month,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _submitForm(BuildContext context) async {
    if (_amount == 0 || _descriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, completa el monto y la descripción.'),
        ),
      );
      return;
    }

    final transaction = Transaction(
      id: widget.transaction?.id ?? const Uuid().v4(),
      type: _selectedType,
      amount: _amount,
      category: _selectedCategory,
      description: _descriptionController.text,
      date: _selectedDate,
    );

    final provider = Provider.of<FinanceProvider>(context, listen: false);
    final navigator = Navigator.of(context);
    await provider.addTransaction(transaction);
    if (mounted) navigator.pop();
  }
}
