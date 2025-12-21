import 'dart:math';

import 'package:flutter/material.dart';

/// Provides information about the expense categories.
class ExpenseCategories {
  final ColorScheme _colorScheme;

  ExpenseCategories({required ColorScheme colorScheme})
    : _colorScheme = colorScheme;

  ExpenseCategory get housing =>
      ExpenseCategory._('Housing', _tone(1), _altTone(1));

  ExpenseCategory get food => ExpenseCategory._('Food', _tone(2), _altTone(2));

  ExpenseCategory get transportation =>
      ExpenseCategory._('Transportation', _tone(3), _altTone(3));

  ExpenseCategory get fitness =>
      ExpenseCategory._('Fitness', _tone(4), _altTone(4));

  ExpenseCategory get education =>
      ExpenseCategory._('Education', _tone(5), _altTone(5));

  ExpenseCategory get entertainment =>
      ExpenseCategory._('Entertainment', _tone(6), _altTone(6));

  Color _tone(int index) => HSLColor.fromColor(
    _colorScheme.secondary,
  ).withLightness(index / 7.0).toColor();

  Color _altTone(int index) {
    final s = _tone(index);
    return ((s.r + s.g + s.b) / 3.0) < 0.5 ? Colors.white : Colors.black;
  }
}

/// Represents an expense category.
class ExpenseCategory {
  /// The name of the category.
  final String label;

  /// The [Color] to represent the category.
  final Color color;

  /// A background [Color] which should provide good contrast with [color].
  final Color backgroundColor;

  ExpenseCategory._(this.label, this.color, this.backgroundColor);
}
