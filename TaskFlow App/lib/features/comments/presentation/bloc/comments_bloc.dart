import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../domain/models/comment_models.dart';
import '../../data/repositories/comments_repository_impl.dart';

sealed class CommentsEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadCommentsRequested extends CommentsEvent {
  final String taskId;
  final int page;
  final int pageSize;
  LoadCommentsRequested(this.taskId, {this.page = 1, this.pageSize = 20});
  @override
  List<Object?> get props => [taskId, page, pageSize];
}

class AddCommentRequested extends CommentsEvent {
  final CreateCommentRequest request;
  AddCommentRequested(this.request);
  @override
  List<Object?> get props => [request];
}

sealed class CommentsState extends Equatable {
  @override
  List<Object?> get props => [];
}

class CommentsInitial extends CommentsState {}

class CommentsLoading extends CommentsState {}

class CommentsLoaded extends CommentsState {
  final List<CommentResponse> comments;
  final bool hasNextPage;
  CommentsLoaded(this.comments, {this.hasNextPage = false});
  @override
  List<Object?> get props => [comments, hasNextPage];
}

class CommentsFailure extends CommentsState {
  final String message;
  CommentsFailure(this.message);
  @override
  List<Object?> get props => [message];
}

@injectable
class CommentsBloc extends Bloc<CommentsEvent, CommentsState> {
  final CommentsRepository repo;

  CommentsBloc(this.repo) : super(CommentsInitial()) {
    on<LoadCommentsRequested>(_onLoad);
    on<AddCommentRequested>(_onAdd);
  }

  Future<void> _onLoad(LoadCommentsRequested event, Emitter<CommentsState> emit) async {
    emit(CommentsLoading());
    final r = await repo.list(event.taskId, page: event.page, pageSize: event.pageSize);
    r.fold(
      (f) => emit(CommentsFailure(f.message)),
      (p) => emit(CommentsLoaded(p.items, hasNextPage: p.hasNextPage)),
    );
  }

  Future<void> _onAdd(AddCommentRequested event, Emitter<CommentsState> emit) async {
    final r = await repo.create(event.request);
    r.fold(
      (f) => emit(CommentsFailure(f.message)),
      (c) {
        if (state is CommentsLoaded) {
          final s = state as CommentsLoaded;
          emit(CommentsLoaded([c, ...s.comments], hasNextPage: s.hasNextPage));
        } else {
          emit(CommentsLoaded([c]));
        }
      },
    );
  }
}
