import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/constants/api_paths.dart';
import '../../../../core/network/api_response.dart';
import '../../../../core/network/dio_extensions.dart';
import '../../domain/models/notification_models.dart';

@injectable
class NotificationsRemoteDataSource {
	final Dio dio;
	NotificationsRemoteDataSource(this.dio);

	Future<PagedResult<NotificationResponse>> list({int page = 1, int pageSize = 20}) =>
			dio.getData(ApiPaths.notifications,
				(j) => PagedResult<NotificationResponse>.fromJson(j as Map<String, dynamic>,
					(p) => NotificationResponse.fromJson(p as Map<String, dynamic>)),
				query: {'page': page, 'pageSize': pageSize});

	Future<void> markAsRead(String id) => dio.patchOk(ApiPaths.notificationRead(id));

	Future<void> markAllAsRead() => dio.postOk(ApiPaths.notificationsReadAll);

	Future<void> delete(String id) => dio.deleteOk(ApiPaths.notification(id));

	Future<void> pushToken(PushTokenRequest r) => dio.postOk(ApiPaths.notificationsPushToken, data: r.toJson());
}
