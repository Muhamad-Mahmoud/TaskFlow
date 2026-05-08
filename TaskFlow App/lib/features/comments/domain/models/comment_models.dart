import 'package:json_annotation/json_annotation.dart';

part 'comment_models.g.dart';

@JsonSerializable()
class CommentResponse {
	final String id, content;
	final String authorId, authorName;
	final String? authorAvatarUrl;
	final DateTime createdAt;

	const CommentResponse({
		required this.id, required this.content, required this.authorId,
		required this.authorName, this.authorAvatarUrl, required this.createdAt,
	});

	factory CommentResponse.fromJson(Map<String, dynamic> j) => _$CommentResponseFromJson(j);
}

@JsonSerializable()
class CreateCommentRequest {
	final String content, taskId;
	const CreateCommentRequest({required this.content, required this.taskId});
	Map<String, dynamic> toJson() => _$CreateCommentRequestToJson(this);
}
