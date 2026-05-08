import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../domain/models/auth_models.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/auth_usecases.dart';
import '../../../../core/error/failure.dart';

sealed class AuthEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class AuthCheckRequested extends AuthEvent {}

class LoginRequested extends AuthEvent {
  final String email, password;
  LoginRequested(this.email, this.password);
  @override
  List<Object?> get props => [email, password];
}

class RegisterRequested extends AuthEvent {
  final RegisterRequest req;
  RegisterRequested(this.req);
  @override
  List<Object?> get props => [req];
}

class LogoutRequested extends AuthEvent {}

sealed class AuthState extends Equatable {
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class Authenticated extends AuthState {
  final UserDto user;
  Authenticated(this.user);
  @override
  List<Object?> get props => [user.id];
}

class Unauthenticated extends AuthState {}

class AuthFailure extends AuthState {
  final String message;
  final List<String>? errors;
  AuthFailure(this.message, {this.errors});
  @override
  List<Object?> get props => [message, errors];
}

@injectable
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase login;
  final RegisterUseCase register;
  final LogoutUseCase logout;
  final AuthRepository repo;

  AuthBloc(this.login, this.register, this.logout, this.repo)
      : super(AuthInitial()) {
    on<AuthCheckRequested>(_onCheck);
    on<LoginRequested>(_onLogin);
    on<RegisterRequested>(_onRegister);
    on<LogoutRequested>(_onLogout);
  }

  Future<void> _onCheck(AuthCheckRequested event, Emitter<AuthState> emit) async {
    final u = await repo.currentUser();
    if (u != null) {
      emit(Authenticated(u));
    } else {
      emit(Unauthenticated());
    }
  }

  Future<void> _onLogin(LoginRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final r = await login(event.email, event.password);
    r.fold(
      (f) => emit(AuthFailure(f.message, errors: f is ServerFailure ? f.errors : null)),
      (a) => emit(Authenticated(a.user)),
    );
  }

  Future<void> _onRegister(
      RegisterRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final r = await register(event.req);
    r.fold(
      (f) => emit(AuthFailure(f.message)),
      (a) => emit(Authenticated(a.user)),
    );
  }

  Future<void> _onLogout(LogoutRequested event, Emitter<AuthState> emit) async {
    await logout();
    emit(Unauthenticated());
  }
}

