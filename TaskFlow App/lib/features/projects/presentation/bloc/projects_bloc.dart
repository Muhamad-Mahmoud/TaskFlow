import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../data/models/project_models.dart';
import '../../data/repositories/projects_repository_impl.dart';
import '../../../../core/network/api_response.dart';

// ─── Events ───────────────────────────────────────────────────────────────────
sealed class ProjectsEvent extends Equatable {
  const ProjectsEvent();
  @override
  List<Object?> get props => [];
}

class LoadProjectsRequested extends ProjectsEvent {
  final int page;
  final int pageSize;
  const LoadProjectsRequested({this.page = 1, this.pageSize = 20});
  @override
  List<Object?> get props => [page, pageSize];
}

class CreateProjectRequested extends ProjectsEvent {
  final CreateProjectRequest request;
  const CreateProjectRequested(this.request);
  @override
  List<Object?> get props => [request];
}

class LoadProjectDetailRequested extends ProjectsEvent {
  final String projectId;
  const LoadProjectDetailRequested(this.projectId);
  @override
  List<Object?> get props => [projectId];
}

class InviteMemberRequested extends ProjectsEvent {
  final String projectId;
  final InviteMemberRequest request;
  const InviteMemberRequested(this.projectId, this.request);
  @override
  List<Object?> get props => [projectId, request];
}

// ─── States ───────────────────────────────────────────────────────────────────
sealed class ProjectsState extends Equatable {
  @override
  List<Object?> get props => [];
}

class ProjectsInitial extends ProjectsState {}

class ProjectsLoading extends ProjectsState {}

class ProjectsLoaded extends ProjectsState {
  final List<ProjectSummary> projects;
  final bool hasNextPage;
  ProjectsLoaded(this.projects, {this.hasNextPage = false});
  @override
  List<Object?> get props => [projects, hasNextPage];
}

class ProjectsFailure extends ProjectsState {
  final String message;
  ProjectsFailure(this.message);
  @override
  List<Object?> get props => [message];
}

class ProjectDetailLoading extends ProjectsState {}

class ProjectDetailLoaded extends ProjectsState {
  final ProjectResponse project;
  final ProjectStatsResponse? stats;
  ProjectDetailLoaded(this.project, {this.stats});
  @override
  List<Object?> get props => [project, stats];
}

class ProjectDetailFailure extends ProjectsState {
  final String message;
  ProjectDetailFailure(this.message);
  @override
  List<Object?> get props => [message];
}

class InviteMemberSuccess extends ProjectsState {
  final ProjectMemberResponse member;
  InviteMemberSuccess(this.member);
  @override
  List<Object?> get props => [member];
}

class InviteMemberFailure extends ProjectsState {
  final String message;
  InviteMemberFailure(this.message);
  @override
  List<Object?> get props => [message];
}

// ─── BLoC ─────────────────────────────────────────────────────────────────────
@injectable
class ProjectsBloc extends Bloc<ProjectsEvent, ProjectsState> {
  final ProjectsRepository repo;

  ProjectsBloc(this.repo) : super(ProjectsInitial()) {
    on<LoadProjectsRequested>(_onLoad);
    on<CreateProjectRequested>(_onCreate);
    on<LoadProjectDetailRequested>(_onLoadDetail);
    on<InviteMemberRequested>(_onInvite);
  }

  Future<void> _onLoad(LoadProjectsRequested event, Emitter<ProjectsState> emit) async {
    emit(ProjectsLoading());
    final r = await repo.list(page: event.page, pageSize: event.pageSize);
    r.fold(
      (f) => emit(ProjectsFailure(f.message)),
      (p) => emit(ProjectsLoaded(p.items, hasNextPage: p.hasNextPage)),
    );
  }

  Future<void> _onCreate(CreateProjectRequested event, Emitter<ProjectsState> emit) async {
    emit(ProjectsLoading());
    final r = await repo.create(event.request);
    r.fold(
      (f) => emit(ProjectsFailure(f.message)),
      (_) { add(LoadProjectsRequested()); },
    );
  }

  Future<void> _onLoadDetail(LoadProjectDetailRequested event, Emitter<ProjectsState> emit) async {
    emit(ProjectDetailLoading());
    final projectResult = await repo.get(event.projectId);
    final statsResult = await repo.getStats(event.projectId);
    projectResult.fold(
      (f) => emit(ProjectDetailFailure(f.message)),
      (project) {
        statsResult.fold(
          (_) => emit(ProjectDetailLoaded(project)),
          (stats) => emit(ProjectDetailLoaded(project, stats: stats)),
        );
      },
    );
  }

  Future<void> _onInvite(InviteMemberRequested event, Emitter<ProjectsState> emit) async {
    final r = await repo.invite(event.projectId, event.request);
    r.fold(
      (f) => emit(InviteMemberFailure(f.message)),
      (member) => emit(InviteMemberSuccess(member)),
    );
  }
}
