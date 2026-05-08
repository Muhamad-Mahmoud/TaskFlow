import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/constants/api_paths.dart';
import '../../../../core/network/dio_extensions.dart';
import 'package:taskflow/features/home/domain/models/home_stats.dart';

@injectable
class HomeRemoteDataSource {
  final Dio dio;
  HomeRemoteDataSource(this.dio);

  Future<HomeStats> getStats() => 
      dio.getData(ApiPaths.usersMe + '/stats', (j) => HomeStats.fromJson(j as Map<String, dynamic>));
}
