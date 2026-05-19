// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:dio/dio.dart' as _i361;
import 'package:flutter_secure_storage/flutter_secure_storage.dart' as _i558;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:taskflow/core/config/app_config.dart' as _i404;
import 'package:taskflow/core/di/register_module.dart' as _i438;
import 'package:taskflow/core/network/auth_interceptor.dart' as _i845;
import 'package:taskflow/core/storage/secure_storage.dart' as _i389;
import 'package:taskflow/core/utils/auth_event_bus.dart' as _i661;
import 'package:taskflow/features/auth/data/datasources/auth_remote_datasource.dart'
    as _i768;
import 'package:taskflow/features/auth/data/repositories/auth_repository_impl.dart'
    as _i860;
import 'package:taskflow/features/auth/domain/repositories/auth_repository.dart'
    as _i697;
import 'package:taskflow/features/auth/domain/usecases/auth_usecases.dart'
    as _i385;
import 'package:taskflow/features/auth/presentation/bloc/auth_bloc.dart'
    as _i662;
import 'package:taskflow/features/home/data/datasources/home_remote_datasource.dart'
    as _i870;
import 'package:taskflow/features/home/domain/repositories/home_repository.dart'
    as _i45;
import 'package:taskflow/features/home/presentation/bloc/home_bloc.dart'
    as _i522;
import 'package:taskflow/features/projects/data/datasources/project_remote_datasource.dart'
    as _i119;
import 'package:taskflow/features/projects/data/repositories/projects_repository_impl.dart'
    as _i750;
import 'package:taskflow/features/projects/presentation/bloc/projects_bloc.dart'
    as _i794;
import 'package:taskflow/features/tasks/data/datasources/tasks_remote_datasource.dart'
    as _i925;
import 'package:taskflow/features/tasks/data/repositories/tasks_repository_impl.dart'
    as _i536;
import 'package:taskflow/features/tasks/presentation/bloc/tasks_bloc.dart'
    as _i61;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final registerModule = _$RegisterModule();
    gh.lazySingleton<_i404.AppConfig>(() => registerModule.config);
    gh.lazySingleton<_i558.FlutterSecureStorage>(
      () => registerModule.secureStorage,
    );
    gh.lazySingleton<_i661.AuthEventBus>(() => registerModule.authEventBus);
    gh.lazySingleton<_i389.SecureStorage>(
      () => _i389.SecureStorage(gh<_i558.FlutterSecureStorage>()),
    );
    gh.factory<_i845.AuthInterceptor>(
      () => _i845.AuthInterceptor(
        gh<_i389.SecureStorage>(),
        gh<_i661.AuthEventBus>(),
      ),
    );
    gh.lazySingleton<_i361.Dio>(
      () => registerModule.dio(
        gh<_i404.AppConfig>(),
        gh<_i845.AuthInterceptor>(),
      ),
    );
    gh.factory<_i768.AuthRemoteDataSource>(
      () => _i768.AuthRemoteDataSource(gh<_i361.Dio>()),
    );
    gh.factory<_i870.HomeRemoteDataSource>(
      () => _i870.HomeRemoteDataSource(gh<_i361.Dio>()),
    );
    gh.factory<_i119.ProjectsRemoteDataSource>(
      () => _i119.ProjectsRemoteDataSource(gh<_i361.Dio>()),
    );
    gh.factory<_i925.TasksRemoteDataSource>(
      () => _i925.TasksRemoteDataSource(gh<_i361.Dio>()),
    );
    gh.lazySingleton<_i45.IHomeRepository>(
      () => _i45.HomeRepository(gh<_i870.HomeRemoteDataSource>()),
    );
    gh.lazySingleton<_i536.TasksRepository>(
      () => _i536.TasksRepositoryImpl(gh<_i925.TasksRemoteDataSource>()),
    );
    gh.factory<_i522.HomeBloc>(
      () => _i522.HomeBloc(
        gh<_i45.IHomeRepository>(),
        gh<_i925.TasksRemoteDataSource>(),
      ),
    );
    gh.factory<_i61.TasksBloc>(
      () => _i61.TasksBloc(gh<_i536.TasksRepository>()),
    );
    gh.lazySingleton<_i750.ProjectsRepository>(
      () => _i750.ProjectsRepositoryImpl(gh<_i119.ProjectsRemoteDataSource>()),
    );
    gh.lazySingleton<_i697.AuthRepository>(
      () => _i860.AuthRepositoryImpl(
        gh<_i768.AuthRemoteDataSource>(),
        gh<_i389.SecureStorage>(),
      ),
    );
    gh.factory<_i385.LoginUseCase>(
      () => _i385.LoginUseCase(gh<_i697.AuthRepository>()),
    );
    gh.factory<_i385.RegisterUseCase>(
      () => _i385.RegisterUseCase(gh<_i697.AuthRepository>()),
    );
    gh.factory<_i385.LogoutUseCase>(
      () => _i385.LogoutUseCase(gh<_i697.AuthRepository>()),
    );
    gh.factory<_i385.GetCurrentUserUseCase>(
      () => _i385.GetCurrentUserUseCase(gh<_i697.AuthRepository>()),
    );
    gh.factory<_i662.AuthBloc>(
      () => _i662.AuthBloc(
        gh<_i385.LoginUseCase>(),
        gh<_i385.RegisterUseCase>(),
        gh<_i385.LogoutUseCase>(),
        gh<_i697.AuthRepository>(),
      ),
    );
    gh.factory<_i794.ProjectsBloc>(
      () => _i794.ProjectsBloc(gh<_i750.ProjectsRepository>()),
    );
    return this;
  }
}

class _$RegisterModule extends _i438.RegisterModule {}
