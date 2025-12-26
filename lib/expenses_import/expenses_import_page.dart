import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:monthly_expenses_tracker/expenses_data/expenses_data_repository.dart';
import 'package:monthly_expenses_tracker/expenses_import/expenses_import_service.dart';

/// The button click handler to import a CSV file.
void _importCsvFile(BuildContext context) async {
  final service = ExpensesImportServiceProvider.of(context).service;
  final sms = ScaffoldMessenger.of(context);
  final theme = Theme.of(context);
  Uint8List? bytes;
  final result = await FilePicker.platform.pickFiles(
    dialogTitle: 'Import CSV file',
    type: FileType.custom,
    allowedExtensions: ['csv'],
  );

  if (result == null || result.files.isEmpty) {
    return;
  }

  final file = result.files.first;

  // The file data is provided differently depending on the platform.
  if (file.bytes != null) {
    bytes = result.files.first.bytes;
  } else if (file.path != null) {
    bytes = await File(file.path!).readAsBytes();
  }

  if (bytes != null) {
    await service.importFromCsv(bytes, minimumDelay: Duration(seconds: 1));

    if (service.state is ExpensesImportServiceReadyState && sms.mounted) {
      sms.showSnackBar(
        SnackBar(
          content: ListTile(
            leading: Icon(Icons.check, color: theme.primaryColorLight),
            title: Text(
              'Expenses imported successfully!',
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

/// The top-level widget implementing the expenses import screen.
class ExpensesImportPage extends StatelessWidget {
  const ExpensesImportPage({super.key});

  @override
  Widget build(BuildContext context) {
    final repository = ExpensesDataRepositoryProvider.of(context).repository;
    final service = ExpensesImportService(repository);

    return ExpensesImportServiceProvider(
      service: service,
      child: Builder(
        builder: (context) {
          final service = ExpensesImportServiceProvider.of(context).service;

          return ListenableBuilder(
            listenable: service,
            builder: (context, child) {
              final theme = Theme.of(context);
              final backgroundColor = switch (service.state) {
                ExpensesImportServiceReadyState() =>
                  theme.colorScheme.inversePrimary,
                ExpensesImportServiceErrorState() =>
                  theme.colorScheme.secondary,
                ExpensesImportServiceImportingState() =>
                  theme.colorScheme.inversePrimary,
              };

              return Container(
                color: backgroundColor,
                child: switch (service.state) {
                  ExpensesImportServiceReadyState() => _ReadyStateWidget(
                    service: service,
                  ),
                  ExpensesImportServiceErrorState() => _ErrorStateWidget(
                    service: service,
                  ),
                  ExpensesImportServiceImportingState() =>
                    _ImportingStateWidget(service: service),
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
  final ExpensesImportService service;

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
            'You can import your expenses from a CSV file.',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.primaryColor,
            ),
          ),
          SizedBox(height: 30),
          OverflowBar(
            overflowAlignment: OverflowBarAlignment.center,
            overflowSpacing: 10,
            spacing: 10,
            children: [
              TextButton(
                onPressed: () =>
                    _downloadExampleCsvFile(DefaultAssetBundle.of(context)),
                child: Text(
                  'Get example CSV file',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.primaryColor,
                  ),
                ),
              ),
              FilledButton.tonal(
                onPressed: () => _importCsvFile(context),
                child: Text(
                  'Import a CSV file',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.primaryColor,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _downloadExampleCsvFile(AssetBundle bundle) async {
    final bytes = (await bundle.load(
      'assets/example.csv',
    )).buffer.asUint8List();
    FilePicker.platform.saveFile(
      dialogTitle: 'Save example CSV',
      fileName: 'example.csv',
      bytes: bytes,
    );
  }
}

class _ImportingStateWidget extends StatelessWidget {
  final ExpensesImportService service;

  const _ImportingStateWidget({super.key, required this.service});

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

class _ErrorStateWidget extends StatelessWidget {
  final ExpensesImportService service;

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
            'Import failed',
            style: theme.textTheme.titleLarge?.copyWith(
              color: theme.primaryColorLight,
            ),
          ),
          SizedBox(height: 10),
          Text(
            'Unfortunately, your expenses could not be imported.',
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
          SizedBox(height: 10),
          Text(
            'Edit your CSV file to correct the problem, then try again.',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.primaryColorLight,
            ),
          ),
          SizedBox(height: 20),
          TextButton(
            onPressed: () => _importCsvFile(context),
            child: Text(
              'Retry',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.primaryColorLight,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
