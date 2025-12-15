import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:monthly_expenses_tracker/expenses_data/expenses_data.dart';
import 'package:monthly_expenses_tracker/expenses_data/expenses_data_repository.dart';
import 'package:monthly_expenses_tracker/expenses_export/expenses_export_service.dart';

void main() {
  late Directory tempDir;
  late ExpensesDataRepository repository;
  late ExpensesExportService service;

  setUpAll(() async {
    tempDir = await Directory.systemTemp.createTemp('monthly_expenses_tracker');
    repository = await ExpensesDataRepository.init(directory: tempDir);
    service = ExpensesExportService(repository);
    final data =
        {
          // housing, food, transportation, fitness, education, entertainment,
          "2018:01": (1000.0, 300.0, 300.0, 60.0, 15.0, 120.0),
          "2018:02": (1000.0, 300.0, 300.0, 60.0, 15.0, 120.0),
          "2018:03": (1000.0, 300.0, 300.0, 60.0, 15.0, 120.0),
          "2018:04": (1000.0, 300.0, 300.0, 60.0, 15.0, 120.0),
          "2018:05": (1000.0, 300.0, 300.0, 60.0, 15.0, 120.0),
          "2018:06": (1100.0, 300.0, 300.0, 60.0, 15.0, 120.0),
          "2018:07": (1100.0, 300.0, 300.0, 60.0, 15.0, 120.0),
          "2018:08": (1100.0, 300.0, 300.0, 60.0, 15.0, 120.0),
          "2018:09": (1100.0, 300.0, 300.0, 60.0, 15.0, 120.0),
          "2018:10": (1100.0, 300.0, 300.0, 60.0, 15.0, 120.0),
          "2018:11": (1100.0, 300.0, 300.0, 60.0, 15.0, 120.0),
          "2018:12": (1100.0, 300.0, 300.0, 60.0, 15.0, 120.0),
          "2019:01": (1500.0, 350.0, 320.0, 65.0, 20.0, 125.0),
          "2019:02": (1500.0, 350.0, 320.0, 65.0, 20.0, 125.0),
          "2019:03": (1500.0, 350.0, 320.0, 65.0, 20.0, 125.0),
          "2019:04": (1500.0, 350.0, 320.0, 65.0, 20.0, 125.0),
          "2019:05": (1500.0, 350.0, 320.0, 65.0, 20.0, 125.0),
          "2019:06": (1500.0, 350.0, 320.0, 65.0, 20.0, 125.0),
        }.map(
          (key, value) => MapEntry<ExpensesDataKey, ExpensesData>(
            ExpensesDataKey.fromString(key),
            ExpensesData(
              housing: value.$1,
              food: value.$2,
              transportation: value.$3,
              fitness: value.$4,
              education: value.$5,
              entertainment: value.$6,
            ),
          ),
        );

    for (var entry in data.entries) {
      await repository.update(key: entry.key, data: entry.value);
    }
  });

  tearDownAll(() async {
    await repository.close();
    await tempDir.delete(recursive: true);
  });

  test('initial state', () {
    expect(service.state.value, isA<ExpensesExportServiceReadyState>());
  });

  test('toCSV', () async {
    final result = await service.toCSV().toList();
    final header = result[0].split(',');
    final firstRow = result[1].split(',');

    expect(result.length, 19);
    expect(header[0], '"year"');
    expect(header[1], '"month"');
    expect(header[2], '"housing"');
    expect(header[3], '"food"');
    expect(header[4], '"transportation"');
    expect(header[5], '"entertainment"');
    expect(header[6], '"fitness"');
    expect(header[7], '"education"\n');
    expect(firstRow[0], '2018');
    expect(firstRow[1], '1');
    expect(firstRow[2], '1000.0');
    expect(firstRow[3], '300.0');
    expect(firstRow[4], '300.0');
    expect(firstRow[5], '120.0');
    expect(firstRow[6], '60.0');
    expect(firstRow[7], '15.0\n');
  });

  test('exportExpenses', () async {
    final callback = expectAsync1<void, Uint8List>((_) {});
    await service.exportExpenses(callback);

    expect(service.state.value, isA<ExpensesExportServiceReadyState>());
  });
}
