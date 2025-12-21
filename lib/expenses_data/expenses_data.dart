import 'dart:convert' as convert;
import 'dart:math' as math;

import 'package:freezed_annotation/freezed_annotation.dart';

part 'expenses_data.freezed.dart';
part 'expenses_data.g.dart';

/// A DTO for the monthly expenses data.
/// Note that this class doesn't contain the month and year.
/// That's because those fields are the key used to look up the expenses data.
@freezed
@JsonSerializable()
class ExpensesData with _$ExpensesData {
  @override
  final double housing;
  @override
  final double food;
  @override
  final double transportation;
  @override
  final double entertainment;
  @override
  final double fitness;
  @override
  final double education;

  const ExpensesData({
    required this.housing,
    required this.food,
    required this.transportation,
    required this.entertainment,
    required this.fitness,
    required this.education,
  });

  factory ExpensesData.fromJson(Map<String, Object?> json) =>
      _$ExpensesDataFromJson(json);

  factory ExpensesData.fromJsonString(String jsonString) =>
      ExpensesData.fromJson(convert.jsonDecode(jsonString));

  Map<String, Object?> toJson() => _$ExpensesDataToJson(this);

  String toJsonString() => convert.jsonEncode(toJson());

  ExpensesData operator +(ExpensesData other) => copyWith(
    housing: math.max(0, housing + other.housing),
    food: math.max(0, food + other.food),
    transportation: math.max(0, transportation + other.transportation),
    entertainment: math.max(0, entertainment + other.entertainment),
    fitness: math.max(0, fitness + other.fitness),
    education: math.max(0, education + other.education),
  );

  double get total =>
      housing + food + transportation + entertainment + fitness + education;
}
