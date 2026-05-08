// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'home_stats.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$HomeStats {

 int get totalTasks; int get completedCount; int get inProgressCount; int get reviewCount; int get blockedCount; int get todoCount; int get totalProjects; double get completionPercentage;
/// Create a copy of HomeStats
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HomeStatsCopyWith<HomeStats> get copyWith => _$HomeStatsCopyWithImpl<HomeStats>(this as HomeStats, _$identity);

  /// Serializes this HomeStats to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HomeStats&&(identical(other.totalTasks, totalTasks) || other.totalTasks == totalTasks)&&(identical(other.completedCount, completedCount) || other.completedCount == completedCount)&&(identical(other.inProgressCount, inProgressCount) || other.inProgressCount == inProgressCount)&&(identical(other.reviewCount, reviewCount) || other.reviewCount == reviewCount)&&(identical(other.blockedCount, blockedCount) || other.blockedCount == blockedCount)&&(identical(other.todoCount, todoCount) || other.todoCount == todoCount)&&(identical(other.totalProjects, totalProjects) || other.totalProjects == totalProjects)&&(identical(other.completionPercentage, completionPercentage) || other.completionPercentage == completionPercentage));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,totalTasks,completedCount,inProgressCount,reviewCount,blockedCount,todoCount,totalProjects,completionPercentage);

@override
String toString() {
  return 'HomeStats(totalTasks: $totalTasks, completedCount: $completedCount, inProgressCount: $inProgressCount, reviewCount: $reviewCount, blockedCount: $blockedCount, todoCount: $todoCount, totalProjects: $totalProjects, completionPercentage: $completionPercentage)';
}


}

