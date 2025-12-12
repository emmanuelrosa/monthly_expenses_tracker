import 'package:flutter/foundation.dart';
import 'package:monthly_expenses_tracker/expenses_data/expenses_data.dart';
import 'package:monthly_expenses_tracker/expenses_data/expenses_data_repository.dart';

sealed class DataEntryServiceState {
  const DataEntryServiceState();
}

class DataEntryServiceLoadingState extends DataEntryServiceState {}

class DataEntryServiceFinishedState extends DataEntryServiceState {}

class DataEntryServiceErrorState extends DataEntryServiceState {
  final String _message;

  const DataEntryServiceErrorState(String message) : _message = message;

  String get message => _message;
}

/// A facade that provides the business logic of entering expenses into the application.
/// Uses an [ExpensesDataRepository] to store data.
/// Maintains internal state to make it easy to use with the Flutter widget tree.
/// Uses a [ValueNotifier] to emit information about state changes.
class DataEntryService {
  final ExpensesDataRepository _repository;

  // Internal state
  int _month = 1;
  int _year = 1969;
  ExpensesData? _data;
  ValueNotifier<DataEntryServiceState> _state = ValueNotifier(
    DataEntryServiceLoadingState(),
  );

  /// Initializes the [DataEntryService].
  /// By default, the month is set to the prior month.
  DataEntryService(
    ExpensesDataRepository repository, {
    DateTime? today,
    bool initWithPriorMonth = true,
  }) : _repository = repository {
    final finalToday = today ?? DateTime.now();

    if (initWithPriorMonth) {
      _month = finalToday.month - 1 == 0 ? 12 : finalToday.month - 1;
      _year = finalToday.month - 1 == 0 ? finalToday.year - 1 : finalToday.year;
    } else {
      _month = finalToday.month;
      _year = finalToday.year;
    }

    _load();
  }

  int get month => _month;
  int get year => _year;
  ExpensesData? get data => _data?.copyWith();
  ValueNotifier<DataEntryServiceState> get state => _state;

  /// Updates the internal state using the expenses data for the month/year reflected in the state.
  Future<void> _load() async {
    _state.value = DataEntryServiceLoadingState();

    try {
      final key = ExpensesDataKey(month: _month, year: _year);
      _data = await _repository.lookup(key);
      _state.value = DataEntryServiceFinishedState();
    } catch (e) {
      _state.value = DataEntryServiceErrorState(e.toString());
    }
  }

  /// Updates the internal state using the expenses data for the provided month/year.
  /// Intended to be used for testing.
  /// Throws [AssertionError] when the month or year are invalid.
  Future<void> setDate({required int month, required int year}) async {
    assert(
      month >= 1 && month <= 12,
      'The month argument must be between 1 and 12, inclusive',
    );
    assert(year >= 1969, 'The year argument must be >= 1969');

    _month = month;
    _year = year;
    _data = null;
    return _load();
  }

  /// Adds/updates the monthly expenses record for the month and year specified when [load()] was executed.
  /// The expenses provided are added/deducted from the values loaded when [load()] was executed.
  Future<void> update({
    required double housing,
    required double food,
    required double transportation,
    required double entertainment,
    required double fitness,
    required double education,
  }) async {
    final key = ExpensesDataKey(month: _month, year: _year);
    final tempData = ExpensesData(
      housing: housing,
      food: food,
      transportation: transportation,
      fitness: fitness,
      entertainment: entertainment,
      education: education,
    );

    // The '+' operator in [ExpensesData] enforces as minimum expense value of 0.
    final data = _data == null ? tempData : _data! + tempData;

    try {
      await _repository.update(key: key, data: data);
      _data = data;
    } catch (e) {
      _state.value = DataEntryServiceErrorState(e.toString());
    }
  }
}
