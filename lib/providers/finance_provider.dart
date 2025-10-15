import 'package:dinerosync/models/category.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/transaction.dart';

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
      return allTransactions.where((t) => 
        t.date.isAfter(currentFilter.start.subtract(const Duration(days: 1))) &&
        t.date.isBefore(currentFilter.end.add(const Duration(days: 1)))
      ).toList()..sort((a, b) => b.date.compareTo(a.date));
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
}