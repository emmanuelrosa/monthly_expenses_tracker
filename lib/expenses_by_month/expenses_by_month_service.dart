import 'package:flutter/foundation.dart';
import 'package:monthly_expenses_tracker/expenses_data/expenses_data.dart';
import 'package:monthly_expenses_tracker/expenses_data/expenses_data_repository.dart';

sealed class ExpensesByMonthServiceState {
  const ExpensesByMonthServiceState();
}

class ExpensesByMonthServiceLoadingState extends ExpensesByMonthServiceState {}

class ExpensesByMonthServiceFinishedState extends ExpensesByMonthServiceState {}

class ExpensesByMonthServiceErrorState extends ExpensesByMonthServiceState {
  final String _message;

  const ExpensesByMonthServiceErrorState(String message) : _message = message;

  String get message => _message;
}

/// Provices the total expenses aggregated by year.
class ExpensesByMonthService {
  final ExpensesDataRepository _repository;
  Map<ExpensesDataKey, ExpensesData> _data = {};
  final ValueNotifier<ExpensesByMonthServiceState> _state = ValueNotifier(
    ExpensesByMonthServiceLoadingState(),
  );

  ExpensesByMonthService(ExpensesDataRepository repository)
    : _repository = repository;

  /// Returns a copy of the cached data returned by [lookup()].
  /// Beware that the data is unsorted.
  Map<ExpensesDataKey, ExpensesData> get data =>
      Map<ExpensesDataKey, ExpensesData>.of(_data);

  /// Returns a [ValueNotifier] of the current [ExpensesByMonthServiceState] of the service.
  /// Listen to the notifier to get notified of state changes.
  ValueNotifier<ExpensesByMonthServiceState> get state => _state;

  /// Retrieves the aggregated data from the [ExpensesDataRepository].
  /// The result is retained internally and can be accessed via the [data] getter.
  /// This is so that the lookup can be triggered and then the Flutter UI can
  /// respond to the notification emitted by the [state] [ValueNotifier].
  Future<void> lookup(ExpensesDataYearKey key) async {
    _state.value = ExpensesByMonthServiceLoadingState();

    try {
      _data = await _repository.lookupByYear(key);
      _state.value = ExpensesByMonthServiceFinishedState();
    } catch (e) {
      _state.value = ExpensesByMonthServiceErrorState(e.toString());
    }

    return Future.value(null);
  }
}
