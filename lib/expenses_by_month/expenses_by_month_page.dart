import 'dart:math';

import 'package:flutter/material.dart';
import 'package:monthly_expenses_tracker/expense_category/expense_categories.dart';
import 'package:monthly_expenses_tracker/expense_category/expense_category_card.dart';
import 'package:monthly_expenses_tracker/expenses_by_month/expenses_by_month_service.dart';
import 'package:monthly_expenses_tracker/expenses_chart/stacked_expenses_chart.dart';
import 'package:monthly_expenses_tracker/expenses_data/expenses_data_repository.dart';

/// The top-level widget of the expenses by year feature.
class ExpensesByMonthPage extends StatelessWidget {
  const ExpensesByMonthPage({super.key});

  @override
  Widget build(BuildContext context) {
    final repository = ExpensesDataRepositoryProvider.of(context).repository;

    return _ExpensesByMonthServiceLoader(
      repository: repository,
      child: _ExpensesByMonthServiceLoaded(),
    );
  }
}

/// Once the [ExpensesByMonthService] has been initialized, this widget is used
/// to render the main UI for this feature.
class _ExpensesByMonthServiceLoaded extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final service = ExpensesByMonthServiceProvider.of(context).service;

    return ListenableBuilder(
      listenable: service,
      builder: (context, _) {
        final theme = Theme.of(context);
        final backgroundColor = switch (service.state) {
          ExpensesByMonthServiceLoadingState() =>
            theme.colorScheme.inversePrimary,
          ExpensesByMonthServiceReadyState() =>
            theme.colorScheme.inversePrimary,
          ExpensesByMonthServiceNotReadyState() => theme.colorScheme.secondary,
          ExpensesByMonthServiceErrorState() => theme.colorScheme.secondary,
        };
        final titleColor = switch (service.state) {
          ExpensesByMonthServiceLoadingState() => theme.primaryColor,
          ExpensesByMonthServiceReadyState() => theme.primaryColor,
          ExpensesByMonthServiceNotReadyState() => theme.primaryColorLight,
          ExpensesByMonthServiceErrorState() => theme.primaryColorLight,
        };

        return Scaffold(
          appBar: AppBar(
            backgroundColor: backgroundColor,
            title: Text(
              'Expenses by month',
              style: theme.textTheme.titleLarge?.copyWith(color: titleColor),
            ),
          ),
          backgroundColor: backgroundColor,
          body: switch (service.state) {
            ExpensesByMonthServiceLoadingState() => _ReloadingStateWidget(),
            ExpensesByMonthServiceReadyState() => _ReadyStateWidget(
              service: service,
            ),
            ExpensesByMonthServiceNotReadyState() => _NotReadyStateWidget(),
            ExpensesByMonthServiceErrorState() => _ErrorStateWidget(
              service: service,
            ),
          },
        );
      },
    );
  }
}

class _LoadingStateWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            double size = max(100, min(constraints.maxWidth - 150, 200));

            return SizedBox(
              width: size,
              height: size,
              child: CircularProgressIndicator(strokeWidth: 10),
            );
          },
        ),
      ],
    ),
  );
}

/// Dependency injection for [ExpensesByMonthService].
class ExpensesByMonthServiceProvider extends InheritedWidget {
  final ExpensesByMonthService service;

  const ExpensesByMonthServiceProvider({
    super.key,
    required this.service,
    required super.child,
  });

  static ExpensesByMonthServiceProvider? maybeOf(BuildContext context) =>
      context
          .dependOnInheritedWidgetOfExactType<ExpensesByMonthServiceProvider>();

  static ExpensesByMonthServiceProvider of(BuildContext context) {
    final provider = maybeOf(context);
    assert(
      provider != null,
      'No ExpensesByMonthServiceProvider found in context.',
    );
    return provider!;
  }

  @override
  bool updateShouldNotify(covariant ExpensesByMonthServiceProvider oldWidget) =>
      this != oldWidget;
}

/// The [ExpensesByMonthService] loads data in the background to initialize itself.
/// This widget provides something to look at until the service is initialized.
/// Once initialized, it renders the provided [child], which can then use the
/// [ExpensesByMonthServiceProvider] to access the service.
class _ExpensesByMonthServiceLoader extends StatefulWidget {
  final ExpensesDataRepository repository;
  final Widget child;

  const _ExpensesByMonthServiceLoader({
    super.key,
    required this.repository,
    required this.child,
  });

  @override
  State<StatefulWidget> createState() => _ExpensesByMonthServiceLoaderState();
}

