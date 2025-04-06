import 'package:hive/hive.dart';
import 'category.dart';

part 'transaction.g.dart';

@HiveType(typeId: 0)
class Transaction {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final TransactionType type;
  
  @HiveField(2)
  final double amount;
  
  @HiveField(3)
  final Category category;
  
  @HiveField(4)
  final String description;
  
  @HiveField(5)
  final DateTime date;

  Transaction({
    required this.id,
    required this.type,
    required this.amount,
    required this.category,
    required this.description,
    required this.date,
  });
}

@HiveType(typeId: 1)
enum TransactionType {
  @HiveField(0)
  income,
  
  @HiveField(1)
  expense
}