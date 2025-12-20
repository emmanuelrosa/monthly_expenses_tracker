import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:monthly_expenses_tracker/expenses_data/expenses_data_repository.dart';

sealed class ExpensesExportServiceState {
  const ExpensesExportServiceState();
}

class ExpensesExportServiceReadyState extends ExpensesExportServiceState {}

class ExpensesExportServiceNotReadyState extends ExpensesExportServiceState {}

class ExpensesExportServiceExportingState extends ExpensesExportServiceState {
  final double progress;

  const ExpensesExportServiceExportingState(this.progress);
}

class ExpensesExportServiceErrorState extends ExpensesExportServiceState {
  final String message;

  const ExpensesExportServiceErrorState(this.message);
}

/// This service provides the ability to export the [ExpensesData] to a CSV file.
class ExpensesExportService with ChangeNotifier {
  final ExpensesDataRepository _repository;
  ExpensesExportServiceState _state = ExpensesExportServiceNotReadyState();

  /// Initializes the service.
  /// The [state] will be set depending on whether the [repository] has data.
  ExpensesExportService(ExpensesDataRepository repository)
    : _repository = repository {
    _state = _repository.hasData
        ? ExpensesExportServiceReadyState()
        : ExpensesExportServiceNotReadyState();
  }

  /// Returns the current [ExpensesExportServiceState] of the service.
  ExpensesExportServiceState get state => _state;

  /// Exports the [ExpenseData] records to a [Uint8List] formatted as CSV.
  /// If provided, the callback is called with the bytes ready to write to a file.
  /// The [state] is updated along the way to indicate progress, and to yield
  /// to the Dart runtime.
  /// Only call when [state] is [ExpensesExportServiceReadyState].
  /// Throws [AssertionError] if the repository doesn't have any data.
  Future<void> exportExpenses([
    void Function(Uint8List bytes)? completed,
  ]) async {
    assert(
      _repository.hasData,
      'exportExpenses() cannot be called when there is no data available.',
    );

    final builder = BytesBuilder();
    final totalNumberOfLines = _repository.numberOfRecords + 1;
    var recordCount = 1;

    await for (final line in toCSV()) {
      final bytes = utf8.encode(line);
      builder.add(bytes);
      _state = ExpensesExportServiceExportingState(
        recordCount / totalNumberOfLines,
      );
      notifyListeners();
      recordCount++;
    }

    if (completed != null) {
      completed(builder.toBytes());
    }

    _state = ExpensesExportServiceReadyState();
    notifyListeners();
  }

  /// Creates a [Stream] of CSV file lines.
  Stream<String> toCSV() async* {
    final buffer = StringBuffer();

    // Write the CSV header.
    buffer.writeln(
      '"year","month","housing","food","transportation","entertainment","fitness","education"',
    );
    yield buffer.toString();
    buffer.clear();

    // Write the CSV records.
    await for (final entry in _repository.streamAll()) {
      final year = entry.key.year;
      final month = entry.key.month;
      final expenses = entry.value;

      buffer.clear();
      buffer.writeln(
        '$year,$month,${expenses.housing},${expenses.food},${expenses.transportation},${expenses.entertainment},${expenses.fitness},${expenses.education}',
      );
      yield buffer.toString();
    }
  }
}
