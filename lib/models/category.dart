import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'category.g.dart';

@HiveType(typeId: 2)
enum Category {
  @HiveField(0)
  food,
  @HiveField(1)
  transportation,
  @HiveField(2)
  entertainment,
  @HiveField(3)
  housing,
  @HiveField(4)
  salary,
  @HiveField(5)
  other
}

extension CategoryExtension on Category {
  String get name {
    switch (this) {
      case Category.food:
        return 'Comida';
      case Category.transportation:
        return 'Transporte';
      case Category.entertainment:
        return 'Entretenimiento';
      case Category.housing:
        return 'Vivienda';
      case Category.salary:
        return 'Salario';
      case Category.other:
        return 'Otro';
    }
  }

  IconData get icon {
    switch (this) {
      case Category.food:
        return Icons.restaurant;
      case Category.transportation:
        return Icons.directions_car;
      case Category.entertainment:
        return Icons.movie;
      case Category.housing:
        return Icons.home;
      case Category.salary:
        return Icons.attach_money;
      case Category.other:
        return Icons.category;
    }
  }

  Color get color {
    switch (this) {
      case Category.food:
        return Colors.amber;
      case Category.transportation:
        return Colors.blue;
      case Category.entertainment:
        return Colors.purple;
      case Category.housing:
        return Colors.brown;
      case Category.salary:
        return Colors.green;
      case Category.other:
        return Colors.grey;
    }
  }
}