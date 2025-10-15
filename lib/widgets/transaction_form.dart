import 'package:dinerosync/models/category.dart';
import 'package:dinerosync/models/transaction.dart';
import 'package:dinerosync/providers/finance_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

/// Form widget for creating and editing transactions.
///
/// Provides input fields for amount, description, category, type, and date.
/// When [transaction] is provided, the form operates in edit mode,
/// otherwise it creates a new transaction.
class TransactionForm extends StatefulWidget {
  /// The transaction to edit, or null to create a new one.
  final Transaction? transaction;

  /// Creates a new transaction form.
  ///
  /// If [transaction] is provided, the form will be pre-filled with
  /// the transaction's data for editing.
  const TransactionForm({super.key, this.transaction});

  @override
  TransactionFormState createState() => TransactionFormState();
}

/// State class for [TransactionForm].
///
/// Manages form validation, input formatting, and transaction submission.
class TransactionFormState extends State<TransactionForm> {
  /// Form key for validation.
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  
  /// Controller for the amount input field.
  final TextEditingController _amountController = TextEditingController();
  
  /// Controller for the description input field.
  final TextEditingController _descriptionController = TextEditingController();
  
  /// Currently selected transaction type.
  TransactionType _selectedType = TransactionType.expense;
  
  /// Currently selected category.
  Category _selectedCategory = Category.food;
  
  /// Currently selected date and time.
  DateTime _selectedDate = DateTime.now();
  
  /// Whether the form is currently being submitted.
  bool _isSubmitting = false;
  
  /// Number formatter for currency display.
  final NumberFormat _currencyFormat = NumberFormat.decimalPattern('es_ES');

  /// Initializes the form state.
  ///
  /// Sets up form fields and adds listeners for amount formatting.
  @override
  void initState() {
    super.initState();
    _updateFormFields();
    _amountController.addListener(_formatAmount);
  }

  /// Formats the amount input as the user types.
  ///
  /// Applies currency formatting to maintain consistent number display.
  void _formatAmount() {
    final String text = _amountController.text;

    if (text.isEmpty) {
      return;
    }

    try {
      final double value = _currencyFormat.parse(text).toDouble();
      final String formattedText = _currencyFormat.format(value);

      if (text != formattedText) {
        _amountController.value = TextEditingValue(
          text: formattedText,
          selection: TextSelection.collapsed(offset: formattedText.length),
        );
      }
    } catch (e) {
      // Ignore temporary input errors.
    }
  }

  /// Updates form fields with transaction data.
  ///
  /// Populates all form fields when editing an existing transaction,
  /// or clears them when creating a new one.
  void _updateFormFields() {
    final transaction = widget.transaction;
    if (transaction != null) {
      _selectedType = transaction.type;
      _selectedCategory = transaction.category;
      _selectedDate = transaction.date;
      _amountController.text = _currencyFormat.format(transaction.amount);
      _descriptionController.text = transaction.description;
    } else {
      _amountController.clear();
      _descriptionController.clear();
    }
  }

