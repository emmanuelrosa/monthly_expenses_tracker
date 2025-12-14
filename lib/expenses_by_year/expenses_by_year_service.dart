import 'package:flutter/foundation.dart';
import 'package:monthly_expenses_tracker/expenses_data/expenses_data.dart';
import 'package:monthly_expenses_tracker/expenses_data/expenses_data_repository.dart';

sealed class ExpensesByYearServiceState {
  const ExpensesByYearServiceState();
}

class ExpensesByYearServiceLoadingState extends ExpensesByYearServiceState {}

class ExpensesByYearServiceFinishedState extends ExpensesByYearServiceState {}

class ExpensesByYearServiceErrorState extends ExpensesByYearServiceState {
  final String _message;

  const ExpensesByYearServiceErrorState(String message) : _message = message;

  String get message => _message;
}

/// Provices the total expenses aggregated by year.
class ExpensesByYearService {
  final ExpensesDataRepository _repository;
  Map<ExpensesDataYearKey, ExpensesData>? _data;
  final ValueNotifier<ExpensesByYearServiceState> _state = ValueNotifier(
    ExpensesByYearServiceLoadingState(),
  );

  ExpensesByYearService(ExpensesDataRepository repository)
    : _repository = repository;

  /// Returns a copy of the cached data returned by [lookup()].
  /// Beware that the data is unsorted.
  Map<ExpensesDataYearKey, ExpensesData>? get data =>
      _data != null ? Map<ExpensesDataYearKey, ExpensesData>.of(_data!) : null;

  /// Returns a [ValueNotifier] of the current [ExpensesByYearServiceState] of the service.
  /// Listen to the notifier to get notified of state changes.
  ValueNotifier<ExpensesByYearServiceState> get state => _state;

  /// Retrieves the aggregated data from the [ExpensesDataRepository].
  /// The result is retained internally and can be accessed via the [data] getter.
  /// This is so that the lookup can be triggered and then the Flutter UI can
  /// respond to the notification emitted by the [state] [ValueNotifier].
  Future<void> lookup() async {
    _state.value = ExpensesByYearServiceLoadingState();

    try {
      _data = await _repository.aggregateByYear();
      _state.value = ExpensesByYearServiceFinishedState();
    } catch (e) {
      _state.value = ExpensesByYearServiceErrorState(e.toString());
    }

    return Future.value(null);
  }
}
