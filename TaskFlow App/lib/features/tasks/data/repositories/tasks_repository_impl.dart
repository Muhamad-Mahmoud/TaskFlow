import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/error_mapper.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/network/api_response.dart';
import '../../domain/models/task_models.dart';
import '../datasources/tasks_remote_datasource.dart';

abstract class TasksRepository {
  Future<Either<Failure, PagedResult<TaskSummary>>> list({String? projectId, int page = 1, int pageSize = 20});
  Future<Either<Failure, TaskResponse>> create(CreateTaskRequest r);
  Future<Either<Failure, TaskResponse>> get(String id);
  Future<Either<Failure, TaskResponse>> update(String id, UpdateTaskRequest r);
  Future<Either<Failure, Unit>> delete(String id);
}

@LazySingleton(as: TasksRepository)
class TasksRepositoryImpl implements TasksRepository {
	final TasksRemoteDataSource remote;
	TasksRepositoryImpl(this.remote);

	@override
	Future<Either<Failure, PagedResult<TaskSummary>>> list({String? projectId, int page = 1, int pageSize = 20}) async {
		try {
			final res = await remote.list(projectId: projectId, page: page, pageSize: pageSize);
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
	Future<Either<Failure, TaskResponse>> create(CreateTaskRequest r) async {
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
	Future<Either<Failure, TaskResponse>> get(String id) async {
		try {
			final res = await remote.get(id);
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
	Future<Either<Failure, TaskResponse>> update(String id, UpdateTaskRequest r) async {
		try {
			final res = await remote.update(id, r);
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
	Future<Either<Failure, Unit>> delete(String id) async {
		try {
			await remote.delete(id);
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
