// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'expenses_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ExpensesData _$ExpensesDataFromJson(Map<String, dynamic> json) => ExpensesData(
  housing: (json['housing'] as num).toDouble(),
  food: (json['food'] as num).toDouble(),
  transportation: (json['transportation'] as num).toDouble(),
  entertainment: (json['entertainment'] as num).toDouble(),
  fitness: (json['fitness'] as num).toDouble(),
  education: (json['education'] as num).toDouble(),
);

Map<String, dynamic> _$ExpensesDataToJson(ExpensesData instance) =>
    <String, dynamic>{
      'housing': instance.housing,
      'food': instance.food,
      'transportation': instance.transportation,
      'entertainment': instance.entertainment,
      'fitness': instance.fitness,
      'education': instance.education,
    };
