import 'package:flutter_test/flutter_test.dart';
import 'package:monthly_expenses_tracker/data_entry/year_list_service.dart';

void main() {
  late YearListService service;

  setUp(() {
    final today = DateTime.parse('2020-12-31 23:59:57');
    service = YearListService(
      today,
      pollingInterval: Duration(seconds: 3),
      currentYearFunc: () => DateTime.parse('2021-01-01 01:00:00').year,
    );
  });

  tearDown(() {
    service.dispose();
  });

  test('years', () {
    final years = service.yearNotifier.value;

    expect(years.length, 52);
    expect(years.first, 2020);
    expect(years.last, 1969);
  });

  /// Beware: This test is time-sensitive.
  /// It sets up a callback which is called by [service.yearNotifier]
  /// as a way to check the service's year polling.
  /// And then it uses a delayed [Future] to wait for the callback.
  /// This is not ideal.
  test('years update', () async {
    final notifier = service.yearNotifier;
    final callback = expectAsync0<void>(() => {});

    notifier.addListener(callback);
    await Future<void>.delayed(Duration(seconds: 3));

    expect(notifier.value.length, 53);
    expect(notifier.value.first, 2021);
    expect(notifier.value.last, 1969);
  });
}
