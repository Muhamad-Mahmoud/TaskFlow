import 'package:json_annotation/json_annotation.dart';

part 'auth_models.g.dart';

@JsonSerializable()
class RegisterRequest {
	final String fullName, email, password, confirmPassword;
	final String? avatarUrl;
	const RegisterRequest({
		required this.fullName, required this.email, required this.password,
		required this.confirmPassword, this.avatarUrl,
	});
	Map<String, dynamic> toJson() => _$RegisterRequestToJson(this);
}

@JsonSerializable()
class LoginRequest {
	final String email, password;
	const LoginRequest({required this.email, required this.password});
	Map<String, dynamic> toJson() => _$LoginRequestToJson(this);
}

@JsonSerializable()
class AuthResponse {
	@JsonKey(name: 'token') final String accessToken;
	final String? refreshToken;
	final DateTime expiresAt;
	final UserDto user;
	const AuthResponse({required this.accessToken, this.refreshToken, required this.expiresAt, required this.user});
	factory AuthResponse.fromJson(Map<String, dynamic> j) => _$AuthResponseFromJson(j);
}

@JsonSerializable()
class UserDto {
	final String id, fullName, email, role;
	final String? avatarUrl;
	const UserDto({required this.id, required this.fullName, required this.email, this.avatarUrl, required this.role});
	factory UserDto.fromJson(Map<String, dynamic> j) => _$UserDtoFromJson(j);
	Map<String, dynamic> toJson() => _$UserDtoToJson(this);
}
