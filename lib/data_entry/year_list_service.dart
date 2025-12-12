import 'dart:async';

import 'package:flutter/foundation.dart';

/// This service returns a list of years from which data entry can be performed.
/// Namely, 1969 to the present.
/// Optionally, a timer is used to periodically update the years list
/// when the system clock rolls over to a new year.
/// Don't forget to call [dispose()] to release internal resources.
class YearListService {
  StreamSubscription<int>? _subscription;
  late ValueNotifier<List<int>> _yearNotifier;

  /// Initializes the service.
  /// [today] sets the current date. Meant to be used for testing.
  /// [pollingInterval] is how frequently to check if the current year has changed.
  /// Set to a [Duration] greater than zero to activate.
  /// [currentYearFunc] is a callback which should return the current year when called.
  /// Meant to be used for testing.
  YearListService(
    DateTime? today, {
    Duration pollingInterval = Duration.zero,
    int Function()? currentYearFunc,
  }) {
    final func = currentYearFunc ?? () => DateTime.now().year;
    final currentYear = (today ?? DateTime.now()).year;
    _yearNotifier = ValueNotifier<List<int>>(_computeYears(currentYear));

    if (pollingInterval != Duration.zero) {
      final stream = Stream<int>.periodic(pollingInterval, (_) => func());

      _subscription = stream.listen((year) {
        _yearNotifier.value = _computeYears(year);
      });
    }
  }

  /// Releases internal resources.
  Future<void> dispose() async {
    _yearNotifier.dispose();
    return _subscription?.cancel();
  }

  /// Returns a list of years; From 1969 to the present.
  List<int> _computeYears(int currentYear) => List.generate(
    currentYear - startYear + 1,
    (index) => startYear + index,
  ).reversed.toList();

  int get startYear => 1969;

  ValueNotifier<List<int>> get yearNotifier => _yearNotifier;
}
