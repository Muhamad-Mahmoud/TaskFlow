import 'package:freezed_annotation/freezed_annotation.dart';

part 'home_stats.freezed.dart';
part 'home_stats.g.dart';

@freezed
abstract class HomeStats with _$HomeStats {
  const factory HomeStats({
    required int totalTasks,
    required int completedCount,
    required int inProgressCount,
    required int reviewCount,
    required int blockedCount,
    required int todoCount,
    required int totalProjects,
    required double completionPercentage,
  }) = _HomeStats;

  factory HomeStats.fromJson(Map<String, dynamic> json) => _$HomeStatsFromJson(json);
}
