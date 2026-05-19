import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/constants/api_paths.dart';
import '../../../../core/network/dio_extensions.dart';
import '../../domain/models/tag_models.dart';

@injectable
class TagsRemoteDataSource {
	final Dio dio;
	TagsRemoteDataSource(this.dio);

	Future<List<TagResponse>> list() =>
			dio.getData(ApiPaths.tags, (j) => (j as List).map((x) => TagResponse.fromJson(x as Map<String, dynamic>)).toList());

	Future<TagResponse> create(CreateTagRequest r) =>
			dio.postData(ApiPaths.tags, r.toJson(), (j) => TagResponse.fromJson(j as Map<String, dynamic>));

	Future<void> delete(String id) => dio.deleteOk(ApiPaths.tag(id));
}
