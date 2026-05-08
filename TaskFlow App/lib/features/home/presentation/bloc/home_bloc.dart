import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:taskflow/core/error/failure.dart';
import 'package:taskflow/features/home/domain/models/home_stats.dart';
import 'package:taskflow/features/home/domain/repositories/home_repository.dart';
import 'package:taskflow/features/tasks/domain/models/task_models.dart';
import 'package:taskflow/features/tasks/data/datasources/tasks_remote_datasource.dart';

part 'home_event.dart';
part 'home_state.dart';
part 'home_bloc.freezed.dart';

@injectable
class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final IHomeRepository _repository;
  final TasksRemoteDataSource _tasksRemote;

  HomeBloc(this._repository, this._tasksRemote) : super(const HomeState.initial()) {
    on<HomeEvent>((event, emit) async {
      await event.map(
        started: (_) async {
          emit(const HomeState.loading());
          final statsRes = await _repository.getStats();
          
          // Get priority tasks (highest priority tasks)
          try {
            final tasksRes = await _tasksRemote.list(pageSize: 5); // Just get first few tasks for now
            
            statsRes.fold(
              (f) => emit(HomeState.failure(f.message)),
              (stats) => emit(HomeState.success(stats, tasksRes.items)),
            );
          } catch (e) {
             statsRes.fold(
              (f) => emit(HomeState.failure(f.message)),
              (stats) => emit(HomeState.success(stats, [])),
            );
          }
        },
      );
    });
  }
}
