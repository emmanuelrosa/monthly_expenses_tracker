import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:monthly_expenses_tracker/data_entry/data_entry_service.dart';
import 'package:monthly_expenses_tracker/expense_category/expense_categories.dart';
import 'package:monthly_expenses_tracker/expense_category/expense_category_card.dart';
import 'package:monthly_expenses_tracker/expenses_chart/expenses_pie_chart.dart';
import 'package:monthly_expenses_tracker/expenses_data/expenses_data_repository.dart';

/// The top-level [Widget] of the data entry page.
/// It starts with a loader [Widget] which loads the [DataEntryService],
/// and then transfers control to the actual UI.
class DataEntryPage extends StatelessWidget {
  const DataEntryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final repository = ExpensesDataRepositoryProvider.of(context).repository;

    return _DataEntryServiceLoader(
      repository: repository,
      child: _DataEntryServiceLoaded(),
    );
  }
}

/// [Widget] responsible for initializing the [DataEntryService].
/// Once initialized, the service is handed over to a provider.
class _DataEntryServiceLoader extends StatefulWidget {
  final ExpensesDataRepository repository;
  final Widget child;

  const _DataEntryServiceLoader({
    required this.repository,
    required this.child,
  });

  @override
  State<StatefulWidget> createState() => _DataEntryServiceLoaderState();
}

class _DataEntryServiceLoaderState extends State<_DataEntryServiceLoader> {
  late Future<DataEntryService> _serviceFuture;

  @override
  void initState() {
    super.initState();
    _serviceFuture = Future<DataEntryService>.delayed(
      Duration(milliseconds: 250),
      () => DataEntryService.init(widget.repository),
    );
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<DataEntryService>(
    future: _serviceFuture,
    builder: (context, snapshot) {
      if (snapshot.connectionState == .done) {
        return DataEntryServiceProvider(
          service: snapshot.requireData,
          child: widget.child,
        );
      } else {
        return _LoadingStateWidget();
      }
    },
  );
}

/// The [Widget] displayed while the [DataEntryService] is being initialized.
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

/// Dependency injection for [DataEntryService].
class DataEntryServiceProvider extends InheritedWidget {
  final DataEntryService service;

  const DataEntryServiceProvider({
    super.key,
    required this.service,
    required super.child,
  });

  static DataEntryServiceProvider? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<DataEntryServiceProvider>();

  static DataEntryServiceProvider of(BuildContext context) {
    final provider = maybeOf(context);
    assert(provider != null, 'No DataEntryServiceProvider found in context.');
    return provider!;
  }

  @override
  bool updateShouldNotify(covariant DataEntryServiceProvider oldWidget) =>
      this != oldWidget;
}

/// The main UI.
class _DataEntryServiceLoaded extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _DataEntryServiceLoadedState();
}

class _DataEntryServiceLoadedState extends State<_DataEntryServiceLoaded> {
  @override
  Widget build(BuildContext context) {
    final service = DataEntryServiceProvider.of(context).service;

    return ListenableBuilder(
      listenable: service,
      builder: (context, _) {
        final theme = Theme.of(context);
        final backgroundColor = switch (service.state) {
          DataEntryServiceLoadingState() => theme.colorScheme.inversePrimary,
          DataEntryServiceFinishedState() => theme.colorScheme.inversePrimary,
          DataEntryServiceErrorState() => theme.colorScheme.secondary,
        };

        return Container(
          color: backgroundColor,
          child: switch (service.state) {
            DataEntryServiceLoadingState() => _FinishedStateWidget(
              service: service,
            ),
            DataEntryServiceFinishedState() => _FinishedStateWidget(
              service: service,
            ),
            DataEntryServiceErrorState() => _ErrorStateWidget(service: service),
          },
        );
      },
    );
  }
}

class _ErrorStateWidget extends StatelessWidget {
  final DataEntryService service;

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

class _FinishedStateWidget extends StatefulWidget {
  final DataEntryService service;

  const _FinishedStateWidget({required this.service});

  @override
  State<StatefulWidget> createState() => _FinishedStateWidgetState();
}

class _FinishedStateWidgetState extends State<_FinishedStateWidget> {
  final TextEditingController yearController = TextEditingController();
  final TextEditingController monthController = TextEditingController();
  final TextEditingController housingController = TextEditingController();
  final TextEditingController foodController = TextEditingController();
  final TextEditingController transportationController =
      TextEditingController();
  final TextEditingController entertainmentController = TextEditingController();
  final TextEditingController fitnessController = TextEditingController();
  final TextEditingController educationController = TextEditingController();

