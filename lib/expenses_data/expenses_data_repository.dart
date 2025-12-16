import 'dart:io';

import 'package:flutter/material.dart';
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
class ExpensesDataRepository with ChangeNotifier {
  final LazyBox<Map> _expensesBox;
  final LazyBox<Set> _yearsBox;

  ExpensesDataRepository._(LazyBox<Map> expensesBox, LazyBox<Set> yearsBox)
    : _expensesBox = expensesBox,
      _yearsBox = yearsBox;

  /// Initializes an [ExpensesDataRepository].
  static Future<ExpensesDataRepository> init({Directory? directory}) async {
    final expensesBox = directory != null
        ? await Hive.openLazyBox<Map>('expenses', path: directory.path)
        : await Hive.openLazyBox<Map>('expenses');

    final yearsBox = directory != null
        ? await Hive.openLazyBox<Set>('years', path: directory.path)
        : await Hive.openLazyBox<Set>('years');

    return Future.value(ExpensesDataRepository._(expensesBox, yearsBox));
  }

  /// Closes the internal [Hive] boxes.
  /// Do not use an [ExpensesDataRepository] instance after calling this method!
  Future<void> close() async {
    await _expensesBox.close();
    await _yearsBox.close();
  }

  /// Returns whether the repository contains data or not.
  bool get hasData => _expensesBox.keys.isNotEmpty;

  /// Returns the number of [ExpensesData] records in the repository.
  int get numberOfRecords => _expensesBox.keys.length;

  /// Returns all of the expenses keys.
  Iterable<ExpensesDataKey> _getExpensesKeys() =>
      _expensesBox.keys.map((dynamic key) => ExpensesDataKey.fromString(key));

  /// Return the keys which correspond to the given year.
  Future<Iterable<ExpensesDataKey>> _getKeysByYear(
    ExpensesDataYearKey yearKey,
  ) async {
    final keyStrings = await _yearsBox.get(yearKey.year);

    return keyStrings != null
        ? keyStrings.map((keyString) => ExpensesDataKey.fromString(keyString))
        : <ExpensesDataKey>{};
  }

  /// Returns the year(s) for which there is [ExpensesData] in the repository.
  /// The years are wrapped in an [ExpensesDataYearKey] to provided a validated year
  /// which can be used to look up [ExpensesData] by year.
  Future<List<ExpensesDataYearKey>> lookupYears() {
    final keys = _yearsBox.keys.map((keyInt) => ExpensesDataYearKey._(keyInt));
    final sortedYearsList = keys.toList();
    sortedYearsList.sort();
    return Future.value(sortedYearsList);
  }

  /// Retrieves all of the [ExpensesData] from storage,
  /// and returns them incrementally as a [Stream] of [MapEntry].
  Stream<MapEntry<ExpensesDataKey, ExpensesData>> streamAll() async* {
    final keys = _getExpensesKeys();

    for (var key in keys) {
      final json = (await _expensesBox.get(
        key.toString(),
      ))?.cast<String, Object?>();

      if (json != null) {
        yield MapEntry(key, ExpensesData.fromJson(json));
      }
    }
  }

  /// Retrieves all of the [ExpensesData] from storage.
  Future<Map<ExpensesDataKey, ExpensesData>> lookupAll() async {
    final result = <ExpensesDataKey, ExpensesData>{};

    result.addEntries(await streamAll().toList());

    return Future.value(result);
  }

  /// Retrieve an [ExpensesData] from storage, by an [ExpensesDataKey].
  /// Returns null if the requested data is not found.
  Future<ExpensesData?> lookup(ExpensesDataKey key) async {
    final data = (await _expensesBox.get(
      key.toString(),
    ))?.cast<String, Object?>();

    if (data == null) {
      return Future.value();
    }

    return ExpensesData.fromJson(data);
  }

