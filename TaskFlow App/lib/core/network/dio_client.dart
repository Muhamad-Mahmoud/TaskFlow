import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import '../config/app_config.dart';
import 'auth_interceptor.dart';
import 'error_interceptor.dart';

class DioClient {
	static Dio create(AppConfig config, AuthInterceptor authInterceptor) {
		final dio = Dio(BaseOptions(
			baseUrl: config.baseUrl,
			connectTimeout: const Duration(seconds: 15),
			receiveTimeout: const Duration(seconds: 20),
			headers: {'Accept': 'application/json'},
		));
		dio.interceptors.addAll([
			authInterceptor,
			ErrorInterceptor(),
			if (config.enableLogs)
				PrettyDioLogger(requestHeader: true, requestBody: true, responseBody: true, responseHeader: false, compact: true),
		]);
		return dio;
	}
}

