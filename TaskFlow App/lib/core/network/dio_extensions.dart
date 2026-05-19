import 'package:dio/dio.dart';
import '../error/failure.dart';
import 'api_response.dart';

extension DioApi on Dio {
	Future<T> getData<T>(String path, T Function(Object?) fromT, {Map<String, dynamic>? query}) async {
		final r = await get(path, queryParameters: query);
		final env = ApiResponse<T>.fromJson(r.data as Map<String, dynamic>, fromT);
		if (!env.succeeded || env.data == null) {
			throw ServerFailure(env.message ?? 'Request failed', errors: env.errors);
		}
		return env.data as T;
	}

	Future<T> postData<T>(String path, Object? body, T Function(Object?) fromT) async {
		final r = await post(path, data: body);
		final env = ApiResponse<T>.fromJson(r.data as Map<String, dynamic>, fromT);
		if (!env.succeeded || env.data == null) {
			throw ServerFailure(env.message ?? 'Request failed', errors: env.errors);
		}
		return env.data as T;
	}

  Future<T> putData<T>(String path, Object? body, T Function(Object?) fromT) async {
		final r = await put(path, data: body);
		final env = ApiResponse<T>.fromJson(r.data as Map<String, dynamic>, fromT);
		if (!env.succeeded || env.data == null) {
			throw ServerFailure(env.message ?? 'Request failed', errors: env.errors);
		}
		return env.data as T;
	}

  Future<T> patchData<T>(String path, Object? body, T Function(Object?) fromT) async {
		final r = await patch(path, data: body);
		final env = ApiResponse<T>.fromJson(r.data as Map<String, dynamic>, fromT);
		if (!env.succeeded || env.data == null) {
			throw ServerFailure(env.message ?? 'Request failed', errors: env.errors);
		}
		return env.data as T;
	}

	Future<void> deleteOk(String path) async {
		final r = await delete(path);
		final env = ApiResponse<dynamic>.fromJson(
			r.data as Map<String, dynamic>, (j) => j);
		if (!env.succeeded) {
			throw ServerFailure(env.message ?? 'Delete failed', errors: env.errors);
		}
	}

  Future<void> postOk(String path, {Object? data}) async {
    final r = await post(path, data: data);
    final env = ApiResponse<dynamic>.fromJson(
      r.data as Map<String, dynamic>, (j) => j);
    if (!env.succeeded) {
      throw ServerFailure(env.message ?? 'Post failed', errors: env.errors);
    }
  }

  Future<void> patchOk(String path, {Object? data}) async {
    final r = await patch(path, data: data);
    final env = ApiResponse<dynamic>.fromJson(
      r.data as Map<String, dynamic>, (j) => j);
    if (!env.succeeded) {
      throw ServerFailure(env.message ?? 'Patch failed', errors: env.errors);
    }
  }
}

