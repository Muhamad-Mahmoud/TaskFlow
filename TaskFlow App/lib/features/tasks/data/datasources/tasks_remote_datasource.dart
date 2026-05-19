import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/constants/api_paths.dart';
import '../../../../core/network/api_response.dart';
import '../../../../core/network/dio_extensions.dart';
import '../../domain/models/task_models.dart';

@injectable
class TasksRemoteDataSource {
	final Dio dio;
	TasksRemoteDataSource(this.dio);

	Future<PagedResult<TaskSummary>> list({String? projectId, int page = 1, int pageSize = 20}) =>
			dio.getData(ApiPaths.tasks,
				(j) => PagedResult<TaskSummary>.fromJson(j as Map<String, dynamic>,
					(p) => TaskSummary.fromJson(p as Map<String, dynamic>)),
				query: {
					if (projectId != null) 'projectId': projectId,
					'page': page,
					'pageSize': pageSize,
				});

	Future<TaskResponse> create(CreateTaskRequest r) =>
			dio.postData(ApiPaths.tasks, r.toJson(),
				(j) => TaskResponse.fromJson(j as Map<String, dynamic>));

	Future<TaskResponse> get(String id) =>
			dio.getData(ApiPaths.task(id), (j) => TaskResponse.fromJson(j as Map<String, dynamic>));

	Future<TaskResponse> update(String id, UpdateTaskRequest r) =>
			dio.putData(ApiPaths.task(id), r.toJson(),
				(j) => TaskResponse.fromJson(j as Map<String, dynamic>));

	Future<void> delete(String id) => dio.deleteOk(ApiPaths.task(id));

	Future<void> updateStatus(String id, UpdateTaskStatusRequest r) =>
			dio.patchOk(ApiPaths.taskStatus(id), data: r.toJson());

	Future<void> updatePosition(String id, UpdateTaskPositionRequest r) =>
			dio.patchOk(ApiPaths.taskPosition(id), data: r.toJson());

	Future<SubtaskResponse> createSubtask(String id, CreateSubtaskRequest r) =>
			dio.postData(ApiPaths.subtasks(id), r.toJson(),
					(j) => SubtaskResponse.fromJson(j as Map<String, dynamic>));

	Future<SubtaskResponse> updateSubtask(String id, String sid, UpdateSubtaskRequest r) =>
			dio.patchData(ApiPaths.subtask(id, sid), r.toJson(),
					(j) => SubtaskResponse.fromJson(j as Map<String, dynamic>));

	Future<void> deleteSubtask(String id, String sid) =>
			dio.deleteOk(ApiPaths.subtask(id, sid));
}
