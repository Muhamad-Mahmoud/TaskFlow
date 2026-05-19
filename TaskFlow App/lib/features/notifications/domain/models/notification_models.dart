import 'package:json_annotation/json_annotation.dart';

part 'notification_models.g.dart';

@JsonSerializable()
class NotificationResponse {
  final String id, type, message;
  final bool isRead;
  final DateTime createdAt;
  const NotificationResponse({required this.id, required this.type, required this.message, required this.isRead, required this.createdAt});
  factory NotificationResponse.fromJson(Map<String, dynamic> j) => _$NotificationResponseFromJson(j);
}

@JsonSerializable()
class PushTokenRequest {
  final String token, platform, deviceId;
  const PushTokenRequest({required this.token, required this.platform, required this.deviceId});
  Map<String, dynamic> toJson() => _$PushTokenRequestToJson(this);
}
