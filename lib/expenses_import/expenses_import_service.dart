import 'dart:convert';

import 'package:fast_csv/fast_csv.dart' as csv;
import 'package:flutter/foundation.dart';
import 'package:monthly_expenses_tracker/expenses_data/expenses_data.dart';
import 'package:monthly_expenses_tracker/expenses_data/expenses_data_repository.dart';

class ExpenseFormatException implements Exception {
  final int row;
  final int column;
  final bool isNegative;

  const ExpenseFormatException(
    this.row,
    this.column, {
    this.isNegative = false,
  });

  @override
  String toString() => isNegative
      ? 'Rejected expense on row $row column $column because negative values are not allowed.'
      : 'Unable to parse the expense on row $row column $column.';
}

class YearFormatException implements Exception {
  final int row;

  const YearFormatException(this.row);

  @override
  String toString() =>
      'Unable to parse the year on row $row, column 1. The year must be a whole number >= 1969.';
}

class MonthFormatException implements Exception {
  final int row;

  const MonthFormatException(this.row);

  @override
  String toString() =>
      'Unable to parse the month on row $row, column 2. The month must be a whole number >= 1 and <= 12.';
}

class CsvRowFormatException implements Exception {
  final int row;
  final int columns;

  const CsvRowFormatException(this.row, this.columns);

  @override
  String toString() =>
      'Row $row should have 8 columns, but has $columns columns.';
}

sealed class ExpensesImportServiceState {
  const ExpensesImportServiceState();
}

class ExpensesImportServiceReadyState extends ExpensesImportServiceState {}

class ExpensesImportServiceImportingState extends ExpensesImportServiceState {}

class ExpensesImportServiceErrorState extends ExpensesImportServiceState {
  final String message;

  const ExpensesImportServiceErrorState(this.message);

  @override
  String toString() => message;
}

/// This service handles importing a CSV file into the [ExpensesDataRepository].
class ExpensesImportService {
  final ExpensesDataRepository _repository;
  final ValueNotifier<ExpensesImportServiceState> _state = ValueNotifier(
    ExpensesImportServiceReadyState(),
  );

  ExpensesImportService(ExpensesDataRepository repository)
    : _repository = repository;

  /// Returns a [ValueNotifier] with the current state of the service.
  ValueNotifier<ExpensesImportServiceState> get state => _state;

  /// Parses an expense from the given line and column.
  /// Throws [ExpenseFormatException] when there's a parsing error.
  double _parseExpense({
    required List<String> line,
    required int row,
    required int column,
  }) {
    final value = double.tryParse(line[column]);

    if (value == null) {
      throw ExpenseFormatException(row + 1, column + 1);
    }

    if (value < 0) {
      throw ExpenseFormatException(row + 1, column + 1, isNegative: true);
    }

    return value;
  }

  /// Transforms a [Stream] of CSV rows into a [Stream] of validated data.
  Stream<MapEntry<ExpensesDataKey, ExpensesData>> _convertToExpenses(
    Stream<List<String>> stream,
  ) async* {
    int row = 0;

    await for (final line in stream) {
      if (line.isEmpty) {
        row++;
        continue;
      }

      // Skip the header row.
      if (line[0] == 'year') {
        row++;
        continue;
      }

      // These statements will throw an exception if there's a parsing error.
      if (line.length != 8) {
        throw CsvRowFormatException(row + 1, line.length);
      }

      final year = int.tryParse(line[0]);
      final month = int.tryParse(line[1]);

      if (year == null || year < 1969) {
        throw YearFormatException(row + 1);
      }

      if (month == null || month < 1 || month > 12) {
        throw MonthFormatException(row + 1);
      }

      final key = ExpensesDataKey(month: month, year: year);
      final housing = _parseExpense(line: line, row: row, column: 2);
      final food = _parseExpense(line: line, row: row, column: 3);
      final transportation = _parseExpense(line: line, row: row, column: 4);
      final entertainment = _parseExpense(line: line, row: row, column: 5);
      final fitness = _parseExpense(line: line, row: row, column: 6);
      final education = _parseExpense(line: line, row: row, column: 7);

      final data = ExpensesData(
        housing: housing,
        food: food,
        transportation: transportation,
        entertainment: entertainment,
        fitness: fitness,
        education: education,
      );

      yield MapEntry<ExpensesDataKey, ExpensesData>(key, data);
      row++;
    }
  }

  /// Converts bytes into a parsed CSV file.
  Stream<List<String>> _parseCsv(List<int> bytes) {
    final source = utf8.decode(bytes);
    return Stream.fromIterable(csv.parse(source));
  }

  /// Imports the bytes of a CSV file into the [ExpensesDataRepository].
  Future<void> importFromCsv(List<int> bytes) async {
    _state.value = ExpensesImportServiceImportingState();
    final expenses = <ExpensesDataKey, ExpensesData>{};

    try {
      final stream = _convertToExpenses(_parseCsv(bytes));

      await for (final entry in stream) {
        expenses[entry.key] = entry.value;
      }
    } catch (e) {
      _state.value = ExpensesImportServiceErrorState(e.toString());
      return;
    }

    await _repository.updateAll(expenses);
    _state.value = ExpensesImportServiceReadyState();
  }
}
