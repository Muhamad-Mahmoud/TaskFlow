// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TaskSummary _$TaskSummaryFromJson(Map<String, dynamic> json) => TaskSummary(
  id: json['id'] as String,
  title: json['title'] as String,
  status: json['status'] as String,
  priority: json['priority'] as String,
  assigneeName: json['assigneeName'] as String?,
  projectName: json['projectName'] as String,
  dueDate: json['dueDate'] == null
      ? null
      : DateTime.parse(json['dueDate'] as String),
);

Map<String, dynamic> _$TaskSummaryToJson(TaskSummary instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'status': instance.status,
      'priority': instance.priority,
      'assigneeName': instance.assigneeName,
      'projectName': instance.projectName,
      'dueDate': instance.dueDate?.toIso8601String(),
    };

TaskResponse _$TaskResponseFromJson(Map<String, dynamic> json) => TaskResponse(
  id: json['id'] as String,
  title: json['title'] as String,
  description: json['description'] as String?,
  status: json['status'] as String,
  priority: json['priority'] as String,
  dueDate: json['dueDate'] == null
      ? null
      : DateTime.parse(json['dueDate'] as String),
  estimatedHours: (json['estimatedHours'] as num?)?.toDouble(),
  projectId: json['projectId'] as String,
  assignee: json['assignee'] == null
      ? null
      : AssigneeBrief.fromJson(json['assignee'] as Map<String, dynamic>),
  createdBy: AssigneeBrief.fromJson(json['createdBy'] as Map<String, dynamic>),
  subtasks: (json['subtasks'] as List<dynamic>)
      .map((e) => SubtaskResponse.fromJson(e as Map<String, dynamic>))
      .toList(),
  tags: (json['tags'] as List<dynamic>)
      .map((e) => TagBrief.fromJson(e as Map<String, dynamic>))
      .toList(),
  commentsCount: (json['commentsCount'] as num).toInt(),
  attachmentsCount: (json['attachmentsCount'] as num).toInt(),
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$TaskResponseToJson(TaskResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'status': instance.status,
      'priority': instance.priority,
      'dueDate': instance.dueDate?.toIso8601String(),
      'estimatedHours': instance.estimatedHours,
      'projectId': instance.projectId,
      'assignee': instance.assignee,
      'createdBy': instance.createdBy,
      'subtasks': instance.subtasks,
      'tags': instance.tags,
      'commentsCount': instance.commentsCount,
      'attachmentsCount': instance.attachmentsCount,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

AssigneeBrief _$AssigneeBriefFromJson(Map<String, dynamic> json) =>
    AssigneeBrief(
      id: json['id'] as String,
      fullName: json['fullName'] as String,
      avatarUrl: json['avatarUrl'] as String?,
    );

Map<String, dynamic> _$AssigneeBriefToJson(AssigneeBrief instance) =>
    <String, dynamic>{
      'id': instance.id,
      'fullName': instance.fullName,
      'avatarUrl': instance.avatarUrl,
    };

SubtaskResponse _$SubtaskResponseFromJson(Map<String, dynamic> json) =>
    SubtaskResponse(
      id: json['id'] as String,
      title: json['title'] as String,
      isCompleted: json['isCompleted'] as bool,
      position: (json['position'] as num).toInt(),
    );

Map<String, dynamic> _$SubtaskResponseToJson(SubtaskResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'isCompleted': instance.isCompleted,
      'position': instance.position,
    };

TagBrief _$TagBriefFromJson(Map<String, dynamic> json) => TagBrief(
  id: json['id'] as String,
  name: json['name'] as String,
  color: json['color'] as String,
);

Map<String, dynamic> _$TagBriefToJson(TagBrief instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'color': instance.color,
};

CreateTaskRequest _$CreateTaskRequestFromJson(Map<String, dynamic> json) =>
    CreateTaskRequest(
      title: json['title'] as String,
      projectId: json['projectId'] as String,
      description: json['description'] as String?,
      status: json['status'] as String? ?? 'Todo',
      priority: json['priority'] as String? ?? 'Medium',
      dueDate: json['dueDate'] == null
          ? null
          : DateTime.parse(json['dueDate'] as String),
      estimatedHours: (json['estimatedHours'] as num?)?.toDouble(),
      assigneeEmailOrPhone: json['assigneeEmailOrPhone'] as String?,
    );

Map<String, dynamic> _$CreateTaskRequestToJson(CreateTaskRequest instance) =>
    <String, dynamic>{
      'title': instance.title,
      'projectId': instance.projectId,
      'description': instance.description,
      'status': instance.status,
      'priority': instance.priority,
      'dueDate': instance.dueDate?.toIso8601String(),
      'estimatedHours': instance.estimatedHours,
      'assigneeEmailOrPhone': instance.assigneeEmailOrPhone,
    };

UpdateTaskRequest _$UpdateTaskRequestFromJson(Map<String, dynamic> json) =>
    UpdateTaskRequest(
      title: json['title'] as String?,
      description: json['description'] as String?,
      status: json['status'] as String?,
      priority: json['priority'] as String?,
      dueDate: json['dueDate'] == null
          ? null
          : DateTime.parse(json['dueDate'] as String),
      estimatedHours: (json['estimatedHours'] as num?)?.toDouble(),
      assigneeEmailOrPhone: json['assigneeEmailOrPhone'] as String?,
    );

Map<String, dynamic> _$UpdateTaskRequestToJson(UpdateTaskRequest instance) =>
    <String, dynamic>{
      'title': instance.title,
      'description': instance.description,
      'status': instance.status,
      'priority': instance.priority,
      'dueDate': instance.dueDate?.toIso8601String(),
      'estimatedHours': instance.estimatedHours,
      'assigneeEmailOrPhone': instance.assigneeEmailOrPhone,
    };
