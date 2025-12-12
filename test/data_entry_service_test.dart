import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:monthly_expenses_tracker/data_entry/data_entry_service.dart';
import 'package:monthly_expenses_tracker/expenses_data/expenses_data_repository.dart';

void main() {
  late Directory tempDir;
  late ExpensesDataRepository repository;
  late DataEntryService service;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('monthly_expenses_tracker');
    repository = await ExpensesDataRepository.init(directory: tempDir);
    final today = DateTime.parse('2020-01-30 02:20:54');
    service = DataEntryService(repository, today: today);
  });

  tearDown(() async {
    await repository.close();
    await tempDir.delete(recursive: true);
  });

  test('initial state', () {
    expect(service.month, 12);
    expect(service.year, 2019);
    expect(service.data, null);
  });

  test('load', () async {
    await service.setDate(month: 6, year: 2020);
    expect(service.month, 6);
    expect(service.year, 2020);
    expect(service.data, null);
    expect(service.state.value, isA<DataEntryServiceFinishedState>());
  });

  test('invalid load', () {
    expect(
      () async => await service.setDate(month: 0, year: 2020),
      throwsA(isAssertionError),
    );

    expect(
      () async => await service.setDate(month: 13, year: 2020),
      throwsA(isAssertionError),
    );

    expect(
      () async => await service.setDate(month: 12, year: 1968),
      throwsA(isAssertionError),
    );
  });

  test('update', () async {
    await service.setDate(month: 5, year: 2019);
    await service.update(
      housing: 1000,
      food: 500,
      transportation: 300,
      entertainment: 200,
      fitness: 60,
      education: 0,
    );

    expect(service.month, 5);
    expect(service.year, 2019);
    expect(service.data?.housing, 1000);
    expect(service.data?.food, 500);
    expect(service.data?.transportation, 300);
    expect(service.data?.entertainment, 200);
    expect(service.data?.fitness, 60);
    expect(service.data?.education, 0);
    expect(service.state.value, isA<DataEntryServiceFinishedState>());

    await service.update(
      housing: 0,
      food: 0,
      transportation: 0,
      entertainment: 0,
      fitness: 60,
      education: -100,
    );

    expect(service.month, 5);
    expect(service.year, 2019);
    expect(service.data?.housing, 1000);
    expect(service.data?.food, 500);
    expect(service.data?.transportation, 300);
    expect(service.data?.entertainment, 200);
    expect(service.data?.fitness, 120);
    expect(service.data?.education, 0);
    expect(service.state.value, isA<DataEntryServiceFinishedState>());
  });
}
