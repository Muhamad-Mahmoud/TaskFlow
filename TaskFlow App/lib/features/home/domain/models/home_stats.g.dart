// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_stats.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_HomeStats _$HomeStatsFromJson(Map<String, dynamic> json) => _HomeStats(
  totalTasks: (json['totalTasks'] as num).toInt(),
  completedCount: (json['completedCount'] as num).toInt(),
  inProgressCount: (json['inProgressCount'] as num).toInt(),
  reviewCount: (json['reviewCount'] as num).toInt(),
  blockedCount: (json['blockedCount'] as num).toInt(),
  todoCount: (json['todoCount'] as num).toInt(),
  totalProjects: (json['totalProjects'] as num).toInt(),
  completionPercentage: (json['completionPercentage'] as num).toDouble(),
);

Map<String, dynamic> _$HomeStatsToJson(_HomeStats instance) =>
    <String, dynamic>{
      'totalTasks': instance.totalTasks,
      'completedCount': instance.completedCount,
      'inProgressCount': instance.inProgressCount,
      'reviewCount': instance.reviewCount,
      'blockedCount': instance.blockedCount,
      'todoCount': instance.todoCount,
      'totalProjects': instance.totalProjects,
      'completionPercentage': instance.completionPercentage,
    };