  /// Updates form fields when the widget is rebuilt with different data.
  ///
  /// Refreshes form fields if the [transaction] property changes.
  @override
  void didUpdateWidget(covariant TransactionForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.transaction != oldWidget.transaction) {
      _updateFormFields();
    }
  }

  /// Cleans up resources when the widget is disposed.
  ///
  /// Removes listeners and disposes of text controllers.
  @override
  void dispose() {
    _amountController.removeListener(_formatAmount);
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  /// Builds the transaction form interface.
  ///
  /// Creates a scrollable form with input fields for all transaction
  /// properties and handles form submission.
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final surfaceVariant = colorScheme.surfaceContainerHighest;
    final surfaceVariantLight = Color.alphaBlend(
      surfaceVariant.withAlpha(100),
      colorScheme.surface,
    );

    return PopScope(
      canPop: !_isSubmitting,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                widget.transaction == null
                    ? 'Nueva Transacción'
                    : 'Editar Transacción',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              _buildTypeSelector(surfaceVariant),
              const SizedBox(height: 20),
              _buildAmountField(surfaceVariantLight),
              const SizedBox(height: 16),
              _buildCategoryDropdown(surfaceVariantLight),
              const SizedBox(height: 16),
              _buildDescriptionField(surfaceVariantLight),
              const SizedBox(height: 16),
              _buildDateSelector(context),
              const SizedBox(height: 24),
              _buildSubmitButton(context),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the transaction type selector.
  ///
  /// Creates a segmented button to choose between income and expense
  /// with appropriate colors for each type.
  Widget _buildTypeSelector(Color surfaceVariant) {
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
        if (newSelection.isNotEmpty && mounted) {
          setState(() => _selectedType = newSelection.first);
        }
      },
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.resolveWith<Color>((states) {
          if (states.contains(WidgetState.selected)) {
            return _selectedType == TransactionType.income
                ? Colors.green.withValues(alpha: 0.1)
                : Colors.red.withValues(alpha: 0.1);
          }
          return surfaceVariant;
        }),
      ),
    );
  }

  /// Builds the amount input field.
  ///
  /// Creates a validated text field with currency formatting and
  /// numeric keyboard input.
  Widget _buildAmountField(Color surfaceVariantLight) {
    return TextFormField(
      controller: _amountController,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: 'Monto',
        prefixText: '\$ ',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        fillColor: surfaceVariantLight,
        filled: true,
        suffixIcon: const Icon(Icons.attach_money),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) return 'Ingrese un monto';
        try {
          final amount = _currencyFormat.parse(value).toDouble();
          if (amount <= 0) return 'El monto debe ser mayor a cero';
        } catch (e) {
          return 'Monto inválido';
        }
        return null;
      },
    );
  }

  /// Builds the category selection dropdown.
  ///
  /// Creates a dropdown with all available categories, showing
  /// icons and names for each option.
  Widget _buildCategoryDropdown(Color surfaceVariantLight) {
    return DropdownButtonFormField<Category>(
      initialValue: _selectedCategory,
      items:
          Category.values.map((category) {
            return DropdownMenuItem(
              value: category,
              child: Row(
                children: [
                  Icon(category.icon, color: category.color, size: 20),
                  const SizedBox(width: 12),
                  Text(category.name),
                ],
              ),
            );
          }).toList(),
      onChanged: (Category? value) {
        if (value != null && mounted) {
          setState(() => _selectedCategory = value);
        }
      },
      decoration: InputDecoration(
        labelText: 'Categoría',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        fillColor: surfaceVariantLight,
        filled: true,
      ),
    );
  }

  /// Builds the description input field.
  ///
  /// Creates a validated text field for transaction description
  /// with character limit and minimum length validation.
  Widget _buildDescriptionField(Color surfaceVariantLight) {
    return TextFormField(
      controller: _descriptionController,
      decoration: InputDecoration(
        labelText: 'Descripción',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        fillColor: surfaceVariantLight,
        filled: true,
        suffixIcon: const Icon(Icons.description),
      ),
      maxLength: 100,
      validator: (value) {
        if (value == null || value.isEmpty) return 'Ingrese una descripción';
        if (value.length < 3) return 'Mínimo 3 caracteres';
        return null;
      },
    );
  }

  /// Builds the date and time selector.
  ///
  /// Creates a tappable container that shows the selected date
  /// and opens a date picker when tapped.
  Widget _buildDateSelector(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return InkWell(
      onTap: () => _selectDate(context),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: theme.dividerColor.withValues(alpha: 0.0)),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today,
              color: colorScheme.onSurface.withValues(alpha: 0.6),
            ),
            const SizedBox(width: 16),
            Text(
              DateFormat('dd MMMM yyyy, HH:mm').format(_selectedDate),
              style: theme.textTheme.bodyMedium,
            ),
            const Spacer(),
            Icon(
              Icons.edit,
              color: colorScheme.onSurface.withValues(alpha: 0.3),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the form submission button.
  ///
  /// Creates an elevated button that validates and submits the form,
  /// with loading state during submission.
  Widget _buildSubmitButton(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ElevatedButton(
      onPressed: _isSubmitting ? null : () => _submitForm(context),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
      ),
      child:
          _isSubmitting
              ? const CircularProgressIndicator()
              : Text(
                widget.transaction == null
                    ? 'AGREGAR TRANSACCIÓN'
                    : 'ACTUALIZAR TRANSACCIÓN',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate == null || !mounted) return;

    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_selectedDate),
    );

    if (pickedTime != null && mounted) {
      setState(() {
        _selectedDate = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );
      });
    }
  }

  Future<void> _submitForm(BuildContext context) async {
    final formState = _formKey.currentState;
    if (formState == null || !formState.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final amount = _currencyFormat.parse(_amountController.text).toDouble();
      final transaction = Transaction(
        id: widget.transaction?.id ?? const Uuid().v4(),
        type: _selectedType,
        amount: amount,
        category: _selectedCategory,
        description: _descriptionController.text,
        date: _selectedDate,
      );

      final provider = Provider.of<FinanceProvider>(context, listen: false);
      await provider.addTransaction(transaction);

      if (!mounted) return;

      Navigator.of(context).pop();

      if (!mounted) return;

      final message =
          widget.transaction == null
              ? 'Transacción agregada correctamente'
              : 'Transacción actualizada correctamente';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al guardar: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }
}
