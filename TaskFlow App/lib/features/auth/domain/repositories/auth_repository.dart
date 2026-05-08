import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../models/auth_models.dart';

abstract class AuthRepository {
	Future<Either<Failure, AuthResponse>> login(String email, String password);
	Future<Either<Failure, AuthResponse>> register(RegisterRequest req);
	Future<void> logout();
	Future<UserDto?> currentUser();
}

