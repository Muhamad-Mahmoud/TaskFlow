import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../domain/models/task_models.dart';
import '../../data/repositories/tasks_repository_impl.dart';

sealed class TasksEvent extends Equatable {
  const TasksEvent();
  @override
  List<Object?> get props => [];
}

class LoadTasksRequested extends TasksEvent {
  final String? projectId;
  final int page;
  final int pageSize;
  const LoadTasksRequested({this.projectId, this.page = 1, this.pageSize = 20});
  @override
  List<Object?> get props => [projectId, page, pageSize];
}

class CreateTaskRequested extends TasksEvent {
  final CreateTaskRequest request;
  const CreateTaskRequested(this.request);
  @override
  List<Object?> get props => [request];
}

sealed class TasksState extends Equatable {
  @override
  List<Object?> get props => [];
}

class TasksInitial extends TasksState {}

class TasksLoading extends TasksState {}

class TasksLoaded extends TasksState {
  final List<TaskSummary> tasks;
  final bool hasNextPage;
  TasksLoaded(this.tasks, {this.hasNextPage = false});
  @override
  List<Object?> get props => [tasks, hasNextPage];
}

class TasksFailure extends TasksState {
  final String message;
  TasksFailure(this.message);
  @override
  List<Object?> get props => [message];
}

@injectable
class TasksBloc extends Bloc<TasksEvent, TasksState> {
  final TasksRepository repo;

  TasksBloc(this.repo) : super(TasksInitial()) {
    on<LoadTasksRequested>(_onLoad);
    on<CreateTaskRequested>(_onCreate);
  }

  Future<void> _onLoad(LoadTasksRequested event, Emitter<TasksState> emit) async {
    emit(TasksLoading());
    final r = await repo.list(projectId: event.projectId, page: event.page, pageSize: event.pageSize);
    r.fold(
      (f) => emit(TasksFailure(f.message)),
      (p) => emit(TasksLoaded(p.items, hasNextPage: p.hasNextPage)),
    );
  }

  Future<void> _onCreate(CreateTaskRequested event, Emitter<TasksState> emit) async {
    emit(TasksLoading());
    final r = await repo.create(event.request);
    r.fold(
      (f) => emit(TasksFailure(f.message)),
      (_) {
        add(LoadTasksRequested(projectId: event.request.projectId));
      },
    );
  }
}
