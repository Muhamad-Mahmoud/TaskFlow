import 'package:json_annotation/json_annotation.dart';

part 'tag_models.g.dart';

@JsonSerializable()
class TagResponse {
  final String id, name, color;
  const TagResponse({required this.id, required this.name, required this.color});
  factory TagResponse.fromJson(Map<String, dynamic> j) => _$TagResponseFromJson(j);
}

@JsonSerializable()
class CreateTagRequest {
  final String name, color;
  const CreateTagRequest({required this.name, required this.color});
  Map<String, dynamic> toJson() => _$CreateTagRequestToJson(this);
}