  @override
  void initState() {
    super.initState();
    yearController.text = widget.service.year.toString();
    monthController.text = widget.service.months[widget.service.month - 1].name;

    if (widget.service.data != null) {
      final data = widget.service.data!;

      housingController.text = data.housing.toString();
      foodController.text = data.food.toString();
      transportationController.text = data.transportation.toString();
      entertainmentController.text = data.entertainment.toString();
      fitnessController.text = data.fitness.toString();
      educationController.text = data.education.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final categories = ExpenseCategories(colorScheme: theme.colorScheme);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            Wrap(
              spacing: 10.0,
              runSpacing: 10.0,
              children: [
                DropdownMenu<int>(
                  label: Text(
                    'Year',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: theme.primaryColor,
                    ),
                  ),
                  textStyle: theme.textTheme.titleLarge?.copyWith(
                    color: theme.primaryColor,
                  ),
                  menuHeight: 400,
                  width: 200.0,
                  requestFocusOnTap: false,
                  controller: yearController,
                  onSelected: (year) {
                    if (year != null) {
                      _setDate(year: year, month: widget.service.month);
                    }
                  },
                  dropdownMenuEntries: widget.service.years
                      .map(
                        (year) => DropdownMenuEntry(
                          value: year,
                          label: year.toString(),
                        ),
                      )
                      .toList(),
                ),
                DropdownMenu<Month>(
                  label: Text(
                    'Month',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: theme.primaryColor,
                    ),
                  ),
                  textStyle: theme.textTheme.titleLarge?.copyWith(
                    color: theme.primaryColor,
                  ),
                  menuHeight: 400.0,
                  width: 200.0,
                  requestFocusOnTap: false,
                  controller: monthController,
                  onSelected: (month) {
                    if (month != null) {
                      _setDate(year: widget.service.year, month: month.number);
                    }
                  },
                  dropdownMenuEntries: widget.service.months
                      .map(
                        (month) =>
                            DropdownMenuEntry(value: month, label: month.name),
                      )
                      .toList(),
                ),
              ],
            ),
            SizedBox(height: 10.0),
            Wrap(
              spacing: 10.0,
              runSpacing: 10.0,
              children:
                  [
                        ('Housing', housingController),
                        ('Food', foodController),
                        ('Transportation', transportationController),
                        ('Entertainment', entertainmentController),
                        ('Fitness', fitnessController),
                        ('Education', educationController),
                      ]
                      .map(
                        (tuple) => SizedBox(
                          width: 200,
                          child: TextField(
                            controller: tuple.$2,
                            keyboardType: .number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            decoration: InputDecoration(label: Text(tuple.$1)),
                          ),
                        ),
                      )
                      .toList(),
            ),
            SizedBox(height: 10.0),
            FilledButton.tonal(
              onPressed: () => _update(context),
              child: Text(
                'Save',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.primaryColor,
                ),
              ),
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
            LayoutBuilder(
              builder: (context, constraints) {
                final size =
                    (constraints.maxWidth < constraints.maxHeight
                        ? constraints.maxWidth
                        : constraints.maxHeight) *
                    0.5;

                return SizedBox(
                  width: size,
                  height: size,
                  child: widget.service.data == null
                      ? Container(
                          decoration: BoxDecoration(
                            color: theme.primaryColor,
                            shape: BoxShape.circle,
                          ),
                        )
                      : ExpensesPieChart(
                          expenses: widget.service.data!,
                          categories: categories,
                        ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _setDate({required int year, required int month}) async {
    await widget.service.setDate(month: month, year: year);

    if (widget.service.data != null) {
      final data = widget.service.data!;
      setState(() {
        housingController.text = data.housing.toString();
        foodController.text = data.food.toString();
        transportationController.text = data.transportation.toString();
        entertainmentController.text = data.entertainment.toString();
        fitnessController.text = data.fitness.toString();
        educationController.text = data.education.toString();
        housingController.text = data.housing.toString();
        foodController.text = data.food.toString();
        transportationController.text = data.transportation.toString();
        entertainmentController.text = data.entertainment.toString();
        fitnessController.text = data.fitness.toString();
        educationController.text = data.education.toString();
      });
    }
  }

  void _update(BuildContext context) async {
    final theme = Theme.of(context);
    final sms = ScaffoldMessenger.of(context);

    await widget.service.update(
      housing: double.tryParse(housingController.text) ?? 0.0,
      food: double.tryParse(foodController.text) ?? 0.0,
      transportation: double.tryParse(transportationController.text) ?? 0.0,
      entertainment: double.tryParse(entertainmentController.text) ?? 0.0,
      fitness: double.tryParse(fitnessController.text) ?? 0.0,
      education: double.tryParse(educationController.text) ?? 0.0,
    );

    if (widget.service.state is DataEntryServiceFinishedState && sms.mounted) {
      sms.showSnackBar(
        SnackBar(
          content: ListTile(
            leading: Icon(Icons.check, color: theme.primaryColorLight),
            title: Text(
              'Expenses saved successfully!',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.primaryColorLight,
              ),
            ),
          ),
        ),
      );
    }
  }
}
