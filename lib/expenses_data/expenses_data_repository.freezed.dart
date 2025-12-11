// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'expenses_data_repository.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ExpensesDataKey {

 int get month; int get year;
/// Create a copy of ExpensesDataKey
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ExpensesDataKeyCopyWith<ExpensesDataKey> get copyWith => _$ExpensesDataKeyCopyWithImpl<ExpensesDataKey>(this as ExpensesDataKey, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ExpensesDataKey&&(identical(other.month, month) || other.month == month)&&(identical(other.year, year) || other.year == year));
}


@override
int get hashCode => Object.hash(runtimeType,month,year);



}

/// @nodoc
abstract mixin class $ExpensesDataKeyCopyWith<$Res>  {
  factory $ExpensesDataKeyCopyWith(ExpensesDataKey value, $Res Function(ExpensesDataKey) _then) = _$ExpensesDataKeyCopyWithImpl;
@useResult
$Res call({
 int month, int year
});




}
/// @nodoc
class _$ExpensesDataKeyCopyWithImpl<$Res>
    implements $ExpensesDataKeyCopyWith<$Res> {
  _$ExpensesDataKeyCopyWithImpl(this._self, this._then);

  final ExpensesDataKey _self;
  final $Res Function(ExpensesDataKey) _then;

/// Create a copy of ExpensesDataKey
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? month = null,Object? year = null,}) {
  return _then(ExpensesDataKey(
month: null == month ? _self.month : month // ignore: cast_nullable_to_non_nullable
as int,year: null == year ? _self.year : year // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [ExpensesDataKey].
extension ExpensesDataKeyPatterns on ExpensesDataKey {
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

/// @nodoc
mixin _$ExpensesDataYearKey {

 int get year;
/// Create a copy of ExpensesDataYearKey
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ExpensesDataYearKeyCopyWith<ExpensesDataYearKey> get copyWith => _$ExpensesDataYearKeyCopyWithImpl<ExpensesDataYearKey>(this as ExpensesDataYearKey, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ExpensesDataYearKey&&(identical(other.year, year) || other.year == year));
}


@override
int get hashCode => Object.hash(runtimeType,year);

@override
String toString() {
  return 'ExpensesDataYearKey(year: $year)';
}


}

/// @nodoc
abstract mixin class $ExpensesDataYearKeyCopyWith<$Res>  {
  factory $ExpensesDataYearKeyCopyWith(ExpensesDataYearKey value, $Res Function(ExpensesDataYearKey) _then) = _$ExpensesDataYearKeyCopyWithImpl;
@useResult
$Res call({
 int year
});




}
/// @nodoc
class _$ExpensesDataYearKeyCopyWithImpl<$Res>
    implements $ExpensesDataYearKeyCopyWith<$Res> {
  _$ExpensesDataYearKeyCopyWithImpl(this._self, this._then);

  final ExpensesDataYearKey _self;
  final $Res Function(ExpensesDataYearKey) _then;

/// Create a copy of ExpensesDataYearKey
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? year = null,}) {
  return _then(ExpensesDataYearKey._(
null == year ? _self.year : year // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}



// dart format on
