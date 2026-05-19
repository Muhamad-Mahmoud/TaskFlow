// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tag_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TagResponse _$TagResponseFromJson(Map<String, dynamic> json) => TagResponse(
  id: json['id'] as String,
  name: json['name'] as String,
  color: json['color'] as String,
);

Map<String, dynamic> _$TagResponseToJson(TagResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'color': instance.color,
    };

CreateTagRequest _$CreateTagRequestFromJson(Map<String, dynamic> json) =>
    CreateTagRequest(
      name: json['name'] as String,
      color: json['color'] as String,
    );

Map<String, dynamic> _$CreateTagRequestToJson(CreateTagRequest instance) =>
    <String, dynamic>{'name': instance.name, 'color': instance.color};
