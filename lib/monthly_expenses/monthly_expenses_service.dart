import 'package:monthly_expenses_tracker/expenses_data/expenses_data.dart';
import 'package:monthly_expenses_tracker/expenses_data/expenses_data_repository.dart';

class MonthlyExpensesService {
  final ExpensesDataRepository _repository;

  MonthlyExpensesService(ExpensesDataRepository repository)
    : _repository = repository;

  List<ExpensesData> byYear() {}
}
