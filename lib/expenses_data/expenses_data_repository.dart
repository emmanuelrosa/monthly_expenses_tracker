import 'dart:io';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive_ce/hive.dart';
import 'package:monthly_expenses_tracker/expenses_data/expenses_data.dart';

part 'expenses_data_repository.freezed.dart';

/// A key that's used to store [ExpensesData] in a repository.
@freezed
class ExpensesDataKey with _$ExpensesDataKey implements Comparable {
  @override
  final int month;

  @override
  final int year;

  ExpensesDataKey({required this.month, required this.year}) {
    assert(
      month >= 1 && month <= 12,
      'The month argument must be between 1 and 12, inclusive',
    );
    assert(year >= 1969, 'The year argument must be >= 1969');
  }

  @override
  String toString() => '$year:${month.toString().padLeft(2, '0')}';

  static ExpensesDataKey fromString(String key) {
    final splitKey = key.split(':');
    final year = int.parse(splitKey[0]);
    final month = int.parse(splitKey[1]);

    return ExpensesDataKey(month: month, year: year);
  }

  @override
  int compareTo(other) => toString().compareTo(other.toString());

  /// Returns an [ExpensesDataYearKey] that corresponds to this key.
  ExpensesDataYearKey toYearKey() => ExpensesDataYearKey._(year);
}

/// Represents a valid year which is used to lookup expenses by year.
/// A valid year is one that's already in use within the repository.
@freezed
class ExpensesDataYearKey with _$ExpensesDataYearKey implements Comparable {
  @override
  final int year;

  ExpensesDataYearKey._(this.year);

  @override
  int compareTo(other) => year.compareTo(other.year);
}

/// A facade for persistent storage of [ExpensesData] using ReaxDB.
class ExpensesDataRepository {
  final LazyBox<String> _box;

  ExpensesDataRepository._(LazyBox<String> box) : _box = box;

  /// Initializes an [ExpensesDataRepository].
  static Future<ExpensesDataRepository> init({Directory? directory}) async {
    final box = directory != null
        ? await Hive.openLazyBox<String>('expenses', path: directory.path)
        : await Hive.openLazyBox<String>('expenses');

    return Future.value(ExpensesDataRepository._(box));
  }

  /// Closes the internal [Hive] boxes.
  /// Do not use an [ExpensesDataRepository] instance after calling this method!
  Future<void> close() => _box.close();

  /// Returns all of the expenses keys.
  Iterable<ExpensesDataKey> _getExpensesKeys() =>
      _box.keys.map((dynamic key) => ExpensesDataKey.fromString(key));

  /// Return the keys which correspond to the given year.
  Iterable<ExpensesDataKey> _getKeysByYear(ExpensesDataYearKey yearKey) =>
      _getExpensesKeys().where((key) => key.year == yearKey.year);

  /// Converts a [List<String?>] of nullable JSON strings into [List<String>].
  /// Filteres out the nulls.
  Iterable<String> _toJsonStringList(List<String?> nullableJsonString) =>
      nullableJsonString
          .where((jsonString) => jsonString != null)
          .map((jsonString) => jsonString.toString());

  /// Returns the year(s) for which there is [ExpensesData] in the repository.
  /// The years are wrapped in an [ExpensesDataYearKey] to provided a validated year
  /// which can be used to look up [ExpensesData] by year.
  Future<List<ExpensesDataYearKey>> lookupYears() {
    final keys = _getExpensesKeys();
    final yearsList = keys.map((key) => key.year);
    final yearsSet = <int>{};
    yearsSet.addAll(yearsList);
    final sortedYearsList = yearsSet.map(ExpensesDataYearKey._).toList();
    sortedYearsList.sort();
    return Future.value(sortedYearsList);
  }

  /// Retrieve all of the [ExpensesData] from storage.
  Future<Map<ExpensesDataKey, ExpensesData>> lookupAll() async {
    final result = <ExpensesDataKey, ExpensesData>{};
    final keys = _getExpensesKeys();

    for (var key in keys) {
      final jsonString = await _box.get(key.toString());

      if (jsonString != null) {
        result[key] = ExpensesData.fromJsonString(jsonString);
      }
    }

    return Future.value(result);
  }

  /// Retrieve an [ExpensesData] from storage, by an [ExpensesDataKey].
  /// Returns null if the requested data is not found.
  Future<ExpensesData?> lookup(ExpensesDataKey key) async {
    final data = await _box.get(key.toString());

    if (data == null) {
      return Future.value();
    }

    return ExpensesData.fromJsonString(data);
  }

  /// Retrieve [ExpensesData] records from storage, by year.
  /// The input is an [ExpensesDataYearKey], which is a validated year.
  /// This avoids having to validate the year in this method.
  Future<List<ExpensesData>> lookupByYear(ExpensesDataYearKey yearKey) async {
    final keys = _getKeysByYear(yearKey);
    final data = (await Future.wait(
      keys.map((key) async => await _box.get(key.toString())),
    ));

    final filteredData = _toJsonStringList(data);

    return Future.value(
      filteredData.map((value) => ExpensesData.fromJsonString(value)).toList(),
    );
  }

  /// Add/update/delete an [ExpensesData] into/from storage, by its [ExpensesDataKey].
  /// Adds/updates when at least one of the expense values are non-zero.
  /// Deletes an existing record when all expense values are zero.
  /// This is to avoid having two null states: when the record doesn't exist
  /// and when the record exists but contains all zeros.
  /// Throws [AssertionError] when any expense is negative.
  Future<void> update({
    required ExpensesDataKey key,
    required ExpensesData data,
  }) async {
    assert(data.housing >= 0, 'Housing must be >= 0.');
    assert(data.food >= 0, 'Food must be >= 0.');
    assert(data.transportation >= 0, 'Transportation must be >= 0.');
    assert(data.entertainment >= 0, 'Entertainment must be >= 0.');
    assert(data.fitness >= 0, 'Fitness must be >= 0.');
    assert(data.education >= 0, 'Education must be >= 0.');

    if (data.housing == 0 &&
        data.food == 0 &&
        data.transportation == 0 &&
        data.entertainment == 0 &&
        data.fitness == 0 &&
        data.education == 0) {
      await _box.delete(key.toString());
    } else {
      await _box.put(key.toString(), data.toJsonString());
    }
    return Future.value();
  }

  /// Provides aggregated (summed) [ExpensesData], by year for the given year.
  Future<Map<ExpensesDataYearKey, ExpensesData>> aggregateByYear() async {
    final result = <ExpensesDataYearKey, ExpensesData>{};
    final allExpenses = await lookupAll();

    for (var entry in allExpenses.entries) {
      final yearKey = entry.key.toYearKey();
      final expenses = result[yearKey];

      if (expenses == null) {
        // The start of a new aggregate.
        result[yearKey] = entry.value;
      } else {
        // Add unto an existing aggretate.
        result[yearKey] = expenses + entry.value;
      }
    }

    return Future.value(result);
  }
}
