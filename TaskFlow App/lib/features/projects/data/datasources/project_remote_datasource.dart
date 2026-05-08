import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/constants/api_paths.dart';
import '../../../../core/network/api_response.dart';
import '../../../../core/network/dio_extensions.dart';
import '../models/project_models.dart';

@injectable
class ProjectsRemoteDataSource {
	final Dio dio;
	ProjectsRemoteDataSource(this.dio);

	Future<PagedResult<ProjectSummary>> list({int page = 1, int pageSize = 20}) =>
			dio.getData(ApiPaths.projects,
				(j) => PagedResult<ProjectSummary>.fromJson(j as Map<String, dynamic>,
					(p) => ProjectSummary.fromJson(p as Map<String, dynamic>)),
				query: {'page': page, 'pageSize': pageSize});

	Future<ProjectResponse> create(CreateProjectRequest r) =>
			dio.postData(ApiPaths.projects, r.toJson(),
				(j) => ProjectResponse.fromJson(j as Map<String, dynamic>));

	Future<ProjectResponse> get(String id) =>
			dio.getData(ApiPaths.project(id), (j) => ProjectResponse.fromJson(j as Map<String, dynamic>));

	Future<ProjectResponse> update(String id, UpdateProjectRequest r) =>
			dio.putData(ApiPaths.project(id), r.toJson(),
				(j) => ProjectResponse.fromJson(j as Map<String, dynamic>));

	Future<void> delete(String id) => dio.deleteOk(ApiPaths.project(id));

	Future<ProjectStatsResponse> stats(String id) =>
			dio.getData(ApiPaths.projectStats(id),
				(j) => ProjectStatsResponse.fromJson(j as Map<String, dynamic>));

	Future<ProjectMemberResponse> invite(String id, InviteMemberRequest r) =>
			dio.postData(ApiPaths.projectMembers(id), r.toJson(),
				(j) => ProjectMemberResponse.fromJson(j as Map<String, dynamic>));

	Future<ProjectMemberResponse> changeRole(String id, String userId, ChangeMemberRoleRequest r) =>
			dio.patchData(ApiPaths.projectMember(id, userId), r.toJson(),
				(j) => ProjectMemberResponse.fromJson(j as Map<String, dynamic>));

	Future<void> removeMember(String id, String userId) =>
			dio.deleteOk(ApiPaths.projectMember(id, userId));
}

