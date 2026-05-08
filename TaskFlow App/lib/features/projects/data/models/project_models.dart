import 'package:json_annotation/json_annotation.dart';

part 'project_models.g.dart';

@JsonSerializable()
class ProjectSummary {
	final String id, name;
	final String? status;
	final double completionPercentage;
	final int memberCount, taskCount;
	const ProjectSummary({required this.id, required this.name, this.status, required this.completionPercentage, required this.memberCount, required this.taskCount});
	factory ProjectSummary.fromJson(Map<String, dynamic> j) => _$ProjectSummaryFromJson(j);
}

@JsonSerializable()
class ProjectMemberResponse {
	final String id, fullName;
	final String? avatarUrl, role;
	const ProjectMemberResponse({required this.id, required this.fullName, this.avatarUrl, this.role});
	factory ProjectMemberResponse.fromJson(Map<String, dynamic> j) => _$ProjectMemberResponseFromJson(j);
}

@JsonSerializable()
class ProjectResponse {
	final String id, name;
	final String? description, status, priority, colorLabel;
	final double completionPercentage;
	final DateTime? startDate, dueDate;
	final List<ProjectMemberResponse>? members;
	final DateTime createdAt, updatedAt;
	const ProjectResponse({required this.id, required this.name, this.description, this.status, this.priority, required this.completionPercentage, this.colorLabel, this.startDate, this.dueDate, this.members, required this.createdAt, required this.updatedAt});
	factory ProjectResponse.fromJson(Map<String, dynamic> j) => _$ProjectResponseFromJson(j);
}

@JsonSerializable()
class CreateProjectRequest {
	final String? name, description, colorLabel, priority;
	final DateTime? startDate, dueDate;
	final List<String>? memberIds;
	const CreateProjectRequest({this.name, this.description, this.colorLabel, this.priority, this.startDate, this.dueDate, this.memberIds});
	Map<String, dynamic> toJson() => _$CreateProjectRequestToJson(this);
}

@JsonSerializable()
class UpdateProjectRequest {
	final String? name, description, colorLabel, status, priority;
	final DateTime? startDate, dueDate;
	const UpdateProjectRequest({this.name, this.description, this.colorLabel, this.startDate, this.dueDate, this.status, this.priority});
	Map<String, dynamic> toJson() => _$UpdateProjectRequestToJson(this);
}

@JsonSerializable()
class ProjectStatsResponse {
	final int totalTasks, todoTasks, inProgressTasks, reviewTasks, completedTasks;
	final double completionPercentage;
	const ProjectStatsResponse({required this.totalTasks, required this.todoTasks, required this.inProgressTasks, required this.reviewTasks, required this.completedTasks, required this.completionPercentage});
	factory ProjectStatsResponse.fromJson(Map<String, dynamic> j) => _$ProjectStatsResponseFromJson(j);
}

@JsonSerializable()
class InviteMemberRequest {
	final String emailOrPhone;
	final String? role;
	const InviteMemberRequest({required this.emailOrPhone, this.role});
	Map<String, dynamic> toJson() => _$InviteMemberRequestToJson(this);
}

@JsonSerializable()
class ChangeMemberRoleRequest {
	final String memberId;
	final String? role;
	const ChangeMemberRoleRequest({required this.memberId, this.role});
	Map<String, dynamic> toJson() => _$ChangeMemberRoleRequestToJson(this);
}

