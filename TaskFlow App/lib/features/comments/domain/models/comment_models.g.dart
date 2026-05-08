// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'comment_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CommentResponse _$CommentResponseFromJson(Map<String, dynamic> json) =>
    CommentResponse(
      id: json['id'] as String,
      content: json['content'] as String,
      authorId: json['authorId'] as String,
      authorName: json['authorName'] as String,
      authorAvatarUrl: json['authorAvatarUrl'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$CommentResponseToJson(CommentResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'content': instance.content,
      'authorId': instance.authorId,
      'authorName': instance.authorName,
      'authorAvatarUrl': instance.authorAvatarUrl,
      'createdAt': instance.createdAt.toIso8601String(),
    };

CreateCommentRequest _$CreateCommentRequestFromJson(
  Map<String, dynamic> json,
) => CreateCommentRequest(
  content: json['content'] as String,
  taskId: json['taskId'] as String,
);

Map<String, dynamic> _$CreateCommentRequestToJson(
  CreateCommentRequest instance,
) => <String, dynamic>{'content': instance.content, 'taskId': instance.taskId};
