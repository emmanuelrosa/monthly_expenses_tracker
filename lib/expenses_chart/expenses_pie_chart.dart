import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:monthly_expenses_tracker/expense_category/expense_categories.dart';
import 'package:monthly_expenses_tracker/expenses_data/expenses_data.dart';

class ExpensesPieChart extends StatelessWidget {
  final ExpensesData expenses;
  final ExpenseCategories categories;

  const ExpensesPieChart({
    super.key,
    required this.expenses,
    required this.categories,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final formatter = NumberFormat();
        final size = constraints.maxWidth < constraints.maxHeight
            ? constraints.maxWidth
            : constraints.maxHeight;

        return PieChart(
          PieChartData(
            sectionsSpace: 10.0,
            sections:
                [
                      (expenses.housing, categories.housing),
                      (expenses.food, categories.food),
                      (expenses.transportation, categories.transportation),
                      (expenses.entertainment, categories.entertainment),
                      (expenses.fitness, categories.fitness),
                      (expenses.education, categories.education),
                    ]
                    .map(
                      (tuple) => PieChartSectionData(
                        radius: size * 0.3,
                        value: tuple.$1,
                        title: formatter.format(tuple.$1),
                        color: tuple.$2.color,
                        titleStyle: theme.textTheme.labelLarge?.copyWith(
                          color: tuple.$2.backgroundColor,
                        ),
                      ),
                    )
                    .toList(),
          ),
        );
      },
    );
  }
}
