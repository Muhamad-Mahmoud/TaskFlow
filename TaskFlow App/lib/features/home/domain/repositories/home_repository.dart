import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:taskflow/core/error/failure.dart';
import 'package:taskflow/features/home/domain/models/home_stats.dart';
import 'package:taskflow/features/home/data/datasources/home_remote_datasource.dart';

abstract class IHomeRepository {
  Future<Either<Failure, HomeStats>> getStats();
}

@LazySingleton(as: IHomeRepository)
class HomeRepository implements IHomeRepository {
  final HomeRemoteDataSource _remote;
  HomeRepository(this._remote);

  @override
  Future<Either<Failure, HomeStats>> getStats() async {
    try {
      final stats = await _remote.getStats();
      return Right(stats);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
