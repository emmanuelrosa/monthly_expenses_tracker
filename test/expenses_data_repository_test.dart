import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:monthly_expenses_tracker/expenses_data/expenses_data.dart';
import 'package:monthly_expenses_tracker/expenses_data/expenses_data_repository.dart';

void main() {
  late Directory tempDir;
  late ExpensesDataRepository repository;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('monthly_expenses_tracker');
    repository = await ExpensesDataRepository.init(directory: tempDir);
  });

  tearDown(() async {
    await repository.close();
    await tempDir.delete(recursive: true);
  });

  test('create valid expenses data key', () {
    final key1 = ExpensesDataKey(month: 1, year: 2025);
    final key2 = ExpensesDataKey(month: 12, year: 2025);

    expect(key1.toString(), '2025:01');
    expect(key2.toString(), '2025:12');
  });

  test('create invalid expenses data key', () {
    expect(
      () => ExpensesDataKey(month: 0, year: 2025),
      throwsA(isAssertionError),
    );

    expect(
      () => ExpensesDataKey(month: 13, year: 2025),
      throwsA(isAssertionError),
    );

    expect(
      () => ExpensesDataKey(month: 1, year: 1968),
      throwsA(isAssertionError),
    );
  });

  test('invalid lookup', () async {
    final key = ExpensesDataKey(month: 4, year: 2020);
    final data = await repository.lookup(key);

    expect(data, null);
  });

  test('insert/lookup data', () async {
    final originalData = ExpensesData(
      housing: 1500,
      food: 600,
      transportation: 320,
      entertainment: 30,
      fitness: 0,
      education: 0,
    );

    final key = ExpensesDataKey(month: 5, year: 2020);
    await repository.update(key: key, data: originalData);
    final data = await repository.lookup(key);

    expect(data, originalData);
  });

  test('update/lookup data', () async {
    final originalData = ExpensesData(
      housing: 2000,
      food: 400,
      transportation: 400,
      entertainment: 30,
      fitness: 20,
      education: 0,
    );

    final updatedData = ExpensesData(
      housing: 1800,
      food: 450,
      transportation: 400,
      entertainment: 40,
      fitness: 20,
      education: 0,
    );

    final key = ExpensesDataKey(month: 6, year: 2020);
    await repository.update(key: key, data: originalData);
    await repository.update(key: key, data: updatedData);
    final data = await repository.lookup(key);

    expect(data, updatedData);
  });

  test('invalid insert of data', () async {
    final data = ExpensesData(
      housing: -1,
      food: 450,
      transportation: 400,
      entertainment: 40,
      fitness: 20,
      education: 0,
    );

    final key = ExpensesDataKey(month: 7, year: 2020);
    expect(
      () async => await repository.update(key: key, data: data),
      throwsA(isAssertionError),
    );
  });

  test('lookup years without data', () async {
    final result = await repository.lookupYears();

    expect(result.length, 0);
  });

  test('lookup by year', () async {
    final data1 = ExpensesData(
      housing: 2000,
      food: 450,
      transportation: 400,
      entertainment: 40,
      fitness: 20,
      education: 0,
    );

    final data2 = ExpensesData(
      housing: 3000,
      food: 450,
      transportation: 400,
      entertainment: 40,
      fitness: 20,
      education: 0,
    );

    final data3 = ExpensesData(
      housing: 1000,
      food: 550,
      transportation: 400,
      entertainment: 40,
      fitness: 20,
      education: 0,
    );

    final key1 = ExpensesDataKey(month: 1, year: 2018);
    final key2 = ExpensesDataKey(month: 2, year: 2018);
    final key3 = ExpensesDataKey(month: 5, year: 2019);

    await repository.update(key: key1, data: data1);
    await repository.update(key: key2, data: data2);
    await repository.update(key: key3, data: data3);

    final years = await repository.lookupYears();

    expect(years.length, 2);
    expect(years.first.year, 2018);
    expect(years.last.year, 2019);

    final result1 = await repository.lookupByYear(years.first);
    expect(result1.length, 2);
    expect(result1.containsKey(key1), true);
    expect(result1.containsKey(key2), true);
    expect(result1.containsKey(key3), false);
    expect(result1[key1], data1);
    expect(result1[key2], data2);

    final result2 = await repository.lookupByYear(years.last);
    expect(result2.length, 1);
    expect(result2.containsKey(key1), false);
    expect(result2.containsKey(key2), false);
    expect(result2.containsKey(key3), true);
    expect(result2[key3], data3);
  });

  test('lookup all', () async {
    final data1 = ExpensesData(
      housing: 2000,
      food: 450,
      transportation: 400,
      entertainment: 40,
      fitness: 20,
      education: 0,
    );

    final data2 = ExpensesData(
      housing: 3000,
      food: 450,
      transportation: 400,
      entertainment: 40,
      fitness: 20,
      education: 0,
    );

    final data3 = ExpensesData(
      housing: 1000,
      food: 550,
      transportation: 400,
      entertainment: 40,
      fitness: 20,
      education: 0,
    );

    final key1 = ExpensesDataKey(month: 1, year: 2018);
    final key2 = ExpensesDataKey(month: 2, year: 2018);
    final key3 = ExpensesDataKey(month: 5, year: 2019);

    await repository.update(key: key1, data: data1);
    await repository.update(key: key2, data: data2);
    await repository.update(key: key3, data: data3);

    final data = await repository.lookupAll();

    expect(data.length, 3);
    expect(data[key1], data1);
    expect(data[key2], data2);
    expect(data[key3], data3);
  });

  test('aggregate by year', () async {
    final data1 = ExpensesData(
      housing: 2000,
      food: 450,
      transportation: 400,
      entertainment: 40,
      fitness: 20,
      education: 0,
    );

    final data2 = ExpensesData(
      housing: 3000,
      food: 450,
      transportation: 400,
      entertainment: 40,
      fitness: 20,
      education: 0,
    );

    final data3 = ExpensesData(
      housing: 1000,
      food: 550,
      transportation: 400,
      entertainment: 40,
      fitness: 20,
      education: 0,
    );

    final key1 = ExpensesDataKey(month: 1, year: 2018);
    final key2 = ExpensesDataKey(month: 2, year: 2018);
    final key3 = ExpensesDataKey(month: 5, year: 2019);

    await repository.update(key: key1, data: data1);
    await repository.update(key: key2, data: data2);
    await repository.update(key: key3, data: data3);

    final data = await repository.aggregateByYear();
    final year2018 = data[key1.toYearKey()];
    final year2019 = data[key3.toYearKey()];

    expect(data.length, 2);
    expect(year2018?.housing, 5000);
    expect(year2018?.food, 900);
    expect(year2018?.transportation, 800);
    expect(year2018?.entertainment, 80);
    expect(year2018?.fitness, 40);
    expect(year2018?.education, 0);
    expect(year2019!, data3);
  });
}
