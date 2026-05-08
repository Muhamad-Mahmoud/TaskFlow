import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/constants/api_paths.dart';
import '../../../../core/network/api_response.dart';
import '../../../../core/network/dio_extensions.dart';
import '../../domain/models/comment_models.dart';

@injectable
class CommentsRemoteDataSource {
	final Dio dio;
	CommentsRemoteDataSource(this.dio);

	Future<PagedResult<CommentResponse>> list(String taskId, {int page = 1, int pageSize = 20}) =>
			dio.getData(ApiPaths.comments(taskId),
				(j) => PagedResult<CommentResponse>.fromJson(j as Map<String, dynamic>,
					(p) => CommentResponse.fromJson(p as Map<String, dynamic>)),
				query: {'page': page, 'pageSize': pageSize});

	Future<CommentResponse> create(CreateCommentRequest r) =>
			dio.postData(ApiPaths.comments(r.taskId), r.toJson(),
				(j) => CommentResponse.fromJson(j as Map<String, dynamic>));

	Future<void> delete(String taskId, String commentId) => 
			dio.deleteOk(ApiPaths.comment(taskId, commentId));
}
