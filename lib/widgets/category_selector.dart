import 'package:dinerosync/models/category.dart';
import 'package:flutter/material.dart';

class CategorySelector extends StatelessWidget {
  final Category selectedCategory;
  final Function(Category) onCategorySelected;

  const CategorySelector({
    super.key,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: Category.values.length + 1, // +1 para la opción "Nuevo"
        separatorBuilder: (context, index) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          // Opción "Nuevo" al final
          if (index == Category.values.length) {
            return _buildCategoryItem(
              context,
              icon: Icons.add,
              label: 'Nuevo',
              isSelected: false,
              isDashed: true,
              onTap: () {
                // Add new category logic here
              },
            );
          }

          final category = Category.values[index];
          final isSelected = category == selectedCategory;

          return _buildCategoryItem(
            context,
            icon: category.icon,
            label: category.name,
            isSelected: isSelected,
            color: category.color,
            onTap: () => onCategorySelected(category),
          );
        },
      ),
    );
  }

  Widget _buildCategoryItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required bool isSelected,
    Color? color,
    bool isDashed = false,
    VoidCallback? onTap,
  }) {
    final theme = Theme.of(context);
    final defaultColor = theme.colorScheme.onSurface.withValues(alpha: 0.5);

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: isSelected
                  ? (color ?? defaultColor).withValues(alpha: 0.2)
                  : theme.colorScheme.surfaceContainerHighest,
              shape: BoxShape.circle,
              border: isDashed
                  ? Border.all(
                      color: theme.colorScheme.outline.withValues(alpha: 0.5),
                      style: BorderStyle.solid,
                      width: 2,
                    )
                  : isSelected
                  ? Border.all(color: color ?? defaultColor, width: 2)
                  : null,
            ),
            child: Icon(
              icon,
              size: 32,
              color: isSelected ? (color ?? defaultColor) : defaultColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: isSelected
                  ? theme.colorScheme.onSurface
                  : theme.colorScheme.onSurface.withValues(alpha: 0.7),
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
