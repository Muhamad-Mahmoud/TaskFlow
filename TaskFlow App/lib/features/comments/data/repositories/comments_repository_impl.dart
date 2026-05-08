import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/error_mapper.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/network/api_response.dart';
import '../../domain/models/comment_models.dart';
import '../datasources/comments_remote_datasource.dart';

abstract class CommentsRepository {
  Future<Either<Failure, PagedResult<CommentResponse>>> list(String taskId, {int page = 1, int pageSize = 20});
  Future<Either<Failure, CommentResponse>> create(CreateCommentRequest r);
  Future<Either<Failure, Unit>> delete(String taskId, String commentId);
}

@LazySingleton(as: CommentsRepository)
class CommentsRepositoryImpl implements CommentsRepository {
	final CommentsRemoteDataSource remote;
	CommentsRepositoryImpl(this.remote);

	@override
	Future<Either<Failure, PagedResult<CommentResponse>>> list(String taskId, {int page = 1, int pageSize = 20}) async {
		try {
			final res = await remote.list(taskId, page: page, pageSize: pageSize);
			return Right(res);
		} on ServerFailure catch (f) {
      return Left(f);
    } on DioException catch (e) {
      return Left(ErrorMapper.fromDio(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
	}

	@override
	Future<Either<Failure, CommentResponse>> create(CreateCommentRequest r) async {
		try {
			final res = await remote.create(r);
			return Right(res);
		} on ServerFailure catch (f) {
      return Left(f);
    } on DioException catch (e) {
      return Left(ErrorMapper.fromDio(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
	}

	@override
	Future<Either<Failure, Unit>> delete(String taskId, String commentId) async {
		try {
			await remote.delete(taskId, commentId);
			return const Right(unit);
		} on ServerFailure catch (f) {
      return Left(f);
    } on DioException catch (e) {
      return Left(ErrorMapper.fromDio(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
	}
}
