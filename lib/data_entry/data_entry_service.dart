import 'package:monthly_expenses_tracker/expenses_data/expenses_data.dart';
import 'package:monthly_expenses_tracker/expenses_data/expenses_data_repository.dart';

class DataEntryService {
  final ExpensesDataRepository _repository;

  // Internal state
  int _month = 1;
  int _year = 1969;
  ExpensesData? _data;

  DataEntryService(ExpensesDataRepository repository)
    : _repository = repository;

  int get month => _month;
  int get year => _year;
  ExpensesData? get data => _data?.copyWith();

  /// Updates the internal state using the expenses data for the provided month/year.
  /// Throws [AssertionError] when the month or year are invalid.
  Future<void> load({required int month, required int year}) async {
    assert(
      month >= 1 && month <= 12,
      'The month argument must be between 1 and 12, inclusive',
    );
    assert(year >= 1969, 'The year argument must be >= 1969');

    _month = month;
    _year = year;

    final key = ExpensesDataKey(month: month, year: year);
    _data = await _repository.lookup(key);
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
    await _repository.update(key: key, data: data);
    _data = data;
  }
}
