import 'package:dinerosync/models/category.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import '../models/transaction.dart';
import '../models/insight.dart';

/// Provider class that manages financial data and transactions.
///
/// Handles CRUD operations for transactions, date filtering, and
/// provides calculated financial summaries. Uses [Hive] for local
/// data persistence and [ChangeNotifier] for state management.
class FinanceProvider with ChangeNotifier {
  /// The Hive box for storing transactions.
  Box<Transaction>? _transactionsBox;

  /// Whether the provider has been properly initialized.
  bool _isInitialized = false;

  /// Current date range filter for transactions.
  DateTimeRange? _dateFilter;

  /// The current date filter applied to transactions.
  DateTimeRange? get dateFilter => _dateFilter;

  /// Initializes the provider by opening the Hive box.
  ///
  /// Must be called before using any other methods. Sets up the
  /// local storage connection and marks the provider as initialized.
  Future<void> init() async {
    try {
      _transactionsBox = await Hive.openBox<Transaction>('transactions');
      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Error initializing Hive box: $e');
      _isInitialized = false;
    }
  }

  /// Sets the date range filter for transactions.
  ///
  /// When [range] is provided, only transactions within that date
  /// range will be included in calculations and lists. Pass null
  /// to remove the filter.
  void setDateFilter(DateTimeRange? range) {
    _dateFilter = range;
    notifyListeners();
  }

  /// Gets all transactions, optionally filtered by date range.
  ///
  /// Returns transactions sorted by date (newest first). If a date
  /// filter is active, only transactions within that range are returned.
  List<Transaction> get transactions {
    if (!_isInitialized || _transactionsBox == null) return [];

    final allTransactions = _transactionsBox?.values.toList() ?? [];

    final currentFilter = _dateFilter;
    if (currentFilter != null) {
      return allTransactions
          .where(
            (t) =>
                t.date.isAfter(
                  currentFilter.start.subtract(const Duration(days: 1)),
                ) &&
                t.date.isBefore(currentFilter.end.add(const Duration(days: 1))),
          )
          .toList()
        ..sort((a, b) => b.date.compareTo(a.date));
    }

    return allTransactions..sort((a, b) => b.date.compareTo(a.date));
  }

  /// The total amount of all income transactions.
  ///
  /// Calculates the sum of all transactions with type [TransactionType.income]
  /// within the current date filter, if any.
  double get totalIncome => transactions
      .where((t) => t.type == TransactionType.income)
      .fold(0.0, (sum, t) => sum + t.amount);

  /// The total amount of all expense transactions.
  ///
  /// Calculates the sum of all transactions with type [TransactionType.expense]
  /// within the current date filter, if any.
  double get totalExpenses => transactions
      .where((t) => t.type == TransactionType.expense)
      .fold(0.0, (sum, t) => sum + t.amount);

  /// The current financial balance.
  ///
  /// Calculated as total income minus total expenses. A positive
  /// value indicates profit, negative indicates loss.
  double get balance => totalIncome - totalExpenses;

  /// Groups expense transactions by category with totals.
  ///
  /// Returns a map where keys are [Category] values and values are
  /// the total expense amounts for each category. Only includes
  /// categories with expenses greater than zero.
  Map<Category, double> get expensesByCategory {
    final Map<Category, double> result = {};

    if (!_isInitialized) return result;

    final filteredTransactions = transactions
        .where((t) => t.type == TransactionType.expense)
        .toList();

    for (var category in Category.values) {
      final total = filteredTransactions
          .where((t) => t.category == category)
          .fold(0.0, (sum, t) => sum + (t.amount));
      if (total > 0) {
        result[category] = total;
      }
    }

    return result;
  }

  /// Adds a new transaction to storage.
  ///
  /// Persists the [transaction] to the Hive box and notifies listeners.
  /// Returns true if successful, false if the operation fails.
  Future<bool> addTransaction(Transaction transaction) async {
    if (!_isInitialized || _transactionsBox == null) return false;

    try {
      await _transactionsBox!.put(transaction.id, transaction);
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error adding transaction: $e');
      return false;
    }
  }

  /// Deletes a transaction from storage.
  ///
  /// Removes the transaction with the given [id] from the Hive box
  /// and notifies listeners. Returns true if successful, false otherwise.
  Future<bool> deleteTransaction(String id) async {
    if (!_isInitialized || _transactionsBox == null) return false;

    try {
      await _transactionsBox!.delete(id);
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error deleting transaction: $e');
      return false;
    }
  }

