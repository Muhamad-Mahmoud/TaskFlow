part of 'home_bloc.dart';

@freezed
abstract class HomeState with _$HomeState {
  const factory HomeState.initial() = _Initial;
  const factory HomeState.loading() = _Loading;
  const factory HomeState.success(HomeStats stats, List<TaskSummary> priorityTasks) = _Success;
  const factory HomeState.failure(String message) = _Failure;
}
