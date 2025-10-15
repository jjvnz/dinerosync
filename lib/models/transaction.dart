import 'package:hive/hive.dart';
import 'category.dart';

part 'transaction.g.dart';

/// Model class representing a financial transaction.
///
/// Contains all necessary information for tracking income and expenses
/// with Hive serialization support for local storage persistence.
@HiveType(typeId: 0)
class Transaction {
  /// Unique identifier for this transaction.
  @HiveField(0)
  final String id;
  
  /// The type of transaction (income or expense).
  @HiveField(1)
  final TransactionType type;
  
  /// The monetary amount of the transaction.
  @HiveField(2)
  final double amount;
  
  /// The category this transaction belongs to.
  @HiveField(3)
  final Category category;
  
  /// User-provided description of the transaction.
  @HiveField(4)
  final String description;
  
  /// The date and time when the transaction occurred.
  @HiveField(5)
  final DateTime date;

  /// Creates a new transaction.
  ///
  /// All parameters are required to ensure complete transaction data.
  /// The [id] should be unique across all transactions.
  Transaction({
    required this.id,
    required this.type,
    required this.amount,
    required this.category,
    required this.description,
    required this.date,
  });
}

/// Enumeration of transaction types.
///
/// Defines whether a transaction represents money coming in (income)
/// or money going out (expense) with Hive serialization support.
@HiveType(typeId: 1)
enum TransactionType {
  /// Money received or earned.
  @HiveField(0)
  income,
  
  /// Money spent or paid out.
  @HiveField(1)
  expense
}