import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../storage/secure_storage.dart';
import '../utils/auth_event_bus.dart';

@injectable
class AuthInterceptor extends Interceptor {
	final SecureStorage storage;
	final AuthEventBus bus;
	
  AuthInterceptor(this.storage, this.bus);

	@override
	Future<void> onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
		final token = await storage.readAccessToken();
		if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
		handler.next(options);
	}

	@override
	Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
		if (err.response?.statusCode == 401) {
			await storage.clearTokens();
			bus.emit(AuthEvent.loggedOut);
		}
		handler.next(err);
	}
}