/// @nodoc
abstract mixin class $HomeStatsCopyWith<$Res>  {
  factory $HomeStatsCopyWith(HomeStats value, $Res Function(HomeStats) _then) = _$HomeStatsCopyWithImpl;
@useResult
$Res call({
 int totalTasks, int completedCount, int inProgressCount, int reviewCount, int blockedCount, int todoCount, int totalProjects, double completionPercentage
});




}
/// @nodoc
class _$HomeStatsCopyWithImpl<$Res>
    implements $HomeStatsCopyWith<$Res> {
  _$HomeStatsCopyWithImpl(this._self, this._then);

  final HomeStats _self;
  final $Res Function(HomeStats) _then;

/// Create a copy of HomeStats
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? totalTasks = null,Object? completedCount = null,Object? inProgressCount = null,Object? reviewCount = null,Object? blockedCount = null,Object? todoCount = null,Object? totalProjects = null,Object? completionPercentage = null,}) {
  return _then(_self.copyWith(
totalTasks: null == totalTasks ? _self.totalTasks : totalTasks // ignore: cast_nullable_to_non_nullable
as int,completedCount: null == completedCount ? _self.completedCount : completedCount // ignore: cast_nullable_to_non_nullable
as int,inProgressCount: null == inProgressCount ? _self.inProgressCount : inProgressCount // ignore: cast_nullable_to_non_nullable
as int,reviewCount: null == reviewCount ? _self.reviewCount : reviewCount // ignore: cast_nullable_to_non_nullable
as int,blockedCount: null == blockedCount ? _self.blockedCount : blockedCount // ignore: cast_nullable_to_non_nullable
as int,todoCount: null == todoCount ? _self.todoCount : todoCount // ignore: cast_nullable_to_non_nullable
as int,totalProjects: null == totalProjects ? _self.totalProjects : totalProjects // ignore: cast_nullable_to_non_nullable
as int,completionPercentage: null == completionPercentage ? _self.completionPercentage : completionPercentage // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [HomeStats].
extension HomeStatsPatterns on HomeStats {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _HomeStats value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _HomeStats() when $default != null:
return $default(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _HomeStats value)  $default,){
final _that = this;
switch (_that) {
case _HomeStats():
return $default(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _HomeStats value)?  $default,){
final _that = this;
switch (_that) {
case _HomeStats() when $default != null:
return $default(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int totalTasks,  int completedCount,  int inProgressCount,  int reviewCount,  int blockedCount,  int todoCount,  int totalProjects,  double completionPercentage)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _HomeStats() when $default != null:
return $default(_that.totalTasks,_that.completedCount,_that.inProgressCount,_that.reviewCount,_that.blockedCount,_that.todoCount,_that.totalProjects,_that.completionPercentage);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int totalTasks,  int completedCount,  int inProgressCount,  int reviewCount,  int blockedCount,  int todoCount,  int totalProjects,  double completionPercentage)  $default,) {final _that = this;
switch (_that) {
case _HomeStats():
return $default(_that.totalTasks,_that.completedCount,_that.inProgressCount,_that.reviewCount,_that.blockedCount,_that.todoCount,_that.totalProjects,_that.completionPercentage);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int totalTasks,  int completedCount,  int inProgressCount,  int reviewCount,  int blockedCount,  int todoCount,  int totalProjects,  double completionPercentage)?  $default,) {final _that = this;
switch (_that) {
case _HomeStats() when $default != null:
return $default(_that.totalTasks,_that.completedCount,_that.inProgressCount,_that.reviewCount,_that.blockedCount,_that.todoCount,_that.totalProjects,_that.completionPercentage);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _HomeStats implements HomeStats {
  const _HomeStats({required this.totalTasks, required this.completedCount, required this.inProgressCount, required this.reviewCount, required this.blockedCount, required this.todoCount, required this.totalProjects, required this.completionPercentage});
  factory _HomeStats.fromJson(Map<String, dynamic> json) => _$HomeStatsFromJson(json);

@override final  int totalTasks;
@override final  int completedCount;
@override final  int inProgressCount;
@override final  int reviewCount;
@override final  int blockedCount;
@override final  int todoCount;
@override final  int totalProjects;
@override final  double completionPercentage;

/// Create a copy of HomeStats
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HomeStatsCopyWith<_HomeStats> get copyWith => __$HomeStatsCopyWithImpl<_HomeStats>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$HomeStatsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _HomeStats&&(identical(other.totalTasks, totalTasks) || other.totalTasks == totalTasks)&&(identical(other.completedCount, completedCount) || other.completedCount == completedCount)&&(identical(other.inProgressCount, inProgressCount) || other.inProgressCount == inProgressCount)&&(identical(other.reviewCount, reviewCount) || other.reviewCount == reviewCount)&&(identical(other.blockedCount, blockedCount) || other.blockedCount == blockedCount)&&(identical(other.todoCount, todoCount) || other.todoCount == todoCount)&&(identical(other.totalProjects, totalProjects) || other.totalProjects == totalProjects)&&(identical(other.completionPercentage, completionPercentage) || other.completionPercentage == completionPercentage));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,totalTasks,completedCount,inProgressCount,reviewCount,blockedCount,todoCount,totalProjects,completionPercentage);

@override
String toString() {
  return 'HomeStats(totalTasks: $totalTasks, completedCount: $completedCount, inProgressCount: $inProgressCount, reviewCount: $reviewCount, blockedCount: $blockedCount, todoCount: $todoCount, totalProjects: $totalProjects, completionPercentage: $completionPercentage)';
}


}

/// @nodoc
abstract mixin class _$HomeStatsCopyWith<$Res> implements $HomeStatsCopyWith<$Res> {
  factory _$HomeStatsCopyWith(_HomeStats value, $Res Function(_HomeStats) _then) = __$HomeStatsCopyWithImpl;
@override @useResult
$Res call({
 int totalTasks, int completedCount, int inProgressCount, int reviewCount, int blockedCount, int todoCount, int totalProjects, double completionPercentage
});




}
/// @nodoc
class __$HomeStatsCopyWithImpl<$Res>
    implements _$HomeStatsCopyWith<$Res> {
  __$HomeStatsCopyWithImpl(this._self, this._then);

  final _HomeStats _self;
  final $Res Function(_HomeStats) _then;

/// Create a copy of HomeStats
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? totalTasks = null,Object? completedCount = null,Object? inProgressCount = null,Object? reviewCount = null,Object? blockedCount = null,Object? todoCount = null,Object? totalProjects = null,Object? completionPercentage = null,}) {
  return _then(_HomeStats(
totalTasks: null == totalTasks ? _self.totalTasks : totalTasks // ignore: cast_nullable_to_non_nullable
as int,completedCount: null == completedCount ? _self.completedCount : completedCount // ignore: cast_nullable_to_non_nullable
as int,inProgressCount: null == inProgressCount ? _self.inProgressCount : inProgressCount // ignore: cast_nullable_to_non_nullable
as int,reviewCount: null == reviewCount ? _self.reviewCount : reviewCount // ignore: cast_nullable_to_non_nullable
as int,blockedCount: null == blockedCount ? _self.blockedCount : blockedCount // ignore: cast_nullable_to_non_nullable
as int,todoCount: null == todoCount ? _self.todoCount : todoCount // ignore: cast_nullable_to_non_nullable
as int,totalProjects: null == totalProjects ? _self.totalProjects : totalProjects // ignore: cast_nullable_to_non_nullable
as int,completionPercentage: null == completionPercentage ? _self.completionPercentage : completionPercentage // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

// dart format on
