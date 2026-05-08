import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/error_mapper.dart';
import '../../../../core/error/failure.dart';
import '../datasources/project_remote_datasource.dart';
import '../models/project_models.dart';
import '../../../../core/network/api_response.dart';

abstract class ProjectsRepository {
  Future<Either<Failure, PagedResult<ProjectSummary>>> list({int page = 1, int pageSize = 20});
  Future<Either<Failure, ProjectResponse>> create(CreateProjectRequest r);
  Future<Either<Failure, ProjectResponse>> get(String id);
  Future<Either<Failure, ProjectResponse>> update(String id, UpdateProjectRequest r);
  Future<Either<Failure, Unit>> delete(String id);
  Future<Either<Failure, ProjectStatsResponse>> getStats(String id);
  Future<Either<Failure, ProjectMemberResponse>> invite(String id, InviteMemberRequest r);
}

@LazySingleton(as: ProjectsRepository)
class ProjectsRepositoryImpl implements ProjectsRepository {
	final ProjectsRemoteDataSource remote;
	ProjectsRepositoryImpl(this.remote);

	@override
	Future<Either<Failure, PagedResult<ProjectSummary>>> list({int page = 1, int pageSize = 20}) async {
		try {
			final res = await remote.list(page: page, pageSize: pageSize);
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
	Future<Either<Failure, ProjectResponse>> create(CreateProjectRequest r) async {
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
	Future<Either<Failure, ProjectResponse>> get(String id) async {
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
	Future<Either<Failure, ProjectResponse>> update(String id, UpdateProjectRequest r) async {
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

	@override
	Future<Either<Failure, ProjectStatsResponse>> getStats(String id) async {
		try {
			final res = await remote.stats(id);
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
	Future<Either<Failure, ProjectMemberResponse>> invite(String id, InviteMemberRequest r) async {
		try {
			final res = await remote.invite(id, r);
			return Right(res);
		} on ServerFailure catch (f) {
      return Left(f);
    } on DioException catch (e) {
      return Left(ErrorMapper.fromDio(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
	}
}