  double get todayChange {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final todayEnd = todayStart.add(const Duration(days: 1));

    final todayTransactions = transactions
        .where(
          (t) =>
              t.date.isAfter(
                todayStart.subtract(const Duration(milliseconds: 1)),
              ) &&
              t.date.isBefore(todayEnd),
        )
        .toList();

    double income = todayTransactions
        .where((t) => t.type == TransactionType.income)
        .fold(0.0, (sum, t) => sum + t.amount);

    double expenses = todayTransactions
        .where((t) => t.type == TransactionType.expense)
        .fold(0.0, (sum, t) => sum + t.amount);

    return income - expenses;
  }

  Future<bool> updateTransaction(Transaction updatedTransaction) async {
    if (!_isInitialized || _transactionsBox == null) return false;

    try {
      await _transactionsBox!.put(updatedTransaction.id, updatedTransaction);
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error updating transaction: $e');
      return false;
    }
  }

  /// Toggles the favorite status of a transaction.
  Future<bool> toggleFavorite(String id) async {
    if (!_isInitialized || _transactionsBox == null) return false;

    try {
      final transaction = _transactionsBox!.get(id);
      if (transaction != null) {
        final updatedTransaction = Transaction(
          id: transaction.id,
          type: transaction.type,
          amount: transaction.amount,
          category: transaction.category,
          description: transaction.description,
          date: transaction.date,
          isFavorite: !transaction.isFavorite, // <-- Toggle the value
        );
        await _transactionsBox!.put(id, updatedTransaction);
        notifyListeners();
        return true;
      }
    } catch (e) {
      debugPrint('Error toggling favorite: $e');
    }
    return false;
  }

  /// Groups transactions by a formatted date string (e.g., "Hoy", "Ayer").
  Map<String, List<Transaction>> get groupedTransactions {
    if (!_isInitialized || _transactionsBox == null) return {};

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    final Map<String, List<Transaction>> grouped = {};

    for (var transaction in transactions) {
      String key;
      final transactionDate = DateTime(
        transaction.date.year,
        transaction.date.month,
        transaction.date.day,
      );

      if (transactionDate == today) {
        key = 'Hoy';
      } else if (transactionDate == yesterday) {
        key = 'Ayer';
      } else {
        key = DateFormat('dd MMMM, yyyy', 'es_ES').format(transaction.date);
      }

      grouped.putIfAbsent(key, () => []).add(transaction);
    }

    return grouped;
  }

  /// Gets the start and end date for a given filter type.
  DateTimeRange? _getDateRangeForFilter(String filter) {
    final now = DateTime.now();
    switch (filter) {
      case 'Semana':
        final start = now.subtract(Duration(days: now.weekday - 1));
        final end = start.add(const Duration(days: 6));
        return DateTimeRange(start: start, end: end);
      case 'Mes':
        final start = DateTime(now.year, now.month, 1);
        final end = DateTime(now.year, now.month + 1, 0);
        return DateTimeRange(start: start, end: end);
      case 'Año':
        final start = DateTime(now.year, 1, 1);
        final end = DateTime(now.year, 12, 31);
        return DateTimeRange(start: start, end: end);
      default:
        return null; // Usa el filtro personalizado o ninguno
    }
  }

  /// Gets expenses by category for the current filter.
  Map<Category, double> getExpensesByCategoryForFilter(String filter) {
    final range = _getDateRangeForFilter(filter) ?? _dateFilter;
    if (range == null) return expensesByCategory;

    final filteredTransactions = transactions
        .where(
          (t) =>
              t.type == TransactionType.expense &&
              t.date.isAfter(range.start.subtract(const Duration(days: 1))) &&
              t.date.isBefore(range.end.add(const Duration(days: 1))),
        )
        .toList();

    final Map<Category, double> result = {};
    for (var category in Category.values) {
      final total = filteredTransactions
          .where((t) => t.category == category)
          .fold(0.0, (sum, t) => sum + t.amount);
      if (total > 0) {
        result[category] = total;
      }
    }
    return result;
  }

