import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:monthly_expenses_tracker/expenses_by_month/expenses_by_month_service.dart';
import 'package:monthly_expenses_tracker/expenses_data/expenses_data.dart';
import 'package:monthly_expenses_tracker/expenses_data/expenses_data_repository.dart';

void main() {
  late Directory tempDir;
  late ExpensesDataRepository repository;
  late ExpensesByMonthService service;

  setUpAll(() async {
    tempDir = await Directory.systemTemp.createTemp('monthly_expenses_tracker');
    repository = await ExpensesDataRepository.init(directory: tempDir);
    service = ExpensesByMonthService(repository);
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
    expect(service.data, {});
    expect(service.state.value, isA<ExpensesByMonthServiceLoadingState>());
  });

  test('lookup', () async {
    final years = await repository.lookupYears();
    years.sort();

    await service.lookup(years.first);
    final result1 = service.data;

    expect(service.state.value, isA<ExpensesByMonthServiceFinishedState>());
    expect(result1.keys.length, 12);
    expect(result1.keys.first.year, 2018);
    expect(result1[ExpensesDataKey(month: 6, year: 2018)]?.housing, 1100);

    await service.lookup(years.last);
    final result2 = service.data;

    expect(service.state.value, isA<ExpensesByMonthServiceFinishedState>());
    expect(result2.keys.length, 6);
    expect(result2.keys.first.year, 2019);
    expect(result2[ExpensesDataKey(month: 1, year: 2019)]?.housing, 1500);
  });
}
