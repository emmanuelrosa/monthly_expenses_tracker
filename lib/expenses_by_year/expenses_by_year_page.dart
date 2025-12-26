import 'dart:math';

import 'package:flutter/material.dart';
import 'package:monthly_expenses_tracker/expense_category/expense_categories.dart';
import 'package:monthly_expenses_tracker/expense_category/expense_category_card.dart';
import 'package:monthly_expenses_tracker/expenses_by_year/expenses_by_year_service.dart';
import 'package:monthly_expenses_tracker/expenses_chart/stacked_expenses_chart.dart';
import 'package:monthly_expenses_tracker/expenses_data/expenses_data_repository.dart';

/// The top-level widget of the expenses by year feature.
class ExpensesByYearPage extends StatelessWidget {
  const ExpensesByYearPage({super.key});

  @override
  Widget build(BuildContext context) {
    final repository = ExpensesDataRepositoryProvider.of(context).repository;

    return _ExpensesByYearServiceLoader(
      repository: repository,
      child: _ExpensesByYearServiceLoaded(),
    );
  }
}

/// Once the [ExpensesByYearService] has been initialized, this widget is used
/// to render the main UI for this feature.
class _ExpensesByYearServiceLoaded extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final service = ExpensesByYearServiceProvider.of(context).service;

    return ListenableBuilder(
      listenable: service,
      builder: (context, _) {
        final theme = Theme.of(context);
        final backgroundColor = switch (service.state) {
          ExpensesByYearServiceLoadingState() =>
            theme.colorScheme.inversePrimary,
          ExpensesByYearServiceReadyState() => theme.colorScheme.inversePrimary,
          ExpensesByYearServiceNotReadyState() => theme.colorScheme.secondary,
          ExpensesByYearServiceErrorState() => theme.colorScheme.secondary,
        };
        final titleColor = switch (service.state) {
          ExpensesByYearServiceLoadingState() => theme.primaryColor,
          ExpensesByYearServiceReadyState() => theme.primaryColor,
          ExpensesByYearServiceNotReadyState() => theme.primaryColorLight,
          ExpensesByYearServiceErrorState() => theme.primaryColorLight,
        };

        return Container(
          color: backgroundColor,
          child: switch (service.state) {
            ExpensesByYearServiceLoadingState() => throw StateError(
              'The ExpensesByYearService should have already loaded.',
            ),
            ExpensesByYearServiceReadyState() => _ReadyStateWidget(
              service: service,
            ),
            ExpensesByYearServiceNotReadyState() => _NotReadyStateWidget(),
            ExpensesByYearServiceErrorState() => _ErrorStateWidget(
              service: service,
            ),
          },
        );
      },
    );
  }
}

/// Dependency injection for [ExpensesByYearService].
class ExpensesByYearServiceProvider extends InheritedWidget {
  final ExpensesByYearService service;

  const ExpensesByYearServiceProvider({
    super.key,
    required this.service,
    required super.child,
  });

  static ExpensesByYearServiceProvider? maybeOf(BuildContext context) => context
      .dependOnInheritedWidgetOfExactType<ExpensesByYearServiceProvider>();

  static ExpensesByYearServiceProvider of(BuildContext context) {
    final provider = maybeOf(context);
    assert(
      provider != null,
      'No ExpensesByYearServiceProvider found in context.',
    );
    return provider!;
  }

  @override
  bool updateShouldNotify(covariant ExpensesByYearServiceProvider oldWidget) =>
      this != oldWidget;
}

/// The [ExpensesByYearService] loads data in the background to initialize itself.
/// This widget provides something to look at until the service is initialized.
/// Once initialized, it renders the provided [child], which can then use the
/// [ExpensesByYearServiceProvider] to access the service.
class _ExpensesByYearServiceLoader extends StatefulWidget {
  final ExpensesDataRepository repository;
  final Widget child;

  const _ExpensesByYearServiceLoader({
    super.key,
    required this.repository,
    required this.child,
  });

  @override
  State<StatefulWidget> createState() => _ExpensesByYearServiceLoaderState();
}

class _ExpensesByYearServiceLoaderState
    extends State<_ExpensesByYearServiceLoader> {
  late Future<ExpensesByYearService> _serviceFuture;
  @override
  void initState() {
    super.initState();
    _serviceFuture = Future<ExpensesByYearService>.delayed(
      Duration(milliseconds: 250),
      () => ExpensesByYearService.init(widget.repository),
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
        return ExpensesByYearServiceProvider(
          service: snapshot.requireData,
          child: widget.child,
        );
      } else {
        return _LoadingStateWidget();
      }
    },
  );
}

class _LoadingStateWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final backgroundColor = theme.colorScheme.inversePrimary;

    return Container(
      color: backgroundColor,
      child: Center(
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
            'To view the yearly report you first need to add your expenses.',
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
  final ExpensesByYearService service;

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

class _ReadyStateWidget extends StatelessWidget {
  final ExpensesByYearService service;

  const _ReadyStateWidget({required this.service});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final categories = ExpenseCategories(colorScheme: theme.colorScheme);
    final chartData = service.data.entries
        .map((entry) => (entry.key.year.toString(), entry.value))
        .toList();
    chartData.sort((a, b) => b.$1.compareTo(a.$1));

    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
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
                      height: service.data.length * 50,
                      child: StackedExpensesChart(
                        expenses: chartData,
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
}
