import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/constants/api_paths.dart';
import '../../../../core/network/api_response.dart';
import '../../../../core/network/dio_extensions.dart';
import '../../domain/models/auth_models.dart';

@injectable
class AuthRemoteDataSource {
	final Dio dio;
	AuthRemoteDataSource(this.dio);

	Future<AuthResponse> register(RegisterRequest r) =>
			dio.postData('${ApiPaths.auth}/register', r.toJson(), (j) => AuthResponse.fromJson(j as Map<String, dynamic>));

	Future<AuthResponse> login(LoginRequest r) =>
			dio.postData('${ApiPaths.auth}/login', r.toJson(), (j) => AuthResponse.fromJson(j as Map<String, dynamic>));
}

