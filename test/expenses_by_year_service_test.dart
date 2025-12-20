import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:monthly_expenses_tracker/expenses_by_year/expenses_by_year_service.dart';
import 'package:monthly_expenses_tracker/expenses_data/expenses_data.dart';
import 'package:monthly_expenses_tracker/expenses_data/expenses_data_repository.dart';

void main() {
  late Directory tempDir;
  late ExpensesDataRepository repository;
  late ExpensesByYearService service;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('monthly_expenses_tracker');
    repository = await ExpensesDataRepository.init(directory: tempDir);
    service = await ExpensesByYearService.init(repository);
  });

  tearDown(() async {
    await repository.close();
    await tempDir.delete(recursive: true);
  });

  test('initial state', () {
    expect(service.data, {});
    expect(service.state, isA<ExpensesByYearServiceNotReadyState>());
  });

  test('lookup without data', () async {
    await service.lookup();

    expect(service.data, {});
    expect(service.state, isA<ExpensesByYearServiceNotReadyState>());
  });

  test('lookup with data', () async {
    await loadTestData(repository);
    await service.lookup();
    final data = service.data;
    final years = data.keys.toList();

    years.sort();

    expect(service.state, isA<ExpensesByYearServiceReadyState>());
    expect(data.keys.length, 3);
    expect(years[0].year, 2018);
    expect(years[1].year, 2019);
    expect(years[2].year, 2020);

    final year1 = years[0];
    final year2 = years[1];
    final year3 = years[2];

    expect(data[year1]?.housing, 12000.0);
    expect(data[year1]?.food, 3600.0);
    expect(data[year1]?.transportation, 3600.0);
    expect(data[year1]?.fitness, 720.0);
    expect(data[year1]?.education, 180.0);
    expect(data[year1]?.entertainment, 1440.0);

    expect(data[year2]?.housing, 18000.0);
    expect(data[year2]?.food, 4200.0);
    expect(data[year2]?.transportation, 3840.0);
    expect(data[year2]?.fitness, 780.0);
    expect(data[year2]?.education, 240.0);
    expect(data[year2]?.entertainment, 1500.0);

    expect(data[year3]?.housing, 24000.0);
    expect(data[year3]?.food, 6000.0);
    expect(data[year3]?.transportation, 4800.0);
    expect(data[year3]?.fitness, 780.0);
    expect(data[year3]?.education, 0.0);
    expect(data[year3]?.entertainment, 840.0);
  });
}

Future<void> loadTestData(ExpensesDataRepository repository) {
  final data =
      {
        // housing, food, transportation, fitness, education, entertainment,
        "2018:01": (1000.0, 300.0, 300.0, 60.0, 15.0, 120.0),
        "2018:02": (1000.0, 300.0, 300.0, 60.0, 15.0, 120.0),
        "2018:03": (1000.0, 300.0, 300.0, 60.0, 15.0, 120.0),
        "2018:04": (1000.0, 300.0, 300.0, 60.0, 15.0, 120.0),
        "2018:05": (1000.0, 300.0, 300.0, 60.0, 15.0, 120.0),
        "2018:06": (1000.0, 300.0, 300.0, 60.0, 15.0, 120.0),
        "2018:07": (1000.0, 300.0, 300.0, 60.0, 15.0, 120.0),
        "2018:08": (1000.0, 300.0, 300.0, 60.0, 15.0, 120.0),
        "2018:09": (1000.0, 300.0, 300.0, 60.0, 15.0, 120.0),
        "2018:10": (1000.0, 300.0, 300.0, 60.0, 15.0, 120.0),
        "2018:11": (1000.0, 300.0, 300.0, 60.0, 15.0, 120.0),
        "2018:12": (1000.0, 300.0, 300.0, 60.0, 15.0, 120.0),
        "2019:01": (1500.0, 350.0, 320.0, 65.0, 20.0, 125.0),
        "2019:02": (1500.0, 350.0, 320.0, 65.0, 20.0, 125.0),
        "2019:03": (1500.0, 350.0, 320.0, 65.0, 20.0, 125.0),
        "2019:04": (1500.0, 350.0, 320.0, 65.0, 20.0, 125.0),
        "2019:05": (1500.0, 350.0, 320.0, 65.0, 20.0, 125.0),
        "2019:06": (1500.0, 350.0, 320.0, 65.0, 20.0, 125.0),
        "2019:07": (1500.0, 350.0, 320.0, 65.0, 20.0, 125.0),
        "2019:08": (1500.0, 350.0, 320.0, 65.0, 20.0, 125.0),
        "2019:09": (1500.0, 350.0, 320.0, 65.0, 20.0, 125.0),
        "2019:10": (1500.0, 350.0, 320.0, 65.0, 20.0, 125.0),
        "2019:11": (1500.0, 350.0, 320.0, 65.0, 20.0, 125.0),
        "2019:12": (1500.0, 350.0, 320.0, 65.0, 20.0, 125.0),
        "2020:01": (2000.0, 500.0, 400.0, 65.0, 0.0, 70.0),
        "2020:02": (2000.0, 500.0, 400.0, 65.0, 0.0, 70.0),
        "2020:03": (2000.0, 500.0, 400.0, 65.0, 0.0, 70.0),
        "2020:04": (2000.0, 500.0, 400.0, 65.0, 0.0, 70.0),
        "2020:05": (2000.0, 500.0, 400.0, 65.0, 0.0, 70.0),
        "2020:06": (2000.0, 500.0, 400.0, 65.0, 0.0, 70.0),
        "2020:07": (2000.0, 500.0, 400.0, 65.0, 0.0, 70.0),
        "2020:08": (2000.0, 500.0, 400.0, 65.0, 0.0, 70.0),
        "2020:09": (2000.0, 500.0, 400.0, 65.0, 0.0, 70.0),
        "2020:10": (2000.0, 500.0, 400.0, 65.0, 0.0, 70.0),
        "2020:11": (2000.0, 500.0, 400.0, 65.0, 0.0, 70.0),
        "2020:12": (2000.0, 500.0, 400.0, 65.0, 0.0, 70.0),
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

  return repository.updateAll(data);
}
