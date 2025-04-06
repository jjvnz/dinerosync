import 'package:dinerosync/models/category.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/transaction.dart';

class FinanceProvider with ChangeNotifier {
  Box<Transaction>? _transactionsBox;
  bool _isInitialized = false;
  DateTimeRange? _dateFilter;

  // Getter público para el filtro de fecha
  DateTimeRange? get dateFilter => _dateFilter;

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

  void setDateFilter(DateTimeRange? range) {
    _dateFilter = range;
    notifyListeners();
  }

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

  double get totalIncome => transactions
      .where((t) => t.type == TransactionType.income)
      .fold(0.0, (sum, t) => sum + t.amount);

  double get totalExpenses => transactions
      .where((t) => t.type == TransactionType.expense)
      .fold(0.0, (sum, t) => sum + t.amount);

  double get balance => totalIncome - totalExpenses;

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