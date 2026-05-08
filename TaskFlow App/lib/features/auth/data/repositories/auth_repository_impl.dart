import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/error_mapper.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/storage/secure_storage.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import '../../domain/models/auth_models.dart';

@LazySingleton(as: AuthRepository)
class AuthRepositoryImpl implements AuthRepository {
	final AuthRemoteDataSource remote;
	final SecureStorage storage;
	AuthRepositoryImpl(this.remote, this.storage);

	@override
	Future<Either<Failure, AuthResponse>> login(String e, String p) async {
		try {
			final res = await remote.login(LoginRequest(email: e, password: p));
			await storage.saveTokens(res.accessToken, res.refreshToken);
			await storage.saveUser(res.user);
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
	Future<Either<Failure, AuthResponse>> register(RegisterRequest req) async {
		try {
			final res = await remote.register(req);
			await storage.saveTokens(res.accessToken, res.refreshToken);
			await storage.saveUser(res.user);
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
  Future<void> logout() => storage.clearAll();

	@override
  Future<UserDto?> currentUser() => storage.readUser();
}

