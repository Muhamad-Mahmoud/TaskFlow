import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';
import '../config/app_config.dart';
import '../network/dio_client.dart';
import '../network/auth_interceptor.dart';
import '../utils/auth_event_bus.dart';

@module
abstract class RegisterModule {
  @lazySingleton
  AppConfig get config => AppConfig.dev(); // Default to dev for now

  @lazySingleton
  FlutterSecureStorage get secureStorage => const FlutterSecureStorage();

  @lazySingleton
  AuthEventBus get authEventBus => AuthEventBus();

  @lazySingleton
  Dio dio(AppConfig config, AuthInterceptor authInterceptor) =>
      DioClient.create(config, authInterceptor);
}