  /// Retrieve [ExpensesData] records from storage, by year.
  /// The input is an [ExpensesDataYearKey], which is a validated year.
  /// This avoids having to validate the year in this method.
  Future<Map<ExpensesDataKey, ExpensesData>> lookupByYear(
    ExpensesDataYearKey yearKey,
  ) async {
    final keys = await _getKeysByYear(yearKey);
    final data =
        (await Future.wait(
          keys.map(
            (key) async => (
              key: key,
              value: (await _expensesBox.get(
                key.toString(),
              ))?.cast<String, Object?>(),
            ),
          ),
        )).fold(<ExpensesDataKey, ExpensesData>{}, (map, entry) {
          if (entry.value != null) {
            map[entry.key] = ExpensesData.fromJson(entry.value!);
          }

          return map;
        });

    return Future.value(data);
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

    var yearsData = (await _yearsBox.get(key.toYearKey().year))?.cast<String>();

    if (data.housing == 0 &&
        data.food == 0 &&
        data.transportation == 0 &&
        data.entertainment == 0 &&
        data.fitness == 0 &&
        data.education == 0) {
      await _expensesBox.delete(key.toString());

      if (yearsData != null) {
        yearsData.remove(key.toString());
        await _yearsBox.put(key.toYearKey().year, yearsData);
      }
    } else {
      await _expensesBox.put(key.toString(), data.toJson());

      if (yearsData != null) {
        yearsData.add(key.toString());
        await _yearsBox.put(key.toYearKey().year, yearsData);
      } else {
        await _yearsBox.put(key.toYearKey().year, {key.toString()});
      }
    }

    notifyListeners();
    return Future.value();
  }

  /// Add/update/delete all of the [ExpensesData] records into/from storage.
  /// Adds/updates when at least one of the expense values are non-zero.
  /// Deletes an existing record when all expense values are zero.
  /// This is to avoid having two null states: when the record doesn't exist
  /// and when the record exists but contains all zeros.
  /// Throws [AssertionError] and aborts entire update when any expense is negative.
  Future<void> updateAll(Map<ExpensesDataKey, ExpensesData> data) async {
    final expensesToUpdate = <ExpensesDataKey, ExpensesData>{};
    final expensesToDelete = <ExpensesDataKey, ExpensesData>{};
    final yearsUpdates = <int, Set<String>>{};

    for (final entry in data.entries) {
      assert(entry.value.housing >= 0, 'Housing must be >= 0.');
      assert(entry.value.food >= 0, 'Food must be >= 0.');
      assert(entry.value.transportation >= 0, 'Transportation must be >= 0.');
      assert(entry.value.entertainment >= 0, 'Entertainment must be >= 0.');
      assert(entry.value.fitness >= 0, 'Fitness must be >= 0.');
      assert(entry.value.education >= 0, 'Education must be >= 0.');

      if (entry.value.housing == 0 &&
          entry.value.food == 0 &&
          entry.value.transportation == 0 &&
          entry.value.entertainment == 0 &&
          entry.value.fitness == 0 &&
          entry.value.education == 0) {
        expensesToDelete[entry.key] = entry.value;
        var yearsData = (await _yearsBox.get(
          entry.key.toYearKey().year,
          defaultValue: {},
        ))!.cast<String>();
        yearsData.remove(entry.key.toString());
        yearsUpdates[entry.key.toYearKey().year] = yearsData;
      } else {
        expensesToUpdate[entry.key] = entry.value;
        var yearsData = (await _yearsBox.get(
          entry.key.toYearKey().year,
          defaultValue: {},
        ))!.cast<String>();
        yearsData.add(entry.key.toString());
        yearsUpdates[entry.key.toYearKey().year] = yearsData;
      }
    }

    await _expensesBox.putAll(
      expensesToUpdate.map(
        (key, expenses) => MapEntry(key.toString(), expenses.toJson()),
      ),
    );
    await _expensesBox.deleteAll(
      expensesToDelete.keys.map((key) => key.toString()),
    );
    await _yearsBox.putAll(yearsUpdates);

    notifyListeners();
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
