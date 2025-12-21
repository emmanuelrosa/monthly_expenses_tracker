import 'package:flutter/material.dart';
import 'package:monthly_expenses_tracker/expense_category/expense_categories.dart';

/// A Material card used to display an expense category name
/// along with a designated color.
/// This is used to show the user which chart color corresponds to
/// which expense category.
class ExpenseCategoryCard extends StatelessWidget {
  final Color color;
  final String label;

  const ExpenseCategoryCard({
    super.key,
    required this.color,
    required this.label,
  });

  static ExpenseCategoryCard fromCategory(ExpenseCategory category) =>
      ExpenseCategoryCard(label: category.label, color: category.color);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      color: theme.primaryColor,
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      child: Padding(
        padding: const EdgeInsets.all(6.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.primaryColorLight,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
