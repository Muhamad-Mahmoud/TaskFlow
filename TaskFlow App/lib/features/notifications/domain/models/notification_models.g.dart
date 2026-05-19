// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NotificationResponse _$NotificationResponseFromJson(
  Map<String, dynamic> json,
) => NotificationResponse(
  id: json['id'] as String,
  type: json['type'] as String,
  message: json['message'] as String,
  isRead: json['isRead'] as bool,
  createdAt: DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$NotificationResponseToJson(
  NotificationResponse instance,
) => <String, dynamic>{
  'id': instance.id,
  'type': instance.type,
  'message': instance.message,
  'isRead': instance.isRead,
  'createdAt': instance.createdAt.toIso8601String(),
};

PushTokenRequest _$PushTokenRequestFromJson(Map<String, dynamic> json) =>
    PushTokenRequest(
      token: json['token'] as String,
      platform: json['platform'] as String,
      deviceId: json['deviceId'] as String,
    );

Map<String, dynamic> _$PushTokenRequestToJson(PushTokenRequest instance) =>
    <String, dynamic>{
      'token': instance.token,
      'platform': instance.platform,
      'deviceId': instance.deviceId,
    };
