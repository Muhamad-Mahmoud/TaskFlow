// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'project_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProjectSummary _$ProjectSummaryFromJson(Map<String, dynamic> json) =>
    ProjectSummary(
      id: json['id'] as String,
      name: json['name'] as String,
      status: json['status'] as String?,
      completionPercentage: (json['completionPercentage'] as num).toDouble(),
      memberCount: (json['memberCount'] as num).toInt(),
      taskCount: (json['taskCount'] as num).toInt(),
    );

Map<String, dynamic> _$ProjectSummaryToJson(ProjectSummary instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'status': instance.status,
      'completionPercentage': instance.completionPercentage,
      'memberCount': instance.memberCount,
      'taskCount': instance.taskCount,
    };

ProjectMemberResponse _$ProjectMemberResponseFromJson(
  Map<String, dynamic> json,
) => ProjectMemberResponse(
  id: json['id'] as String,
  fullName: json['fullName'] as String,
  avatarUrl: json['avatarUrl'] as String?,
  role: json['role'] as String?,
);

Map<String, dynamic> _$ProjectMemberResponseToJson(
  ProjectMemberResponse instance,
) => <String, dynamic>{
  'id': instance.id,
  'fullName': instance.fullName,
  'avatarUrl': instance.avatarUrl,
  'role': instance.role,
};

ProjectResponse _$ProjectResponseFromJson(Map<String, dynamic> json) =>
    ProjectResponse(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      status: json['status'] as String?,
      priority: json['priority'] as String?,
      completionPercentage: (json['completionPercentage'] as num).toDouble(),
      colorLabel: json['colorLabel'] as String?,
      startDate: json['startDate'] == null
          ? null
          : DateTime.parse(json['startDate'] as String),
      dueDate: json['dueDate'] == null
          ? null
          : DateTime.parse(json['dueDate'] as String),
      members: (json['members'] as List<dynamic>?)
          ?.map(
            (e) => ProjectMemberResponse.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$ProjectResponseToJson(ProjectResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'status': instance.status,
      'priority': instance.priority,
      'colorLabel': instance.colorLabel,
      'completionPercentage': instance.completionPercentage,
      'startDate': instance.startDate?.toIso8601String(),
      'dueDate': instance.dueDate?.toIso8601String(),
      'members': instance.members,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

CreateProjectRequest _$CreateProjectRequestFromJson(
  Map<String, dynamic> json,
) => CreateProjectRequest(
  name: json['name'] as String?,
  description: json['description'] as String?,
  colorLabel: json['colorLabel'] as String?,
  priority: json['priority'] as String?,
  startDate: json['startDate'] == null
      ? null
      : DateTime.parse(json['startDate'] as String),
  dueDate: json['dueDate'] == null
      ? null
      : DateTime.parse(json['dueDate'] as String),
  memberIds: (json['memberIds'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
);

Map<String, dynamic> _$CreateProjectRequestToJson(
  CreateProjectRequest instance,
) => <String, dynamic>{
  'name': instance.name,
  'description': instance.description,
  'colorLabel': instance.colorLabel,
  'priority': instance.priority,
  'startDate': instance.startDate?.toIso8601String(),
  'dueDate': instance.dueDate?.toIso8601String(),
  'memberIds': instance.memberIds,
};

UpdateProjectRequest _$UpdateProjectRequestFromJson(
  Map<String, dynamic> json,
) => UpdateProjectRequest(
  name: json['name'] as String?,
  description: json['description'] as String?,
  colorLabel: json['colorLabel'] as String?,
  startDate: json['startDate'] == null
      ? null
      : DateTime.parse(json['startDate'] as String),
  dueDate: json['dueDate'] == null
      ? null
      : DateTime.parse(json['dueDate'] as String),
  status: json['status'] as String?,
  priority: json['priority'] as String?,
);

Map<String, dynamic> _$UpdateProjectRequestToJson(
  UpdateProjectRequest instance,
) => <String, dynamic>{
  'name': instance.name,
  'description': instance.description,
  'colorLabel': instance.colorLabel,
  'status': instance.status,
  'priority': instance.priority,
  'startDate': instance.startDate?.toIso8601String(),
  'dueDate': instance.dueDate?.toIso8601String(),
};

ProjectStatsResponse _$ProjectStatsResponseFromJson(
  Map<String, dynamic> json,
) => ProjectStatsResponse(
  totalTasks: (json['totalTasks'] as num).toInt(),
  todoTasks: (json['todoTasks'] as num).toInt(),
  inProgressTasks: (json['inProgressTasks'] as num).toInt(),
  reviewTasks: (json['reviewTasks'] as num).toInt(),
  completedTasks: (json['completedTasks'] as num).toInt(),
  completionPercentage: (json['completionPercentage'] as num).toDouble(),
);

Map<String, dynamic> _$ProjectStatsResponseToJson(
  ProjectStatsResponse instance,
) => <String, dynamic>{
  'totalTasks': instance.totalTasks,
  'todoTasks': instance.todoTasks,
  'inProgressTasks': instance.inProgressTasks,
  'reviewTasks': instance.reviewTasks,
  'completedTasks': instance.completedTasks,
  'completionPercentage': instance.completionPercentage,
};

InviteMemberRequest _$InviteMemberRequestFromJson(Map<String, dynamic> json) =>
    InviteMemberRequest(
      emailOrPhone: json['emailOrPhone'] as String,
      role: json['role'] as String?,
    );

Map<String, dynamic> _$InviteMemberRequestToJson(
  InviteMemberRequest instance,
) => <String, dynamic>{
  'emailOrPhone': instance.emailOrPhone,
  'role': instance.role,
};

ChangeMemberRoleRequest _$ChangeMemberRoleRequestFromJson(
  Map<String, dynamic> json,
) => ChangeMemberRoleRequest(
  memberId: json['memberId'] as String,
  role: json['role'] as String?,
);

Map<String, dynamic> _$ChangeMemberRoleRequestToJson(
  ChangeMemberRoleRequest instance,
) => <String, dynamic>{'memberId': instance.memberId, 'role': instance.role};
