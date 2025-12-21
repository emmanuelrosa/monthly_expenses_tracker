import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:monthly_expenses_tracker/expense_category/expense_categories.dart';
import 'package:monthly_expenses_tracker/expenses_data/expenses_data.dart';

typedef _RodData = ({
  double fromY,
  double toY,
  Color rodColor,
  String label,
  Color labelColor,
});

/// Uses [fl_chart] to create a stacked bar chart using the provided list of [ExpensesData].
/// The expenses is an [Iterable] tuple, which contains a String label and the corresponding [ExpensesData].
class StackedExpensesChart extends StatelessWidget {
  final Iterable<(String, ExpensesData)> expenses;
  final ExpenseCategories categories;

  const StackedExpensesChart({
    super.key,
    required this.expenses,
    required this.categories,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BarChart(
      BarChartData(
        rotationQuarterTurns: 1,
        alignment: .start,
        barTouchData: BarTouchData(enabled: false),
        borderData: FlBorderData(show: false),
        gridData: FlGridData(
          drawHorizontalLine: false,
          drawVerticalLine: false,
        ),
        titlesData: FlTitlesData(
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 50,
              getTitlesWidget: (value, meta) => _getTitles(
                theme,
                expenses.map((tuple) => tuple.$1),
                value,
                meta,
              ),
            ),
          ),
        ),
        barGroups: [
          for (int i = 0; i < expenses.length; i++)
            BarChartGroupData(
              x: i,
              showingTooltipIndicators: [],
              barRods: [
                BarChartRodData(
                  toY: expenses.elementAt(i).$2.total,
                  rodStackItems: _rodStackItems(expenses.elementAt(i).$2),
                  width: 40.0,
                ),
              ],
            ),
        ],
      ),
    );
  }

  /// Takes the [ExpensesData] and returns the [BarChartRodStackItem]s to
  /// represent the expenses as a stacked bar chart.
  List<BarChartRodStackItem> _rodStackItems(ExpensesData expenses) =>
      [
            (
              expenses.housing,
              categories.housing.color,
              categories.housing.backgroundColor,
            ),
            (
              expenses.food,
              categories.food.color,
              categories.food.backgroundColor,
            ),
            (
              expenses.transportation,
              categories.transportation.color,
              categories.transportation.backgroundColor,
            ),
            (
              expenses.entertainment,
              categories.entertainment.color,
              categories.entertainment.backgroundColor,
            ),
            (
              expenses.fitness,
              categories.fitness.color,
              categories.fitness.backgroundColor,
            ),
            (
              expenses.education,
              categories.education.color,
              categories.education.backgroundColor,
            ),
          ]
          /* Traverses the list of tuples shown above and prepends
           * the fromY that will be used for the rod.
           * The output is a triple.
           */
          .fold<List<_RodData>>([], (list, tuple) {
            final fromY = list.isEmpty ? 0.0 : list.last.toY;
            final formatter = NumberFormat();

            list.add((
              fromY: fromY,
              toY: fromY + tuple.$1,
              rodColor: tuple.$2,
              label: formatter.format(tuple.$1),
              labelColor: tuple.$3,
            ));
            return list;
          })
          .map(
            (rd) => BarChartRodStackItem(
              rd.fromY,
              rd.toY,
              rd.rodColor,
              /* The label is not displayed when it accounts for a tiny
               * percentage of the total expenses.
               */
              label: ((rd.toY - rd.fromY) / expenses.total) < 0.03
                  ? null
                  : rd.label,
              labelStyle: TextStyle(color: rd.labelColor),
            ),
          )
          .toList();

  Widget _getTitles(
    ThemeData theme,
    Iterable<String> labels,
    double value,
    TitleMeta meta,
  ) {
    final label = labels.elementAt(value.toInt());
    final style = theme.textTheme.titleMedium?.copyWith(
      color: theme.primaryColor,
    );

    return SideTitleWidget(
      meta: meta,
      space: 4,
      child: Text(label, style: style),
    );
  }
}
