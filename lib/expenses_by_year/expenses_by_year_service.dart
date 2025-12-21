import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:monthly_expenses_tracker/expenses_data/expenses_data.dart';
import 'package:monthly_expenses_tracker/expenses_data/expenses_data_repository.dart';

sealed class ExpensesByYearServiceState {
  const ExpensesByYearServiceState();
}

class ExpensesByYearServiceLoadingState extends ExpensesByYearServiceState {}

class ExpensesByYearServiceNotReadyState extends ExpensesByYearServiceState {}

class ExpensesByYearServiceReadyState extends ExpensesByYearServiceState {}

class ExpensesByYearServiceErrorState extends ExpensesByYearServiceState {
  final String _message;

  const ExpensesByYearServiceErrorState(String message) : _message = message;

  String get message => _message;
}

/// Provices the total expenses aggregated by year.
class ExpensesByYearService with ChangeNotifier {
  final ExpensesDataRepository _repository;
  Map<ExpensesDataYearKey, ExpensesData> _data = {};
  ExpensesByYearServiceState _state = ExpensesByYearServiceNotReadyState();

  /// The private constructor.
  ExpensesByYearService._(ExpensesDataRepository repository)
    : _repository = repository;

  /// This acts as the constructor.
  /// The service is created and then the data is loaded to set the initial state.
  /// This way, the retured service is fully initialized.
  static Future<ExpensesByYearService> init(
    ExpensesDataRepository repository,
  ) async {
    final service = ExpensesByYearService._(repository);

    if (repository.hasData) {
      await service.lookup();
    }

    return Future.value(service);
  }

  /// Returns a copy of the cached data returned by [lookup()].
  /// Beware that the data is unsorted.
  Map<ExpensesDataYearKey, ExpensesData> get data =>
      Map<ExpensesDataYearKey, ExpensesData>.of(_data);

  /// Returns the current [ExpensesByYearServiceState] of the service.
  ExpensesByYearServiceState get state => _state;

  /// Retrieves the aggregated data from the [ExpensesDataRepository].
  /// The result is retained internally and can be accessed via the [data] getter.
  /// This is so that the lookup can be triggered and then the Flutter UI can
  /// respond to the notification emitted by this service.
  Future<void> lookup() async {
    if (!_repository.hasData) {
      _state = ExpensesByYearServiceNotReadyState();
      notifyListeners();
      return Future.value(null);
    }

    _state = ExpensesByYearServiceLoadingState();
    notifyListeners();

    try {
      _data = await _repository.aggregateByYear();
      _state = ExpensesByYearServiceReadyState();
    } catch (e) {
      _state = ExpensesByYearServiceErrorState(e.toString());
    } finally {
      notifyListeners();
    }

    return Future.value(null);
  }
}
