import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failure.dart';
import '../repositories/auth_repository.dart';
import '../models/auth_models.dart';

@injectable
class LoginUseCase {
	final AuthRepository repo;
	LoginUseCase(this.repo);
	Future<Either<Failure, AuthResponse>> call(String email, String password) => repo.login(email, password);
}

@injectable
class RegisterUseCase {
  final AuthRepository repo;
	RegisterUseCase(this.repo);
	Future<Either<Failure, AuthResponse>> call(RegisterRequest req) => repo.register(req);
}

@injectable
class LogoutUseCase {
	final AuthRepository repo;
	LogoutUseCase(this.repo);
	Future<void> call() => repo.logout();
}

@injectable
class GetCurrentUserUseCase {
  final AuthRepository repo;
  GetCurrentUserUseCase(this.repo);
  Future<UserDto?> call() => repo.currentUser();
}

