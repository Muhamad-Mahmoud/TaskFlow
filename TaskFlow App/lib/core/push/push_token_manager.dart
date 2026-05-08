import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dio/dio.dart';

class PushTokenManager {
  final FlutterSecureStorage _storage;
  
  PushTokenManager(this._storage);

  Future<void> saveTokenLocally(String token) async {
    await _storage.write(key: 'fcm_token', value: token);
    await _storage.write(key: 'fcm_token_synced', value: 'false');
  }

  Future<void> syncTokenIfPending(Dio client) async {
    final syncedStr = await _storage.read(key: 'fcm_token_synced');
    final synced = syncedStr == 'true';
    if (synced) return;
    
    final token = await _storage.read(key: 'fcm_token');
    if (token == null) return;

    try {
      // Endpoint is missing in API spec, so we catch 404s gracefully
      await client.post('/api/v1/users/me/push-tokens', data: {'token': token});
      await _storage.write(key: 'fcm_token_synced', value: 'true');
    } on DioException catch (e) {
      if (e.response?.statusCode != 404) rethrow;
      // Backend not ready, silently fail
    }
  }
}

