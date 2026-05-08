import 'package:json_annotation/json_annotation.dart';

part 'task_models.g.dart';

@JsonSerializable()
class TaskSummary {
  final String id, title;
  final String status, priority;
  final String? assigneeName;
  final String projectName;
  final DateTime? dueDate;

  const TaskSummary({
    required this.id,
    required this.title,
    required this.status,
    required this.priority,
    this.assigneeName,
    required this.projectName,
    this.dueDate,
  });

  factory TaskSummary.fromJson(Map<String, dynamic> j) => _$TaskSummaryFromJson(j);
}

@JsonSerializable()
class TaskResponse {
  final String id, title;
  final String? description;
  final String status, priority;
  final DateTime? dueDate;
  final double? estimatedHours;
  final String projectId;
  final AssigneeBrief? assignee;
  final AssigneeBrief createdBy;
  final List<SubtaskResponse> subtasks;
  final List<TagBrief> tags;
  final int commentCount;
  final int attachmentCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  const TaskResponse({
    required this.id,
    required this.title,
    this.description,
    required this.status,
    required this.priority,
    this.dueDate,
    this.estimatedHours,
    required this.projectId,
    this.assignee,
    required this.createdBy,
    required this.subtasks,
    required this.tags,
    required this.commentCount,
    required this.attachmentCount,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TaskResponse.fromJson(Map<String, dynamic> j) => _$TaskResponseFromJson(j);
}

@JsonSerializable()
class AssigneeBrief {
  final String id, fullName;
  final String? avatarUrl;
  const AssigneeBrief({required this.id, required this.fullName, this.avatarUrl});
  factory AssigneeBrief.fromJson(Map<String, dynamic> j) => _$AssigneeBriefFromJson(j);
}

@JsonSerializable()
class SubtaskResponse {
  final String id, title;
  final bool isCompleted;
  final int position;
  const SubtaskResponse({required this.id, required this.title, required this.isCompleted, required this.position});
  factory SubtaskResponse.fromJson(Map<String, dynamic> j) => _$SubtaskResponseFromJson(j);
}

@JsonSerializable()
class TagBrief {
  final String id, name, color;
  const TagBrief({required this.id, required this.name, required this.color});
  factory TagBrief.fromJson(Map<String, dynamic> j) => _$TagBriefFromJson(j);
}

@JsonSerializable()
class CreateTaskRequest {
  final String title, projectId;
  final String? description, status, priority;
  final DateTime? dueDate;
  final double? estimatedHours;
  final String? assigneeId;

  const CreateTaskRequest({
    required this.title,
    required this.projectId,
    this.description,
    this.status = 'Todo',
    this.priority = 'Medium',
    this.dueDate,
    this.estimatedHours,
    this.assigneeId,
  });

  Map<String, dynamic> toJson() => _$CreateTaskRequestToJson(this);
}

@JsonSerializable()
class UpdateTaskRequest {
  final String? title, description, status, priority;
  final DateTime? dueDate;
  final double? estimatedHours;
  final String? assigneeId;
  const UpdateTaskRequest({this.title, this.description, this.status, this.priority, this.dueDate, this.estimatedHours, this.assigneeId});
  Map<String, dynamic> toJson() => _$UpdateTaskRequestToJson(this);
}
