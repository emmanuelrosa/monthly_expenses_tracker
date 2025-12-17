import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:monthly_expenses_tracker/expenses_data/expenses_data_repository.dart';
import 'package:monthly_expenses_tracker/expenses_import/expenses_import_service.dart';

void main() {
  late Directory tempDir;
  late ExpensesDataRepository repository;
  late ExpensesImportService service;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('monthly_expenses_tracker');
    repository = await ExpensesDataRepository.init(directory: tempDir);
    service = ExpensesImportService(repository);
  });

  tearDown(() async {
    await repository.close();
    await tempDir.delete(recursive: true);
  });

  test('initial state', () {
    expect(service.state, isA<ExpensesImportServiceReadyState>());
  });

  test('succesful import', () async {
    final csv = '''
      "year","month","housing","food","transporation","entertainment","fitness","education"
      2018,1,1000,300,300,120,60,15
      "2018",2,1000,300,300,120,60,20''';
    final bytes = utf8.encode(csv);

    expect(service.state, isA<ExpensesImportServiceReadyState>());
    await service.importFromCsv(bytes);
    final data1 = await repository.lookup(
      ExpensesDataKey(month: 1, year: 2018),
    );
    final data2 = await repository.lookup(
      ExpensesDataKey(month: 2, year: 2018),
    );
    expect(service.state, isA<ExpensesImportServiceReadyState>());
    expect(data1?.housing, 1000);
    expect(data2?.education, 20);
    expect(repository.numberOfRecords, 2);
    expect((await repository.lookupYears()).length, 1);
  });

  test('succesful import: no header', () async {
    final csv = '''
      2018,1,1000,300,300,120,60,15
      2018,2,1000,300,300,120,60,20
      2019,1,1000,300,300,120,60,20''';
    final bytes = utf8.encode(csv);

    expect(service.state, isA<ExpensesImportServiceReadyState>());
    await service.importFromCsv(bytes);
    final data1 = await repository.lookup(
      ExpensesDataKey(month: 1, year: 2018),
    );
    final data2 = await repository.lookup(
      ExpensesDataKey(month: 2, year: 2018),
    );
    expect(service.state, isA<ExpensesImportServiceReadyState>());
    expect(data1?.housing, 1000);
    expect(data2?.education, 20);
    expect(repository.numberOfRecords, 3);
    expect((await repository.lookupYears()).length, 2);
  });

  test('unsuccesful import: year format', () async {
    final csv = '''
      "year","month","housing","food","transporation","entertainment","fitness","education"
      2018,1,1000,300,300,120,60,15
      "hello",2,1000,300,300,120,60,20''';
    final bytes = utf8.encode(csv);

    expect(service.state, isA<ExpensesImportServiceReadyState>());
    await service.importFromCsv(bytes);
    expect(service.state, isA<ExpensesImportServiceErrorState>());
    expect(
      service.state.toString(),
      'Unable to parse the year on row 3, column 1. The year must be a whole number >= 1969.',
    );
    expect(repository.numberOfRecords, 0);
  });

  test('unsuccesful import: invalid year', () async {
    final csv = '''
      "year","month","housing","food","transporation","entertainment","fitness","education"
      1500,1,1000,300,300,120,60,15
      2018,2,1000,300,300,120,60,20''';
    final bytes = utf8.encode(csv);

    expect(service.state, isA<ExpensesImportServiceReadyState>());
    await service.importFromCsv(bytes);
    expect(service.state, isA<ExpensesImportServiceErrorState>());
    expect(
      service.state.toString(),
      'Unable to parse the year on row 2, column 1. The year must be a whole number >= 1969.',
    );
    expect(repository.numberOfRecords, 0);
  });

  test('unsuccesful import: month format', () async {
    final csv = '''
      "year","month","housing","food","transporation","entertainment","fitness","education"
      2018,1,1000,300,300,120,60,15
      2018,"hello",1000,300,300,120,60,20''';
    final bytes = utf8.encode(csv);

    expect(service.state, isA<ExpensesImportServiceReadyState>());
    await service.importFromCsv(bytes);
    expect(service.state, isA<ExpensesImportServiceErrorState>());
    expect(
      service.state.toString(),
      'Unable to parse the month on row 3, column 2. The month must be a whole number >= 1 and <= 12.',
    );
    expect(repository.numberOfRecords, 0);
  });

  test('unsuccesful import: month value', () async {
    final csv = '''
      "year","month","housing","food","transporation","entertainment","fitness","education"
      2018,13,1000,300,300,120,60,15
      2018,2,1000,300,300,120,60,20''';
    final bytes = utf8.encode(csv);

    expect(service.state, isA<ExpensesImportServiceReadyState>());
    await service.importFromCsv(bytes);
    expect(service.state, isA<ExpensesImportServiceErrorState>());
    expect(
      service.state.toString(),
      'Unable to parse the month on row 2, column 2. The month must be a whole number >= 1 and <= 12.',
    );
    expect(repository.numberOfRecords, 0);
  });

  test('unsuccesful import: negative expense value', () async {
    final csv = '''
      "year","month","housing","food","transporation","entertainment","fitness","education"
      2018,1,1000,300,300,120,60,-15
      2018,2,1000,300,300,120,60,20''';
    final bytes = utf8.encode(csv);

    expect(service.state, isA<ExpensesImportServiceReadyState>());
    await service.importFromCsv(bytes);
    expect(service.state, isA<ExpensesImportServiceErrorState>());
    expect(
      service.state.toString(),
      'Rejected expense on row 2 column 8 because negative values are not allowed.',
    );
    expect(repository.numberOfRecords, 0);
  });

  test('unsuccesful import: expense format', () async {
    final csv = '''
      "year","month","housing","food","transporation","entertainment","fitness","education"
      2018,1,1000,300,300,120,60,15
      2018,2,1000,300,300,120,"hello",20''';
    final bytes = utf8.encode(csv);

    expect(service.state, isA<ExpensesImportServiceReadyState>());
    await service.importFromCsv(bytes);
    expect(service.state, isA<ExpensesImportServiceErrorState>());
    expect(
      service.state.toString(),
      'Unable to parse the expense on row 3 column 7.',
    );
    expect(repository.numberOfRecords, 0);
  });

  test('unsuccesful import: not enough columns', () async {
    final csv = '''
      "year","month","housing","food","transporation","entertainment","fitness","education"
      2018,1,1000,300,300,120,60
      2018,2,1000,300,300,120,60,20''';
    final bytes = utf8.encode(csv);

    expect(service.state, isA<ExpensesImportServiceReadyState>());
    await service.importFromCsv(bytes);
    expect(service.state, isA<ExpensesImportServiceErrorState>());
    expect(
      service.state.toString(),
      'Row 2 should have 8 columns, but has 7 columns.',
    );
    expect(repository.numberOfRecords, 0);
  });

  test('unsuccesful import: too many columns', () async {
    final csv = '''
      "year","month","housing","food","transporation","entertainment","fitness","education"
      2018,1,1000,300,300,120,60,20
      2018,2,1000,300,300,120,60,20,50''';
    final bytes = utf8.encode(csv);

    expect(service.state, isA<ExpensesImportServiceReadyState>());
    await service.importFromCsv(bytes);
    expect(service.state, isA<ExpensesImportServiceErrorState>());
    expect(
      service.state.toString(),
      'Row 3 should have 8 columns, but has 9 columns.',
    );
    expect(repository.numberOfRecords, 0);
  });
}
