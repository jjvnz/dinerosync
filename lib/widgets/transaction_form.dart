import 'package:dinerosync/models/category.dart';
import 'package:dinerosync/models/transaction.dart';
import 'package:dinerosync/providers/finance_provider.dart';
import 'package:dinerosync/utils/number_formatter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  bool _isSubmitting = false;

  // Categorías adaptadas a tu modelo
  final List<Map<String, dynamic>> _categories = [
    {'category': Category.food, 'name': 'Comida', 'icon': Icons.restaurant},
    {
      'category': Category.transportation,
      'name': 'Transporte',
      'icon': Icons.directions_bus,
    },
    {
      'category': Category.entertainment,
      'name': 'Entretenimiento',
      'icon': Icons.movie,
    },
    {'category': Category.housing, 'name': 'Vivienda', 'icon': Icons.home},
    {
      'category': Category.salary,
      'name': 'Salario',
      'icon': Icons.attach_money,
    },
    {'category': Category.other, 'name': 'Otros', 'icon': Icons.category},
  ];

  @override
  void initState() {
    super.initState();
    if (widget.transaction != null) {
      final t = widget.transaction!;
      _selectedType = t.type;
      _selectedCategory = t.category;
      _selectedDate = t.date;
      _amountString = t.amount.toStringAsFixed(0); // Sin decimales inicialmente
      _descriptionController.text = t.description;
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  void _onKeyPressed(String key) {
    HapticFeedback.lightImpact();
    setState(() {
      if (key == 'backspace') {
        if (_amountString.isNotEmpty && _amountString != '0') {
          _amountString = _amountString.substring(0, _amountString.length - 1);
          if (_amountString.isEmpty) _amountString = '0';
        }
      } else if (key == 'clear') {
        _amountString = '0';
      } else {
        if (_amountString == '0') {
          _amountString = key;
        } else {
          _amountString += key;
        }

        // Limitar a 10 dígitos para evitar números demasiado grandes
        if (_amountString.length > 10) {
          _amountString = _amountString.substring(0, 10);
        }
      }
    });
  }

  void _selectCategory(int index) {
    HapticFeedback.selectionClick();
    final category = _categories[index];
    setState(() {
      _selectedCategory = category['category'];
    });
  }

  double get _amount {
    try {
      return double.parse(_amountString);
    } catch (e) {
      return 0.0;
    }
  }

  // Obtener el monto formateado para mostrar
  String get _formattedAmount {
    return NumberFormatter.formatCurrency(_amount);
  }

  bool get _isFormValid =>
      _amount > 0 && _descriptionController.text.trim().isNotEmpty;

  Future<void> _submitForm() async {
    if (!_isFormValid) {
      HapticFeedback.heavyImpact();
      _showValidationError();
      return;
    }

    setState(() => _isSubmitting = true);

    final transaction = Transaction(
      id: widget.transaction?.id ?? const Uuid().v4(),
      type: _selectedType,
      amount: _amount,
      category: _selectedCategory,
      description: _descriptionController.text.trim(),
      date: _selectedDate,
    );

    final provider = Provider.of<FinanceProvider>(context, listen: false);

    try {
      await Future.delayed(const Duration(milliseconds: 300));

      if (widget.transaction != null) {
        await provider.updateTransaction(transaction);
      } else {
        await provider.addTransaction(transaction);
      }

      if (mounted) {
        HapticFeedback.heavyImpact();
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        HapticFeedback.heavyImpact();
        _showErrorSnackBar('Error al guardar: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  void _showValidationError() {
    String message = 'Por favor, completa todos los campos';
    if (_amount == 0) {
      message = 'Ingresa un monto válido';
    } else if (_descriptionController.text.trim().isEmpty) {
      message = 'Agrega una descripción';
    }
    _showErrorSnackBar(message);
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Future<void> _selectDate() async {
    HapticFeedback.selectionClick();

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020), // ← Rango más realista
      lastDate: DateTime(2030), // ← Rango más realista
    );

    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked); // ← Eliminé HapticFeedback extra
    }
  }

  String _getDateText() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final selected = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
    );

    if (selected == today) return 'Hoy';
    if (selected == today.subtract(const Duration(days: 1))) return 'Ayer';

    return DateFormat('dd/MM/yyyy').format(_selectedDate);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = const Color(0xFF0fb885);

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF10221C)
          : const Color(0xFFf6f8f7),
      body: Column(
        children: [
          // Header fijo
          _buildHeader(context, isDark),

          // Contenido principal con scroll
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Display del monto
                  _buildAmountDisplay(isDark, primaryColor),

                  const SizedBox(height: 24),

                  // Selector de tipo (Ingreso/Gasto)
                  _buildTypeSelector(isDark, primaryColor),

                  const SizedBox(height: 24),

                  // Categorías
                  _buildCategorySection(isDark, primaryColor),

                  const SizedBox(height: 24),

                  // Descripción
                  _buildDescriptionField(isDark),

                  const SizedBox(height: 16),

                  // Fecha
                  _buildDateField(isDark),

                  const SizedBox(height: 24),

                  // Teclado numérico mejorado
                  _buildKeypadSection(isDark),

                  const SizedBox(height: 24),

                  // Botón de acción
                  _buildActionButton(primaryColor),

                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF10221C) : const Color(0xFFf6f8f7),
        border: Border(
          bottom: BorderSide(color: isDark ? Colors.white12 : Colors.black12),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              Navigator.pop(context);
            },
            style: IconButton.styleFrom(
              backgroundColor: isDark
                  ? Colors.white.withValues(alpha: 0.1)
                  : Colors.black.withValues(alpha: 0.05),
              shape: const CircleBorder(),
            ),
            icon: Icon(
              Icons.close,
              color: isDark ? Colors.white : const Color(0xFF374151),
            ),
          ),
          Text(
            widget.transaction == null
                ? 'Nueva Transacción'
                : 'Editar Transacción',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF1F2937),
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildAmountDisplay(bool isDark, Color primaryColor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
      decoration: BoxDecoration(
        color: primaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: primaryColor.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Text(
            'MONTO',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: primaryColor,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '\$$_formattedAmount',
            style: TextStyle(
              fontSize: _amountString.length > 8 ? 32 : 40,
              fontWeight: FontWeight.w800,
              color: primaryColor,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            'Pesos Colombianos',
            style: TextStyle(
              fontSize: 12,
              color: primaryColor.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeSelector(bool isDark, Color primaryColor) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.05)
            : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildTypeOption(
              label: 'Gasto',
              isSelected: _selectedType == TransactionType.expense,
              color: Colors.red,
              icon: Icons.arrow_upward,
            ),
          ),
          Expanded(
            child: _buildTypeOption(
              label: 'Ingreso',
              isSelected: _selectedType == TransactionType.income,
              color: Colors.green,
              icon: Icons.arrow_downward,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeOption({
    required String label,
    required bool isSelected,
    required Color color,
    required IconData icon,
  }) {
    return Material(
      color: isSelected ? color : Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          setState(() {
            _selectedType = label == 'Ingreso'
                ? TransactionType.income
                : TransactionType.expense;
          });
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 20, color: isSelected ? Colors.white : color),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategorySection(bool isDark, Color primaryColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Categoría',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : const Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 90,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _categories.length,
            itemBuilder: (context, index) {
              final category = _categories[index];
              final isSelected = _selectedCategory == category['category'];

              return GestureDetector(
                onTap: () => _selectCategory(index),
                child: Container(
                  width: 80,
                  margin: EdgeInsets.only(
                    right: index == _categories.length - 1 ? 0 : 12,
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? primaryColor.withValues(alpha: 0.2)
                              : isDark
                              ? Colors.white.withValues(alpha: 0.1)
                              : Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(
                            color: isSelected
                                ? primaryColor
                                : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: Icon(
                          category['icon'],
                          size: 24,
                          color: isSelected
                              ? primaryColor
                              : isDark
                              ? Colors.grey.shade400
                              : Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        category['name'],
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: isDark
                              ? Colors.white
                              : const Color(0xFF374151),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDescriptionField(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Descripción',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : const Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _descriptionController,
          decoration: InputDecoration(
            hintText: '¿Para qué fue este gasto/ingreso?',
            hintStyle: TextStyle(
              color: isDark ? Colors.grey.shade400 : Colors.grey.shade500,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: isDark
                ? Colors.white.withValues(alpha: 0.05)
                : Colors.grey.shade100,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
          style: TextStyle(
            fontSize: 16,
            color: isDark ? Colors.white : Colors.black,
          ),
          maxLines: 2,
        ),
      ],
    );
  }

  Widget _buildDateField(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Fecha',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : const Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 8),
        Material(
          color: isDark
              ? Colors.white.withValues(alpha: 0.05)
              : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            onTap: _selectDate,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              height: 56,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _getDateText(),
                    style: TextStyle(
                      fontSize: 16,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  Icon(
                    Icons.calendar_today,
                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildKeypadSection(bool isDark) {
    return Column(
      children: [
        Text(
          'Teclado Numérico',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : const Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 12),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 4,
          childAspectRatio: 1.2,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          children: [
            for (final key in [
              '1',
              '2',
              '3',
              'backspace',
              '4',
              '5',
              '6',
              'clear',
              '7',
              '8',
              '9',
              '',
              '.',
              '0',
              '000',
              '',
            ])
              if (key.isNotEmpty)
                Material(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.05)
                      : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                  child: InkWell(
                    onTap: () => _onKeyPressed(key),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      alignment: Alignment.center,
                      child: key == 'backspace'
                          ? Icon(
                              Icons.backspace,
                              color: isDark ? Colors.white : Colors.black,
                              size: 24,
                            )
                          : key == 'clear'
                          ? Icon(
                              Icons.clear,
                              color: isDark ? Colors.white : Colors.black,
                              size: 24,
                            )
                          : Text(
                              key,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w500,
                                color: isDark ? Colors.white : Colors.black,
                              ),
                            ),
                    ),
                  ),
                )
              else
                const SizedBox.shrink(),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton(Color primaryColor) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isSubmitting ? null : _submitForm,
        style: ElevatedButton.styleFrom(
          backgroundColor: _isFormValid ? primaryColor : Colors.grey,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
        child: _isSubmitting
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    widget.transaction == null ? Icons.add : Icons.check,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    widget.transaction == null
                        ? 'Agregar Transacción'
                        : 'Guardar Cambios',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
