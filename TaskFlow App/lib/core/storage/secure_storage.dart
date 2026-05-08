import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';
import '../../features/auth/domain/models/auth_models.dart';

@lazySingleton
class SecureStorage {
  final FlutterSecureStorage _storage;

  SecureStorage(this._storage);

  static const _tokenKey = 'access_token';
  static const _refreshKey = 'refresh_token';
  static const _userKey = 'user_data';

  Future<void> saveTokens(String accessToken, String? refreshToken) async {
    await _storage.write(key: _tokenKey, value: accessToken);
    if (refreshToken != null) {
      await _storage.write(key: _refreshKey, value: refreshToken);
    }
  }

  Future<void> saveUser(UserDto user) async {
    await _storage.write(key: _userKey, value: jsonEncode(user.toJson()));
  }

  Future<UserDto?> readUser() async {
    final data = await _storage.read(key: _userKey);
    if (data == null) return null;
    return UserDto.fromJson(jsonDecode(data) as Map<String, dynamic>);
  }

  Future<String?> readAccessToken() async {
    return await _storage.read(key: _tokenKey);
  }

  Future<String?> readRefreshToken() async {
    return await _storage.read(key: _refreshKey);
  }

  Future<void> clearTokens() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _refreshKey);
  }

  Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}

