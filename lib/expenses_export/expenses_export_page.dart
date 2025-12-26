import 'dart:math';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:monthly_expenses_tracker/expenses_data/expenses_data_repository.dart';
import 'package:monthly_expenses_tracker/expenses_export/expenses_export_service.dart';

class ExpensesExportPage extends StatelessWidget {
  const ExpensesExportPage({super.key});

  @override
  Widget build(BuildContext context) {
    final repository = ExpensesDataRepositoryProvider.of(context).repository;
    final service = ExpensesExportService(repository);

    return ExpensesExportServiceProvider(
      service: service,
      child: Builder(
        builder: (context) {
          final service = ExpensesExportServiceProvider.of(context).service;

          return ListenableBuilder(
            listenable: service,
            builder: (context, child) {
              final theme = Theme.of(context);
              final backgroundColor = switch (service.state) {
                ExpensesExportServiceReadyState() =>
                  theme.colorScheme.inversePrimary,
                ExpensesExportServiceNotReadyState() =>
                  theme.colorScheme.secondary,
                ExpensesExportServiceErrorState() =>
                  theme.colorScheme.secondary,
                ExpensesExportServiceExportingState() =>
                  theme.colorScheme.inversePrimary,
              };

              return Container(
                color: backgroundColor,
                child: switch (service.state) {
                  ExpensesExportServiceReadyState() => _ReadyStateWidget(
                    service: service,
                  ),
                  ExpensesExportServiceNotReadyState() =>
                    _NotReadyStateWidget(),
                  ExpensesExportServiceErrorState() => _ErrorStateWidget(
                    service: service,
                  ),
                  ExpensesExportServiceExportingState(progress: var progress) =>
                    _ExportingStateWidget(progress: progress),
                },
              );
            },
          );
        },
      ),
    );
  }
}

class _ReadyStateWidget extends StatelessWidget {
  final ExpensesExportService service;

  const _ReadyStateWidget({super.key, required this.service});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          LayoutBuilder(
            builder: (context, constraints) => Icon(
              FontAwesomeIcons.fileCsv,
              size: max(100, min(constraints.maxWidth - 150, 200)),
              color: theme.primaryColor,
            ),
          ),
          SizedBox(height: 30),
          Text(
            'You can export your expenses to a CSV file.',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.primaryColor,
            ),
          ),
          SizedBox(height: 30),
          FilledButton.tonal(
            onPressed: () => _exportCsvFile(context),
            child: Text(
              'Export to a CSV file',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.primaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _exportCsvFile(BuildContext context) {
    final service = ExpensesExportServiceProvider.of(context).service;

    service.exportExpenses(
      minimumDelay: Duration(seconds: 1),
      completed: (bytes) async {
        await FilePicker.platform.saveFile(
          dialogTitle: 'Save CSV',
          fileName: 'exported-expenses.csv',
          bytes: bytes,
        );
      },
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
            'Unable to export',
            style: theme.textTheme.titleLarge?.copyWith(
              color: theme.primaryColorLight,
            ),
          ),
          SizedBox(height: 10),
          Text(
            'No expenses were found. Add some expenses and then try again.',
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
  final ExpensesExportService service;

  const _ErrorStateWidget({super.key, required this.service});

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
            'Export failed',
            style: theme.textTheme.titleLarge?.copyWith(
              color: theme.primaryColorLight,
            ),
          ),
          SizedBox(height: 10),
          Text(
            'Unfortunately, your expenses could not be exported.',
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

class _ExportingStateWidget extends StatelessWidget {
  final double progress;

  const _ExportingStateWidget({super.key, required this.progress});

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
              child: CircularProgressIndicator(
                strokeWidth: 10,
                value: progress,
              ),
            );
          },
        ),
      ],
    ),
  );
}
