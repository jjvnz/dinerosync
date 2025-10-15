import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'category.g.dart';

/// Enumeration of transaction categories.
///
/// Defines the available categories for classifying transactions
/// with Hive serialization support for local storage.
@HiveType(typeId: 2)
enum Category {
  /// Food and dining expenses.
  @HiveField(0)
  food,
  
  /// Transportation and travel costs.
  @HiveField(1)
  transportation,
  
  /// Entertainment and leisure activities.
  @HiveField(2)
  entertainment,
  
  /// Housing and accommodation expenses.
  @HiveField(3)
  housing,
  
  /// Salary and income sources.
  @HiveField(4)
  salary,
  
  /// Miscellaneous transactions not fitting other categories.
  @HiveField(5)
  other
}

/// Extension that provides display properties for [Category] enum.
///
/// Adds localized names, icons, and colors for each category
/// to support consistent UI presentation throughout the app.
extension CategoryExtension on Category {
  /// The localized display name for this category.
  ///
  /// Returns Spanish names for each category value.
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

  /// The icon associated with this category.
  ///
  /// Returns Material Design icons that visually represent
  /// each category type.
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

  /// The color theme for this category.
  ///
  /// Returns distinct colors for each category to provide
  /// visual differentiation in charts and UI elements.
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