  /// Gets cash flow data (income vs expense) for a line chart.
  List<CashFlowData> getCashFlowForFilter(String filter) {
    final range = _getDateRangeForFilter(filter) ?? _dateFilter;
    if (range == null) return [];

    final Map<String, double> weeklyData = {};
    var currentWeekStart = range.start;

    while (currentWeekStart.isBefore(range.end)) {
      final currentWeekEnd = currentWeekStart.add(const Duration(days: 6));
      final weekTransactions = transactions
          .where(
            (t) =>
                t.date.isAfter(
                  currentWeekStart.subtract(const Duration(days: 1)),
                ) &&
                t.date.isBefore(currentWeekEnd.add(const Duration(days: 1))),
          )
          .toList();

      final income = weekTransactions
          .where((t) => t.type == TransactionType.income)
          .fold(0.0, (sum, t) => sum + t.amount);
      final expenses = weekTransactions
          .where((t) => t.type == TransactionType.expense)
          .fold(0.0, (sum, t) => sum + t.amount);

      weeklyData['Sem ${DateFormat('dd/MM').format(currentWeekStart)}'] =
          income - expenses;
      currentWeekStart = currentWeekStart.add(const Duration(days: 7));
    }

    return weeklyData.entries.map((e) => CashFlowData(e.key, e.value)).toList();
  }

  /// Generates a list of smart insights based on user spending patterns.
  List<Insight> get insights {
    final List<Insight> generatedInsights = [];
    final now = DateTime.now();
    final thisMonth = DateTime(now.year, now.month, 1);
    final lastMonth = DateTime(now.year, now.month - 1, 1);

    // Insight 1: Gasto más alto del mes
    if (expensesByCategory.isNotEmpty) {
      final topCategory = expensesByCategory.entries.reduce(
        (a, b) => a.value > b.value ? a : b,
      );
      generatedInsights.add(
        Insight(
          title: 'Tu Mayor Gasto Este Mes',
          description:
              'Has gastado más en "${topCategory.key.name}". Revisa si puedes optimizar esta área.',
          icon: topCategory.key.icon,
          iconColor: topCategory.key.color,
        ),
      );
    }

    // Insight 2: Comparación con el mes pasado (simplificado)
    final thisMonthExpenses = transactions
        .where(
          (t) =>
              t.type == TransactionType.expense &&
              t.date.isAfter(thisMonth.subtract(const Duration(days: 1))),
        )
        .fold(0.0, (sum, t) => sum + t.amount);

    final lastMonthExpenses = transactions
        .where(
          (t) =>
              t.type == TransactionType.expense &&
              t.date.isAfter(lastMonth) &&
              t.date.isBefore(thisMonth),
        )
        .fold(0.0, (sum, t) => sum + t.amount);

    if (lastMonthExpenses > 0) {
      final difference =
          ((thisMonthExpenses - lastMonthExpenses) / lastMonthExpenses) * 100;
      if (difference > 10) {
        generatedInsights.add(
          Insight(
            title: 'Gastos en Aumento',
            description:
                'Tus gastos este mes son un ${difference.toStringAsFixed(0)}% más altos que el mes pasado.',
            icon: Icons.trending_up,
            iconColor: Colors.red,
          ),
        );
      } else if (difference < -10) {
        generatedInsights.add(
          Insight(
            title: '¡Buen Trabajo Ahorrando!',
            description:
                'Tus gastos este mes son un ${difference.abs().toStringAsFixed(0)}% más bajos que el mes pasado.',
            icon: Icons.savings,
            iconColor: Colors.green,
          ),
        );
      }
    }

    return generatedInsights;
  }

  /// Gets transactions filtered by the specified filter type.
  List<Transaction> getTransactionsForFilter(String filter) {
    final range = _getDateRangeForFilter(filter) ?? _dateFilter;
    if (range == null) return transactions;

    return transactions
        .where(
          (t) =>
              t.date.isAfter(range.start.subtract(const Duration(days: 1))) &&
              t.date.isBefore(range.end.add(const Duration(days: 1))),
        )
        .toList();
  }

  double getTotalIncomeForFilter(String filter) {
    final transactions = getTransactionsForFilter(filter);
    return transactions
        .where((t) => t.type == TransactionType.income)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  double getTotalExpensesForFilter(String filter) {
    final transactions = getTransactionsForFilter(filter);
    return transactions
        .where((t) => t.type == TransactionType.expense)
        .fold(0.0, (sum, t) => sum + t.amount);
  }
}

/// Data model for the cash flow chart.
class CashFlowData {
  final String period;
  final double amount;
  CashFlowData(this.period, this.amount);
}
