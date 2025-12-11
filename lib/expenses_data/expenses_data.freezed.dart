// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'expenses_data.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ExpensesData {

 double get housing; double get food; double get transportation; double get entertainment; double get fitness; double get education;
/// Create a copy of ExpensesData
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ExpensesDataCopyWith<ExpensesData> get copyWith => _$ExpensesDataCopyWithImpl<ExpensesData>(this as ExpensesData, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ExpensesData&&(identical(other.housing, housing) || other.housing == housing)&&(identical(other.food, food) || other.food == food)&&(identical(other.transportation, transportation) || other.transportation == transportation)&&(identical(other.entertainment, entertainment) || other.entertainment == entertainment)&&(identical(other.fitness, fitness) || other.fitness == fitness)&&(identical(other.education, education) || other.education == education));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,housing,food,transportation,entertainment,fitness,education);

@override
String toString() {
  return 'ExpensesData(housing: $housing, food: $food, transportation: $transportation, entertainment: $entertainment, fitness: $fitness, education: $education)';
}


}

/// @nodoc
abstract mixin class $ExpensesDataCopyWith<$Res>  {
  factory $ExpensesDataCopyWith(ExpensesData value, $Res Function(ExpensesData) _then) = _$ExpensesDataCopyWithImpl;
@useResult
$Res call({
 double housing, double food, double transportation, double entertainment, double fitness, double education
});




}
/// @nodoc
class _$ExpensesDataCopyWithImpl<$Res>
    implements $ExpensesDataCopyWith<$Res> {
  _$ExpensesDataCopyWithImpl(this._self, this._then);

  final ExpensesData _self;
  final $Res Function(ExpensesData) _then;

/// Create a copy of ExpensesData
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? housing = null,Object? food = null,Object? transportation = null,Object? entertainment = null,Object? fitness = null,Object? education = null,}) {
  return _then(ExpensesData(
housing: null == housing ? _self.housing : housing // ignore: cast_nullable_to_non_nullable
as double,food: null == food ? _self.food : food // ignore: cast_nullable_to_non_nullable
as double,transportation: null == transportation ? _self.transportation : transportation // ignore: cast_nullable_to_non_nullable
as double,entertainment: null == entertainment ? _self.entertainment : entertainment // ignore: cast_nullable_to_non_nullable
as double,fitness: null == fitness ? _self.fitness : fitness // ignore: cast_nullable_to_non_nullable
as double,education: null == education ? _self.education : education // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [ExpensesData].
extension ExpensesDataPatterns on ExpensesData {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({required TResult orElse(),}){
final _that = this;
switch (_that) {
case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(){
final _that = this;
switch (_that) {
case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(){
final _that = this;
switch (_that) {
case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({required TResult orElse(),}) {final _that = this;
switch (_that) {
case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>() {final _that = this;
switch (_that) {
case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>() {final _that = this;
switch (_that) {
case _:
  return null;

}
}

}

// dart format on
