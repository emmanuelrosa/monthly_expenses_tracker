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

typedef Month = ({int number, String name});

/// A facade that provides the business logic of entering expenses into the application.
/// Uses an [ExpensesDataRepository] to store data.
/// Maintains internal state to make it easy to use with the Flutter widget tree.
/// Implements [ChangeNotifier] to emit information about state changes.
class DataEntryService with ChangeNotifier {
  final ExpensesDataRepository _repository;

  // Internal state
  int _month = 1;
  int _year = 1969;
  ExpensesData? _data;
  DataEntryServiceState _state = DataEntryServiceLoadingState();

  /// Private constructor.
  DataEntryService._(
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
  }

  /// Initializes the [DataEntryService].
  /// By default, the month is set to the prior month.
  static Future<DataEntryService> init(
    ExpensesDataRepository repository, {
    DateTime? today,
    bool initWithPriorMonth = true,
  }) async {
    final service = DataEntryService._(
      repository,
      today: today,
      initWithPriorMonth: initWithPriorMonth,
    );
    await service._load();

    return Future.value(service);
  }

  /// Return a static list of [Month]s.
  List<Month> get months => <Month>[
    (number: DateTime.january, name: 'January'),
    (number: DateTime.february, name: 'February'),
    (number: DateTime.march, name: 'March'),
    (number: DateTime.april, name: 'April'),
    (number: DateTime.may, name: 'May'),
    (number: DateTime.june, name: 'June'),
    (number: DateTime.july, name: 'July'),
    (number: DateTime.august, name: 'August'),
    (number: DateTime.september, name: 'September'),
    (number: DateTime.october, name: 'October'),
    (number: DateTime.november, name: 'November'),
    (number: DateTime.december, name: 'December'),
  ];

  int get month => _month;
  int get year => _year;
  ExpensesData? get data => _data?.copyWith();
  DataEntryServiceState get state => _state;

  /// Updates the internal state using the expenses data for the month/year reflected in the state.
  Future<void> _load() async {
    _state = DataEntryServiceLoadingState();
    notifyListeners();

    try {
      final key = ExpensesDataKey(month: _month, year: _year);
      _data = await _repository.lookup(key);
      _state = DataEntryServiceFinishedState();
    } catch (e) {
      _state = DataEntryServiceErrorState(e.toString());
    } finally {
      notifyListeners();
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
  Future<void> update({
    required double housing,
    required double food,
    required double transportation,
    required double entertainment,
    required double fitness,
    required double education,
  }) async {
    final key = ExpensesDataKey(month: _month, year: _year);

    try {
      // The constructor throws if any of the values are negative.
      final data = ExpensesData(
        housing: housing,
        food: food,
        transportation: transportation,
        fitness: fitness,
        entertainment: entertainment,
        education: education,
      );
      await _repository.update(key: key, data: data);
      _data = data;
    } catch (e) {
      _state = DataEntryServiceErrorState(e.toString());
    } finally {
      notifyListeners();
    }
  }
}
