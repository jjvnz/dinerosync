import 'package:dinerosync/models/category.dart';
import 'package:dinerosync/models/transaction.dart';
import 'package:dinerosync/providers/finance_provider.dart';
import 'package:dinerosync/utils/number_formatter.dart';
import 'package:dinerosync/widgets/category_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Para HapticFeedback

import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class TransactionForm extends StatefulWidget {
  final Transaction? transaction;
  const TransactionForm({super.key, this.transaction});

  @override
  State<TransactionForm> createState() => _TransactionFormState();
}

class _TransactionFormState extends State<TransactionForm>
    with TickerProviderStateMixin {
  final _descriptionController = TextEditingController();
  TransactionType _selectedType = TransactionType.expense;
  Category _selectedCategory = Category.food;
  DateTime _selectedDate = DateTime.now();
  String _amountString = '0';
  bool _isSubmitting = false; // Estado para el botón de envío

  // Controlador para la animación del selector de tipo
  late AnimationController _typeSelectorAnimationController;
  late Animation<double> _typeSelectorAnimation;

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

    // Inicializar controlador de animación
    _typeSelectorAnimationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _typeSelectorAnimation = CurvedAnimation(
      parent: _typeSelectorAnimationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _typeSelectorAnimationController.dispose();
    super.dispose();
  }

  void _onKeyPressed(String key) {
    HapticFeedback.lightImpact(); // Feedback táctico en cada pulsación
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

  Future<void> _submitForm() async {
    if (_amount == 0 || _descriptionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, completa el monto y la descripción.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true); // Mostrar estado de carga

    final transaction = Transaction(
      id: widget.transaction?.id ?? const Uuid().v4(),
      type: _selectedType,
      amount: _amount,
      category: _selectedCategory,
      description: _descriptionController.text.trim(),
      date: _selectedDate,
    );

    final provider = Provider.of<FinanceProvider>(context, listen: false);
    final navigator = Navigator.of(context);

    try {
      if (widget.transaction != null) {
        await provider.updateTransaction(transaction);
      } else {
        await provider.addTransaction(transaction);
      }
      if (mounted) navigator.pop();
    } catch (e) {
      // Manejo de errores
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar transacción: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isIncome = _selectedType == TransactionType.income;
    final accentColor = isIncome ? Colors.green : Colors.red;

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
        child: Material(
          color: theme.scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          child: Column(
            children: [
              // Header fijo
              _buildHeader(context),
              // Contenido desplazable
              Expanded(
                child: SingleChildScrollView(
                  controller: controller,
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),
                      // --- MEJORA: Display de monto prominente ---
                      _buildHeroAmountDisplay(theme, accentColor),
                      const SizedBox(height: 24),
                      // --- MEJORA: Selector de tipo animado ---
                      _buildAnimatedTypeSelector(theme),
                      const SizedBox(height: 24),
                      CategorySelector(
                        selectedCategory: _selectedCategory,
                        onCategorySelected: (cat) {
                          HapticFeedback.selectionClick();
                          setState(() => _selectedCategory = cat);
                        },
                      ),
                      const SizedBox(height: 24),
                      _buildDetailsSection(theme),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
              // Teclado y botón fijo en la parte inferior
              _buildIntegratedKeypad(theme, accentColor),
            ],
          ),
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
            icon: const Icon(Icons.close, size: 28),
          ),
          Text(
            widget.transaction == null ? 'Nueva Transacción' : 'Editar',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 48), // Spacer para centrar el título
        ],
      ),
    );
  }

  // --- NUEVO: Widget "Hero" para el monto ---
  Widget _buildHeroAmountDisplay(ThemeData theme, Color accentColor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            accentColor.withValues(alpha: 0.1),
            accentColor.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: accentColor.withValues(alpha: 0.2),
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          Text(
            'Monto',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              '\$${NumberFormatter.formatCurrency(_amount).replaceAll('\$', '')}',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 48,
                fontWeight: FontWeight.w900,
                color: accentColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- NUEVO: Selector de tipo con animación ---
  Widget _buildAnimatedTypeSelector(ThemeData theme) {
    return AnimatedBuilder(
      animation: _typeSelectorAnimation,
      builder: (context, child) {
        return Container(
          height: 60,
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.all(4),
          child: Row(
            children: [
              Expanded(
                child: _buildTypeButton(
                  context,
                  type: TransactionType.income,
                  icon: Icons.arrow_downward,
                  label: 'Ingreso',
                  isSelected: _selectedType == TransactionType.income,
                  color: Colors.green,
                ),
              ),
              Expanded(
                child: _buildTypeButton(
                  context,
                  type: TransactionType.expense,
                  icon: Icons.arrow_upward,
                  label: 'Gasto',
                  isSelected: _selectedType == TransactionType.expense,
                  color: Colors.red,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTypeButton(
    BuildContext context, {
    required TransactionType type,
    required IconData icon,
    required String label,
    required bool isSelected,
    required Color color,
  }) {
    return GestureDetector(
      onTap: () {
        if (_selectedType != type) {
          HapticFeedback.selectionClick();
          setState(() => _selectedType = type);
          _typeSelectorAnimationController.forward().then((_) {
            _typeSelectorAnimationController.reverse();
          });
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : color.withValues(alpha: 0.7),
            ),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Inter',
                color: isSelected ? Colors.white : color.withValues(alpha: 0.7),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailsSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Detalles',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _descriptionController,
          decoration: InputDecoration(
            hintText: 'Ej: Café en Starbucks',
            prefixIcon: const Icon(Icons.edit_note),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: theme.colorScheme.surfaceContainerHighest,
          ),
        ),
        const SizedBox(height: 16),
        InkWell(
          onTap: () => _selectDate(context),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
                const SizedBox(width: 16),
                Text(
                  DateFormat('dd MMMM yyyy', 'es_ES').format(_selectedDate),
                  style: theme.textTheme.bodyLarge,
                ),
                const Spacer(),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
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
    HapticFeedback.selectionClick();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
    }
  }

  // --- MEJORA: Teclado con botón de envío con estado de carga ---
  Widget _buildIntegratedKeypad(ThemeData theme, Color accentColor) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 3,
              childAspectRatio: 1.6,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              padding: EdgeInsets.zero,
              children: [
                for (final key in [
                  '1',
                  '2',
                  '3',
                  '4',
                  '5',
                  '6',
                  '7',
                  '8',
                  '9',
                  '.',
                  '0',
                  'backspace',
                ])
                  _KeypadButton(
                    value: key,
                    onPressed: _onKeyPressed,
                    isIcon: key == 'backspace',
                  ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: accentColor,
                  foregroundColor: Colors.white,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : Text(
                        widget.transaction == null
                            ? 'Agregar Transacción'
                            : 'Guardar Cambios',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- MEJORA: Botón con feedback táctico ---
class _KeypadButton extends StatelessWidget {
  final String value;
  final Function(String) onPressed;
  final bool isIcon;

  const _KeypadButton({
    required this.value,
    required this.onPressed,
    this.isIcon = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => onPressed(value),
        splashColor: theme.colorScheme.primary.withValues(alpha: 0.2),
        highlightColor: theme.colorScheme.primary.withValues(alpha: 0.1),
        child: Container(
          alignment: Alignment.center,
          child: isIcon
              ? Icon(
                  Icons.backspace_outlined,
                  size: 26,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                )
              : Text(
                  value,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
        ),
      ),
    );
  }
}