class _ExpensesByMonthServiceLoaderState
    extends State<_ExpensesByMonthServiceLoader> {
  late Future<ExpensesByMonthService> _serviceFuture;
  @override
  void initState() {
    super.initState();
    _serviceFuture = Future<ExpensesByMonthService>.delayed(
      Duration(milliseconds: 500),
      () => ExpensesByMonthService.init(widget.repository),
    );
  }

  @override
  Widget build(BuildContext context) => FutureBuilder(
    future: _serviceFuture,
    builder: (context, snapshot) {
      if (snapshot.connectionState == .done) {
        /* It's pretty safe to assume the Future will complete without
           * throwing an exception because the service itself catches
           * exceptions and reflects that in its state.
           */
        return ExpensesByMonthServiceProvider(
          service: snapshot.requireData,
          child: widget.child,
        );
      } else {
        return _LoadingStateWidget();
      }
    },
  );
}

class _ReloadingStateWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final backgroundColor = theme.colorScheme.inversePrimary;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              double size = max(100, min(constraints.maxWidth - 150, 200));

              return SizedBox(
                width: size,
                height: size,
                child: CircularProgressIndicator(strokeWidth: 10),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _NotReadyStateWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          LayoutBuilder(
            builder: (context, constraints) => Icon(
              Icons.error,
              size: max(100, min(constraints.maxWidth - 150, 200)),
              color: theme.primaryColorLight,
            ),
          ),
          Text(
            'No data available',
            style: theme.textTheme.titleLarge?.copyWith(
              color: theme.primaryColorLight,
            ),
          ),
          SizedBox(height: 10),
          Text(
            'To view the month report you first need to add your expenses.',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.primaryColorLight,
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorStateWidget extends StatelessWidget {
  final ExpensesByMonthService service;

  const _ErrorStateWidget({required this.service});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          LayoutBuilder(
            builder: (context, constraints) => Icon(
              Icons.error,
              size: max(100, min(constraints.maxWidth - 150, 200)),
              color: theme.primaryColorLight,
            ),
          ),
          Text(
            'Something went wrong',
            style: theme.textTheme.titleLarge?.copyWith(
              color: theme.primaryColorLight,
            ),
          ),
          SizedBox(height: 10),
          Text(
            'Unfortunately, your expenses could not be accessed.',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.primaryColorLight,
            ),
          ),
          Text(
            service.state.toString(),
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.primaryColorLight,
            ),
          ),
        ],
      ),
    );
  }
}

class _ReadyStateWidget extends StatefulWidget {
  final ExpensesByMonthService service;

  const _ReadyStateWidget({required this.service});

  @override
  State<_ReadyStateWidget> createState() => _ReadyStateWidgetState();
}

class _ReadyStateWidgetState extends State<_ReadyStateWidget> {
  final TextEditingController controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final categories = ExpenseCategories(colorScheme: theme.colorScheme);
    final chartData = widget.service.data.entries
        .map((entry) => (entry.key.month, entry.value))
        .toList();
    chartData.sort((a, b) => a.$1.compareTo(b.$1));

    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            DropdownMenu(
              label: Text(
                'Year',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.primaryColor,
                ),
              ),
              textStyle: theme.textTheme.titleLarge?.copyWith(
                color: theme.primaryColor,
              ),
              controller: controller,
              onSelected: _lookupByYear,
              requestFocusOnTap: false,
              dropdownMenuEntries: widget.service.years
                  .map(
                    (yearKey) => DropdownMenuEntry(
                      value: yearKey,
                      label: yearKey.year.toString(),
                    ),
                  )
                  .toList(),
            ),
            SizedBox(height: 10),
            Wrap(
              children: [
                ExpenseCategoryCard.fromCategory(categories.housing),
                ExpenseCategoryCard.fromCategory(categories.food),
                ExpenseCategoryCard.fromCategory(categories.transportation),
                ExpenseCategoryCard.fromCategory(categories.entertainment),
                ExpenseCategoryCard.fromCategory(categories.fitness),
                ExpenseCategoryCard.fromCategory(categories.education),
              ],
            ),
            SizedBox(height: 10),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    child: SizedBox(
                      width: constraints.maxWidth,
                      height: widget.service.data.length * 50,
                      child: StackedExpensesChart(
                        expenses: chartData.map(
                          (tuple) => (_getMonthName(tuple.$1), tuple.$2),
                        ),
                        categories: categories,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _lookupByYear(ExpensesDataYearKey? yearKey) {
    if (yearKey != null) {
      widget.service.lookup(yearKey);
    }
  }

  String _getMonthName(int month) => switch (month) {
    1 => 'Jan',
    2 => 'Feb',
    3 => 'Mar',
    4 => 'Apr',
    5 => 'May',
    6 => 'Jun',
    7 => 'Jul',
    8 => 'Aug',
    9 => 'Sep',
    10 => 'Oct',
    11 => 'Nov',
    12 => 'Dec',
    _ => throw StateError('Month can only be 1..12.'),
  };
}
