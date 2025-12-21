import 'package:flutter/foundation.dart';
import 'package:monthly_expenses_tracker/expenses_data/expenses_data.dart';
import 'package:monthly_expenses_tracker/expenses_data/expenses_data_repository.dart';

sealed class ExpensesByMonthServiceState {
  const ExpensesByMonthServiceState();
}

class ExpensesByMonthServiceLoadingState extends ExpensesByMonthServiceState {}

class ExpensesByMonthServiceNotReadyState extends ExpensesByMonthServiceState {}

class ExpensesByMonthServiceReadyState extends ExpensesByMonthServiceState {}

class ExpensesByMonthServiceErrorState extends ExpensesByMonthServiceState {
  final String _message;

  const ExpensesByMonthServiceErrorState(String message) : _message = message;

  String get message => _message;
}

/// Provices the total expenses aggregated by year.
class ExpensesByMonthService with ChangeNotifier {
  final ExpensesDataRepository _repository;
  Map<ExpensesDataKey, ExpensesData> _data = {};
  final List<ExpensesDataYearKey> _years;
  ExpensesByMonthServiceState _state;

  /// Private constructor.
  ExpensesByMonthService._(
    ExpensesDataRepository repository,
    List<ExpensesDataYearKey> years,
    ExpensesByMonthServiceState state,
  ) : _repository = repository,
      _years = years,
      _state = state;

  /// This acts as the constructor.
  /// The service is created and then the data is loaded to set the initial state.
  /// This way, the retured service is fully initialized.
  static Future<ExpensesByMonthService> init(
    ExpensesDataRepository repository,
  ) async {
    ExpensesByMonthServiceState state = ExpensesByMonthServiceNotReadyState();
    List<ExpensesDataYearKey> years = [];

    if (repository.hasData) {
      years = await repository.lookupYears();
      state = ExpensesByMonthServiceReadyState();
      years.sort((a, b) => b.compareTo(a));
    }

    return Future.value(ExpensesByMonthService._(repository, years, state));
  }

  /// Returns a copy of the cached data returned by [lookup()].
  /// Beware that the data is unsorted.
  Map<ExpensesDataKey, ExpensesData> get data =>
      Map<ExpensesDataKey, ExpensesData>.of(_data);

  /// Returns the current [ExpensesByMonthServiceState] of the service.
  ExpensesByMonthServiceState get state => _state;

  /// Returns the list of available years, sorted in descending order.
  List<ExpensesDataYearKey> get years => _years;

  /// Retrieves the aggregated data from the [ExpensesDataRepository].
  /// The result is retained internally and can be accessed via the [data] getter.
  /// This is so that the lookup can be triggered and then the Flutter UI can
  /// respond to the notification emitted by the [ChangeNotifier].
  Future<void> lookup(
    ExpensesDataYearKey key, {
    Duration minimumDelay = Duration.zero,
  }) async {
    final startTimestamp = DateTime.timestamp();
    _state = ExpensesByMonthServiceLoadingState();
    notifyListeners();

    try {
      _data = await _repository.lookupByYear(key);
      _state = ExpensesByMonthServiceReadyState();
    } catch (e) {
      _state = ExpensesByMonthServiceErrorState(e.toString());
    } finally {
      final elapsedTime = DateTime.timestamp().difference(startTimestamp);
      final delay = minimumDelay - elapsedTime;

      if (!delay.isNegative) {
        await Future.delayed(delay);
      }

      notifyListeners();
    }

    return Future.value(null);
  }
}
