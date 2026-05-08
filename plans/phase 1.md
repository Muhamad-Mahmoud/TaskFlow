# Task-Flow Flutter Integration Plan — Mapped to Live API (v1)

<aside>
📱

**Detailed Flutter integration plan** built directly from your live `TaskFlow API` OpenAPI spec. Every endpoint, DTO, and wrapper shape below matches what the backend actually exposes. Discrepancies between the original Figma plan and the deployed API are flagged so you know what to add or drop.

</aside>

## 0. Critical Differences From Original Flutter Doc

<aside>
⚠️

Read this first. Several endpoints from the original architecture doc were **not implemented** in the API. You must remove their UI flows from Flutter or add them to the backend before Phase 2.

</aside>

| **Original plan said** | **API actually has** | **Action** |
| --- | --- | --- |
| `{ data, meta, error }` envelope | `{ succeeded, message, errors[], data }` | Use `ApiResponse<T>` model below |
| `AuthResponse.accessToken` | `AuthResponse.token` | Map JSON `token` → Dart `accessToken` |
| `/auth/logout`, `/auth/refresh` | ❌ Not in spec | Client-side logout only; no refresh flow yet |
| `/auth/forgot-password`, `verify-otp`, `reset-password` | ❌ Not in spec | Hide ForgotPassword screen until backend ships them |
| `GET /tasks` global list | ❌ Only `GET /projects/{id}/tasks` | Aggregate per-project, OR add to backend |
| `PUT /tasks/{id}/comments/{cid}` edit | ❌ Only DELETE | Hide "edit comment" UI |
| `DELETE /projects/{id}/attachments/{aid}` | ❌ Only on tasks | Project attachments are upload-only |
| `DELETE /users/me` | ❌ Not in spec | Hide "Delete account" tile |
| `?page=&limit=` | `?page=&pageSize=` | Use `pageSize` everywhere |
| `status` / `priority` / `role` enums | Plain strings on the wire | Dart enum + `toApi()` / `fromApi()` |

## 1. Full Endpoint Map (Live)

| **Tag** | **Method + Path** | **Request** | **Response `data`** |
| --- | --- | --- | --- |
| Auth | `POST /api/v1/Auth/register` | `RegisterRequest` | `AuthResponse` |
| Auth | `POST /api/v1/Auth/login` | `LoginRequest` | `AuthResponse` |
| Users | `GET /api/v1/users/me` | — | `UserResponse` |
| Users | `PUT /api/v1/users/me` | `UpdateUserRequest` | `UserResponse` |
| Users | `GET /api/v1/users/me/stats` | — | `UserStatsResponse` |
| Users | `POST /api/v1/users/me/avatar` | multipart `file` | `AvatarResponse` |
| Users | `GET /api/v1/users/search?q=` | — | `List<UserSummary>` |
| Projects | `GET /api/v1/projects?page=&pageSize=` | — | `PagedResult<ProjectSummary>` |
| Projects | `POST /api/v1/projects` | `CreateProjectRequest` | `ProjectResponse` |
| Projects | `GET /api/v1/projects/{id}` | — | `ProjectResponse` |
| Projects | `PUT /api/v1/projects/{id}` | `UpdateProjectRequest` | `ProjectResponse` |
| Projects | `DELETE /api/v1/projects/{id}` | — | `object` |
| Projects | `GET /api/v1/projects/{id}/stats` | — | `ProjectStatsResponse` |
| Projects | `POST /api/v1/projects/{id}/members` | `InviteMemberRequest` | `ProjectMemberResponse` |
| Projects | `PATCH /api/v1/projects/{id}/members/{userId}` | `ChangeMemberRoleRequest` | `ProjectMemberResponse` |
| Projects | `DELETE /api/v1/projects/{id}/members/{userId}` | — | `object` |
| Tasks | `GET /api/v1/projects/{projectId}/tasks` | — | `List<TaskSummary>` |
| Tasks | `POST /api/v1/tasks` | `CreateTaskRequest` | `TaskDetailResponse` |
| Tasks | `GET /api/v1/tasks/{id}` | — | `TaskDetailResponse` |
| Tasks | `PUT /api/v1/tasks/{id}` | `UpdateTaskRequest` | `TaskResponse` |
| Tasks | `DELETE /api/v1/tasks/{id}` | — | `object` |
| Tasks | `PATCH /api/v1/tasks/{id}/status` | `UpdateStatusRequest` | `object` |
| Tasks | `PATCH /api/v1/tasks/{id}/position` | `ReorderTaskRequest` | `object` |
| Tasks | `POST /api/v1/tasks/{id}/subtasks` | `CreateSubtaskRequest` | `SubtaskResponse` |
| Tasks | `PATCH /api/v1/tasks/{id}/subtasks/{sid}` | `UpdateSubtaskRequest` | `SubtaskResponse` |
| Tasks | `DELETE /api/v1/tasks/{id}/subtasks/{sid}` | — | `object` |
| Comments | `GET /api/v1/tasks/{taskId}/comments` | — | `List<CommentResponse>` |
| Comments | `POST /api/v1/tasks/{taskId}/comments` | `CreateCommentRequest` | `CommentResponse` |
| Comments | `DELETE /api/v1/tasks/{taskId}/comments/{cid}` | — | `object` |
| Tags | `GET /api/v1/tags` | — | `List<TagResponse>` |
| Tags | `POST /api/v1/tags` | `CreateTagRequest` | `TagResponse` |
| Tags | `DELETE /api/v1/tags/{id}` | — | `object` |
| Notifs | `GET /api/v1/notifications?page=&pageSize=` | — | `PagedResult<NotificationResponse>` |
| Notifs | `PATCH /api/v1/notifications/{id}/read` | — | `object` |
| Notifs | `POST /api/v1/notifications/read-all` | — | `object` |
| Notifs | `DELETE /api/v1/notifications/{id}` | — | `object` |
| Notifs | `POST /api/v1/notifications/push-token` | `RegisterPushTokenRequest` | `object` |
| Files | `GET /api/v1/projects/{projectId}/attachments` | — | `List<AttachmentResponse>` |
| Files | `POST /api/v1/projects/{projectId}/attachments` | multipart `file` | `AttachmentResponse` |
| Files | `GET /api/v1/tasks/{taskId}/attachments` | — | `List<AttachmentResponse>` |
| Files | `POST /api/v1/tasks/{taskId}/attachments` | multipart `file` | `AttachmentResponse` |
| Files | `DELETE /api/v1/tasks/{taskId}/attachments/{aid}` | — | `object` |

## 2. pubspec.yaml — Locked Versions

```yaml
name: taskflow
description: Task-Flow collaborative task management
publish_to: 'none'
version: 1.0.0+1

environment:
	sdk: '>=3.5.0 <4.0.0'
	flutter: '>=3.24.0'

dependencies:
	flutter:
		sdk: flutter
	cupertino_icons: ^1.0.8

	# State + routing
	flutter_bloc: ^8.1.6
	bloc_concurrency: ^0.2.5
	equatable: ^2.0.5
	go_router: ^14.6.2

	# Network
	dio: ^5.7.0
	pretty_dio_logger: ^1.4.0

	# Storage
	flutter_secure_storage: ^9.2.2
	hive_flutter: ^1.1.0

	# DI / FP
	get_it: ^8.0.3
	injectable: ^2.5.0
	dartz: ^0.10.1

	# UI
	flutter_animate: ^4.5.0
	flutter_svg: ^2.0.10+1
	cached_network_image: ^3.4.1
	shimmer: ^3.0.0
	pin_code_fields: ^8.0.1
	flutter_colorpicker: ^1.1.0
	omni_datetime_picker: ^2.0.6

	# Files
	image_picker: ^1.1.2
	image_cropper: ^8.0.2
	file_picker: ^8.1.4
	open_filex: ^4.5.0
	permission_handler: ^11.3.1

	# Firebase / FCM
	firebase_core: ^3.6.0
	firebase_messaging: ^15.1.3
	flutter_local_notifications: ^17.2.4
	firebase_crashlytics: ^4.1.3

	# Misc
	connectivity_plus: ^6.1.0
	rxdart: ^0.28.0
	intl: ^0.19.0
	json_annotation: ^4.9.0

dev_dependencies:
	flutter_test:
		sdk: flutter
	integration_test:
		sdk: flutter
	flutter_lints: ^5.0.0
	build_runner: ^2.4.13
	json_serializable: ^6.8.0
	injectable_generator: ^2.6.2
	hive_generator: ^2.0.1
	mocktail: ^1.0.4
	bloc_test: ^9.1.7
```

## 3. Project Structure

```jsx
lib/
├── main.dart
├── app.dart
│
├── core/
│	├── config/app_config.dart
│	├── constants/{api_paths,app_colors,app_text_styles,app_spacing}.dart
│	├── theme/app_theme.dart
│	├── router/{app_router,route_names,auth_redirect}.dart
│	├── network/{dio_client,auth_interceptor,error_interceptor,api_response}.dart
│	├── error/{failure,exceptions,error_mapper}.dart
│	├── storage/{secure_storage,hive_boxes}.dart
│	├── utils/{validators,date_utils,extensions,logger}.dart
│	└── di/injection.dart
│
├── features/
│	├── auth/         { data, domain, presentation }
│	├── users/        { data, domain, presentation }
│	├── projects/     { data, domain, presentation }
│	├── tasks/        { data, domain, presentation }
│	├── comments/     { data, domain, presentation }
│	├── tags/         { data, domain, presentation }
│	├── attachments/  { data, domain, presentation }
│	├── notifications/{ data, domain, presentation }
│	└── dashboard/    { data, domain, presentation }
│
└── shared/
	├── enums/{task_status,task_priority,project_status,project_member_role,notification_type}.dart
	├── models/{assignee_brief,tag_brief,user_dto}.dart
	└── widgets/{app_button,app_text_field,app_dialog,empty_state,error_view,shimmer_loader,deadline_chip,priority_badge,status_badge,avatar_widget}.dart
```

Each feature folder:

```jsx
features/<name>/
├── data/
│	├── datasources/<name>_remote_ds.dart
│	├── models/...                # JSON DTOs
│	└── repositories/<name>_repository_impl.dart
├── domain/
│	├── entities/...
│	├── repositories/<name>_repository.dart
│	└── usecases/...
└── presentation/
	├── bloc/
	├── pages/
	└── widgets/
```

## 4. Core Layer

### 4.1 `core/network/api_response.dart`

Mirrors the server wrapper exactly.

```csharp
import 'package:json_annotation/json_annotation.dart';
part 'api_response.g.dart';

@JsonSerializable(genericArgumentFactories: true)
class ApiResponse<T> {
	final bool succeeded;
	final String? message;
	final List<String>? errors;
	final T? data;

	const ApiResponse({required this.succeeded, this.message, this.errors, this.data});

	factory ApiResponse.fromJson(Map<String, dynamic> json, T Function(Object?) fromJsonT) =>
			_$ApiResponseFromJson(json, fromJsonT);
}

@JsonSerializable(genericArgumentFactories: true)
class PagedResult<T> {
	final List<T> items;
	final int pageNumber;
	final int pageSize;
	final int totalPages;
	final int totalCount;
	final bool hasPreviousPage;
	final bool hasNextPage;
	final int page;

	const PagedResult({
		required this.items, required this.pageNumber, required this.pageSize,
		required this.totalPages, required this.totalCount,
		required this.hasPreviousPage, required this.hasNextPage, required this.page,
	});

	factory PagedResult.fromJson(Map<String, dynamic> json, T Function(Object?) fromJsonT) =>
			_$PagedResultFromJson(json, fromJsonT);
}
```

### 4.2 `core/network/dio_client.dart`

```csharp
class DioClient {
	static Dio create(AppConfig config, AuthInterceptor authInterceptor) {
		final dio = Dio(BaseOptions(
			baseUrl: config.baseUrl,
			connectTimeout: const Duration(seconds: 15),
			receiveTimeout: const Duration(seconds: 20),
			headers: {'Accept': 'application/json'},
		));
		dio.interceptors.addAll([
			authInterceptor,
			ErrorInterceptor(),
			if (config.enableLogs)
				PrettyDioLogger(requestBody: true, responseBody: true, compact: true),
		]);
		return dio;
	}
}
```

### 4.3 `core/network/auth_interceptor.dart`

<aside>
⚠️

Backend has no `/auth/refresh` yet — on 401 we **log out** instead of refreshing. When refresh ships, swap in a `_tryRefresh()` step before logout.

</aside>

```csharp
class AuthInterceptor extends Interceptor {
	final SecureStorage storage;
	final AuthEventBus bus;
	AuthInterceptor(this.storage, this.bus);

	@override
	Future<void> onRequest(opt, handler) async {
		final token = await storage.readAccessToken();
		if (token != null) opt.headers['Authorization'] = 'Bearer $token';
		handler.next(opt);
	}

	@override
	Future<void> onError(err, handler) async {
		if (err.response?.statusCode == 401) {
			await storage.clearTokens();
			bus.emit(AuthEvent.loggedOut);
		}
		handler.next(err);
	}
}
```

### 4.4 `core/error/error_mapper.dart`

```csharp
class ErrorMapper {
	static Failure fromDio(DioException e) {
		final data = e.response?.data;
		if (data is Map<String, dynamic>) {
			final succeeded = data['succeeded'] == true;
			final msg = data['message'] as String?;
			final errs = (data['errors'] as List?)?.cast<String>();
			if (!succeeded) return ServerFailure(msg ?? 'Request failed', errors: errs);
		}
		switch (e.type) {
			case DioExceptionType.connectionTimeout:
			case DioExceptionType.receiveTimeout:
				return const NetworkFailure('Connection timed out');
			case DioExceptionType.connectionError:
				return const NetworkFailure('No internet connection');
			default:
				return ServerFailure(e.message ?? 'Unexpected error');
		}
	}
}
```

### 4.5 Generic envelope helpers

```csharp
extension DioApi on Dio {
	Future<T> getData<T>(String path, T Function(Object?) fromT, {Map<String, dynamic>? query}) async {
		final r = await get(path, queryParameters: query);
		final env = ApiResponse<T>.fromJson(r.data as Map<String, dynamic>, fromT);
		if (!env.succeeded || env.data == null) {
			throw ServerFailure(env.message ?? 'Failed', errors: env.errors);
		}
		return env.data as T;
	}

	Future<T> postData<T>(String path, Object? body, T Function(Object?) fromT) async {
		final r = await post(path, data: body);
		final env = ApiResponse<T>.fromJson(r.data as Map<String, dynamic>, fromT);
		if (!env.succeeded || env.data == null) {
			throw ServerFailure(env.message ?? 'Failed', errors: env.errors);
		}
		return env.data as T;
	}

	Future<void> deleteOk(String path) async {
		final r = await delete(path);
		final env = ApiResponse<dynamic>.fromJson(
			r.data as Map<String, dynamic>, (j) => j);
		if (!env.succeeded) {
			throw ServerFailure(env.message ?? 'Delete failed', errors: env.errors);
		}
	}
}
```

### 4.6 Enums (`shared/enums/`)

```csharp
enum TaskStatus { todo, inProgress, review, done;
	String toApi() => switch (this) {
		TaskStatus.todo => 'Todo',
		TaskStatus.inProgress => 'InProgress',
		TaskStatus.review => 'Review',
		TaskStatus.done => 'Done',
	};
	static TaskStatus fromApi(String? s) => switch (s) {
		'Todo' => TaskStatus.todo,
		'InProgress' => TaskStatus.inProgress,
		'Review' => TaskStatus.review,
		'Done' => TaskStatus.done,
		_ => TaskStatus.todo,
	};
}

enum TaskPriority { low, medium, high, critical;
	String toApi() => name[0].toUpperCase() + name.substring(1);
	static TaskPriority fromApi(String? s) =>
			TaskPriority.values.firstWhere(
				(e) => e.name.toLowerCase() == (s ?? 'medium').toLowerCase(),
				orElse: () => TaskPriority.medium);
}

enum ProjectStatus { active, archived, completed }
enum ProjectMemberRole { owner, editor, viewer }
enum NotificationType { taskAssigned, taskDue, commentAdded, projectInvite, statusChanged }
```

### 4.7 `core/constants/api_paths.dart`

```csharp
class ApiPaths {
	static const auth = '/api/v1/Auth';
	static const usersMe = '/api/v1/users/me';
	static const usersSearch = '/api/v1/users/search';
	static const projects = '/api/v1/projects';
	static String project(String id) => '$projects/$id';
	static String projectStats(String id) => '$projects/$id/stats';
	static String projectMembers(String id) => '$projects/$id/members';
	static String projectMember(String id, String uid) => '$projects/$id/members/$uid';
	static String projectTasks(String id) => '$projects/$id/tasks';
	static String projectAttachments(String id) => '$projects/$id/attachments';
	static const tasks = '/api/v1/tasks';
	static String task(String id) => '$tasks/$id';
	static String taskStatus(String id) => '$tasks/$id/status';
	static String taskPosition(String id) => '$tasks/$id/position';
	static String subtasks(String id) => '$tasks/$id/subtasks';
	static String subtask(String id, String sid) => '$tasks/$id/subtasks/$sid';
	static String comments(String id) => '$tasks/$id/comments';
	static String comment(String id, String cid) => '$tasks/$id/comments/$cid';
	static String taskAttachments(String id) => '$tasks/$id/attachments';
	static String taskAttachment(String id, String aid) => '$tasks/$id/attachments/$aid';
	static const tags = '/api/v1/tags';
	static String tag(String id) => '$tags/$id';
	static const notifications = '/api/v1/notifications';
	static String notification(String id) => '$notifications/$id';
	static String notificationRead(String id) => '$notifications/$id/read';
	static const notificationsReadAll = '$notifications/read-all';
	static const notificationsPushToken = '$notifications/push-token';
}
```

## 5. Feature: Auth

### 5.1 Models — `features/auth/data/models/`

```csharp
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
}
```

### 5.2 Remote DataSource

```csharp
class AuthRemoteDataSource {
	final Dio dio;
	AuthRemoteDataSource(this.dio);

	Future<AuthResponse> register(RegisterRequest r) =>
			dio.postData('${ApiPaths.auth}/register', r.toJson(), (j) => AuthResponse.fromJson(j as Map<String, dynamic>));

	Future<AuthResponse> login(LoginRequest r) =>
			dio.postData('${ApiPaths.auth}/login', r.toJson(), (j) => AuthResponse.fromJson(j as Map<String, dynamic>));
}
```

### 5.3 Repository + UseCases

```csharp
abstract class AuthRepository {
	Future<Either<Failure, AuthResponse>> login(String email, String password);
	Future<Either<Failure, AuthResponse>> register(RegisterRequest req);
	Future<void> logout();
	Future<UserDto?> currentUser();
}

class AuthRepositoryImpl implements AuthRepository {
	final AuthRemoteDataSource remote;
	final SecureStorage storage;
	AuthRepositoryImpl(this.remote, this.storage);

	@override
	Future<Either<Failure, AuthResponse>> login(String e, String p) async {
		try {
			final res = await remote.login(LoginRequest(email: e, password: p));
			await storage.saveTokens(res.accessToken, res.refreshToken);
			await storage.saveUser(res.user);
			return Right(res);
		} on DioException catch (e) { return Left(ErrorMapper.fromDio(e)); }
		catch (e) { return Left(ServerFailure(e.toString())); }
	}

	@override
	Future<Either<Failure, AuthResponse>> register(RegisterRequest req) async {
		try {
			final res = await remote.register(req);
			await storage.saveTokens(res.accessToken, res.refreshToken);
			await storage.saveUser(res.user);
			return Right(res);
		} on DioException catch (e) { return Left(ErrorMapper.fromDio(e)); }
		catch (e) { return Left(ServerFailure(e.toString())); }
	}

	@override Future<void> logout() => storage.clearAll();
	@override Future<UserDto?> currentUser() => storage.readUser();
}

class LoginUseCase {
	final AuthRepository repo;
	LoginUseCase(this.repo);
	Future<Either<Failure, AuthResponse>> call(String email, String password) => repo.login(email, password);
}
class RegisterUseCase { /* same shape */ }
class LogoutUseCase {
	final AuthRepository repo;
	LogoutUseCase(this.repo);
	Future<void> call() => repo.logout();
}
```

### 5.4 BLoC

```csharp
sealed class AuthEvent {}
class AuthCheckRequested extends AuthEvent {}
class LoginRequested extends AuthEvent { final String email, password; LoginRequested(this.email, this.password); }
class RegisterRequested extends AuthEvent { final RegisterRequest req; RegisterRequested(this.req); }
class LogoutRequested extends AuthEvent {}

sealed class AuthState extends Equatable {}
class AuthInitial extends AuthState { @override List<Object?> get props => []; }
class AuthLoading extends AuthState { @override List<Object?> get props => []; }
class Authenticated extends AuthState { final UserDto user; Authenticated(this.user); @override List<Object?> get props => [user.id]; }
class Unauthenticated extends AuthState { @override List<Object?> get props => []; }
class AuthFailure extends AuthState { final String message; AuthFailure(this.message); @override List<Object?> get props => [message]; }

class AuthBloc extends Bloc<AuthEvent, AuthState> {
	final LoginUseCase login;
	final RegisterUseCase register;
	final LogoutUseCase logout;
	final AuthRepository repo;

	AuthBloc(this.login, this.register, this.logout, this.repo) : super(AuthInitial()) {
		on<AuthCheckRequested>(_onCheck);
		on<LoginRequested>(_onLogin);
		on<RegisterRequested>(_onRegister);
		on<LogoutRequested>(_onLogout);
	}

	Future<void> _onCheck(_, emit) async {
		final u = await repo.currentUser();
		emit(u != null ? Authenticated(u) : Unauthenticated());
	}

	Future<void> _onLogin(LoginRequested e, emit) async {
		emit(AuthLoading());
		final r = await login(e.email, e.password);
		r.fold((f) => emit(AuthFailure(f.message)), (a) => emit(Authenticated(a.user)));
	}

	Future<void> _onRegister(RegisterRequested e, emit) async {
		emit(AuthLoading());
		final r = await register(e.req);
		r.fold((f) => emit(AuthFailure(f.message)), (a) => emit(Authenticated(a.user)));
	}

	Future<void> _onLogout(_, emit) async { await logout(); emit(Unauthenticated()); }
}
```

### 5.5 Pages

- **`SplashPage`** — dispatches `AuthCheckRequested`, redirects to `/login` or `/app/home`.
- **`OnboardingPage`** — 3-slide PageView, persists `onboardingDone` in Hive.
- **`LoginPage`** — `email` + `password` form, validators, `LoginRequested`.
- **`RegisterPage`** — `fullName`, `email`, `password`, `confirmPassword`, optional `avatarUrl`. **Note:** server has no `role` field on register.
- **`ForgotPasswordPage`** — keep UI ready, but disabled/hidden until backend ships those endpoints.

## 6. Feature: Users

### 6.1 Models

```csharp
@JsonSerializable()
class UserResponse {
	final String id, fullName, email, role;
	final String? avatarUrl;
	final DateTime createdAt, updatedAt;
	const UserResponse({required this.id, required this.fullName, required this.email, required this.role, this.avatarUrl, required this.createdAt, required this.updatedAt});
	factory UserResponse.fromJson(Map<String, dynamic> j) => _$UserResponseFromJson(j);
}

@JsonSerializable()
class UpdateUserRequest {
	final String? fullName, avatarUrl;
	const UpdateUserRequest({this.fullName, this.avatarUrl});
	Map<String, dynamic> toJson() => _$UpdateUserRequestToJson(this);
}

@JsonSerializable()
class UserStatsResponse {
	final int completedTasks, totalTasks, totalProjects, todoTasks;
	final double completionPercentage;
	const UserStatsResponse({required this.completedTasks, required this.totalTasks, required this.completionPercentage, required this.totalProjects, required this.todoTasks});
	factory UserStatsResponse.fromJson(Map<String, dynamic> j) => _$UserStatsResponseFromJson(j);
}

@JsonSerializable()
class AvatarResponse {
	final String? url;
	const AvatarResponse({this.url});
	factory AvatarResponse.fromJson(Map<String, dynamic> j) => _$AvatarResponseFromJson(j);
}

@JsonSerializable()
class UserSummary {
	final String id, fullName, email;
	final String? avatarUrl;
	const UserSummary({required this.id, required this.fullName, required this.email, this.avatarUrl});
	factory UserSummary.fromJson(Map<String, dynamic> j) => _$UserSummaryFromJson(j);
}
```

### 6.2 Remote DataSource

```csharp
class UsersRemoteDataSource {
	final Dio dio;
	UsersRemoteDataSource(this.dio);

	Future<UserResponse> me() =>
			dio.getData(ApiPaths.usersMe, (j) => UserResponse.fromJson(j as Map<String, dynamic>));

	Future<UserResponse> update(UpdateUserRequest r) =>
			dio.putData(ApiPaths.usersMe, r.toJson(), (j) => UserResponse.fromJson(j as Map<String, dynamic>));

	Future<UserStatsResponse> stats() =>
			dio.getData('${ApiPaths.usersMe}/stats', (j) => UserStatsResponse.fromJson(j as Map<String, dynamic>));

	Future<AvatarResponse> uploadAvatar(File file) async {
		final form = FormData.fromMap({'file': await MultipartFile.fromFile(file.path)});
		final r = await dio.post('${ApiPaths.usersMe}/avatar', data: form);
		final env = ApiResponse<AvatarResponse>.fromJson(r.data, (j) => AvatarResponse.fromJson(j as Map<String, dynamic>));
		if (!env.succeeded || env.data == null) throw ServerFailure(env.message ?? 'Upload failed');
		return env.data!;
	}

	Future<List<UserSummary>> search(String q) =>
			dio.getData(ApiPaths.usersSearch,
				(j) => (j as List).map((e) => UserSummary.fromJson(e as Map<String, dynamic>)).toList(),
				query: {'q': q});
}
```

### 6.3 ProfileBloc / Pages

- `ProfilePage` — avatar uploader, stats cards (`completedTasks`/`totalTasks`/`totalProjects`), settings tiles (theme toggle, notifications toggle, logout).
- `EditProfileModal` — `fullName` text, avatar picker → cropper → upload → patch user.

## 7. Feature: Projects

### 7.1 Models

```csharp
@JsonSerializable()
class ProjectSummary {
	final String id, name;
	final String? status;
	final double completionPercentage;
	final int memberCount, taskCount;
	const ProjectSummary({required this.id, required this.name, this.status, required this.completionPercentage, required this.memberCount, required this.taskCount});
	factory ProjectSummary.fromJson(Map<String, dynamic> j) => _$ProjectSummaryFromJson(j);
}

@JsonSerializable()
class ProjectMemberResponse {
	final String id, fullName;
	final String? avatarUrl, role;
	const ProjectMemberResponse({required this.id, required this.fullName, this.avatarUrl, this.role});
	factory ProjectMemberResponse.fromJson(Map<String, dynamic> j) => _$ProjectMemberResponseFromJson(j);
}

@JsonSerializable()
class ProjectResponse {
	final String id, name;
	final String? description, status, priority, colorLabel;
	final double completionPercentage;
	final DateTime? startDate, dueDate;
	final List<ProjectMemberResponse>? members;
	final DateTime createdAt, updatedAt;
	const ProjectResponse({required this.id, required this.name, this.description, this.status, this.priority, required this.completionPercentage, this.colorLabel, this.startDate, this.dueDate, this.members, required this.createdAt, required this.updatedAt});
	factory ProjectResponse.fromJson(Map<String, dynamic> j) => _$ProjectResponseFromJson(j);
}

@JsonSerializable()
class CreateProjectRequest {
	final String? name, description, colorLabel, priority;
	final DateTime? startDate, dueDate;
	final List<String>? memberIds;
	const CreateProjectRequest({this.name, this.description, this.colorLabel, this.priority, this.startDate, this.dueDate, this.memberIds});
	Map<String, dynamic> toJson() => _$CreateProjectRequestToJson(this);
}

@JsonSerializable()
class UpdateProjectRequest {
	final String? name, description, colorLabel, status, priority;
	final DateTime? startDate, dueDate;
	const UpdateProjectRequest({this.name, this.description, this.colorLabel, this.startDate, this.dueDate, this.status, this.priority});
	Map<String, dynamic> toJson() => _$UpdateProjectRequestToJson(this);
}

@JsonSerializable()
class ProjectStatsResponse {
	final int totalTasks, todoTasks, inProgressTasks, reviewTasks, completedTasks;
	final double completionPercentage;
	const ProjectStatsResponse({required this.totalTasks, required this.todoTasks, required this.inProgressTasks, required this.reviewTasks, required this.completedTasks, required this.completionPercentage});
	factory ProjectStatsResponse.fromJson(Map<String, dynamic> j) => _$ProjectStatsResponseFromJson(j);
}

@JsonSerializable()
class InviteMemberRequest {
	final String userId;
	final String? role;
	const InviteMemberRequest({required this.userId, this.role});
	Map<String, dynamic> toJson() => _$InviteMemberRequestToJson(this);
}

@JsonSerializable()
class ChangeMemberRoleRequest {
	final String memberId;
	final String? role;
	const ChangeMemberRoleRequest({required this.memberId, this.role});
	Map<String, dynamic> toJson() => _$ChangeMemberRoleRequestToJson(this);
}
```

### 7.2 Remote DataSource

```csharp
class ProjectsRemoteDataSource {
	final Dio dio;
	ProjectsRemoteDataSource(this.dio);

	Future<PagedResult<ProjectSummary>> list({int page = 1, int pageSize = 20}) =>
			dio.getData(ApiPaths.projects,
				(j) => PagedResult<ProjectSummary>.fromJson(j as Map<String, dynamic>,
					(p) => ProjectSummary.fromJson(p as Map<String, dynamic>)),
				query: {'page': page, 'pageSize': pageSize});

	Future<ProjectResponse> create(CreateProjectRequest r) =>
			dio.postData(ApiPaths.projects, r.toJson(),
				(j) => ProjectResponse.fromJson(j as Map<String, dynamic>));

	Future<ProjectResponse> get(String id) =>
			dio.getData(ApiPaths.project(id), (j) => ProjectResponse.fromJson(j as Map<String, dynamic>));

	Future<ProjectResponse> update(String id, UpdateProjectRequest r) =>
			dio.putData(ApiPaths.project(id), r.toJson(),
				(j) => ProjectResponse.fromJson(j as Map<String, dynamic>));

	Future<void> delete(String id) => dio.deleteOk(ApiPaths.project(id));

	Future<ProjectStatsResponse> stats(String id) =>
			dio.getData(ApiPaths.projectStats(id),
				(j) => ProjectStatsResponse.fromJson(j as Map<String, dynamic>));

	Future<ProjectMemberResponse> invite(String id, InviteMemberRequest r) =>
			dio.postData(ApiPaths.projectMembers(id), r.toJson(),
				(j) => ProjectMemberResponse.fromJson(j as Map<String, dynamic>));

	Future<ProjectMemberResponse> changeRole(String id, String userId, ChangeMemberRoleRequest r) =>
			dio.patchData(ApiPaths.projectMember(id, userId), r.toJson(),
				(j) => ProjectMemberResponse.fromJson(j as Map<String, dynamic>));

	Future<void> removeMember(String id, String userId) =>
			dio.deleteOk(ApiPaths.projectMember(id, userId));
}
```

### 7.3 BLoCs

- **`ProjectsBloc`** — paginated grid: `Started`, `LoadMoreRequested`, `RefreshRequested`, `ProjectCreated`, `ProjectDeleted`. Concurrency: `droppable()` for page loads.
- **`ProjectDetailBloc`** — fetches `ProjectResponse` + `ProjectStatsResponse` + tasks list in parallel using `Future.wait`. Tabs: Overview / Tasks / Members / Files.
- **`MembersCubit`** — invite/change role/remove with optimistic add.

### 7.4 Pages & Widgets

- `ProjectsPage` — `SliverGrid` of `ProjectCard`, search bar, filter chips, FAB.
- `ProjectDetailPage` — `TabBar` (`OverviewTab`, `TasksTab`, `MembersTab`, `FilesTab`).
- `ProjectFormSheet` — name, description, color picker, date range, priority dropdown, member multi-select (uses `users/search`), submit.

## 8. Feature: Tasks

### 8.1 Models

```csharp
@JsonSerializable()
class TaskSummary {
	final String id, title;
	final String? status, priority, assigneeName, projectName;
	final DateTime? dueDate;
	const TaskSummary({required this.id, required this.title, this.status, this.priority, this.assigneeName, this.projectName, this.dueDate});
	factory TaskSummary.fromJson(Map<String, dynamic> j) => _$TaskSummaryFromJson(j);
}

@JsonSerializable()
class AssigneeBrief {
	final String? id, fullName, avatarUrl;
	const AssigneeBrief({this.id, this.fullName, this.avatarUrl});
	factory AssigneeBrief.fromJson(Map<String, dynamic> j) => _$AssigneeBriefFromJson(j);
}

@JsonSerializable()
class TagBrief {
	final String id, name;
	final String? color;
	const TagBrief({required this.id, required this.name, this.color});
	factory TagBrief.fromJson(Map<String, dynamic> j) => _$TagBriefFromJson(j);
}

@JsonSerializable()
class SubtaskResponse {
	final String id, title;
	final bool isCompleted;
	final int position;
	const SubtaskResponse({required this.id, required this.title, required this.isCompleted, required this.position});
	factory SubtaskResponse.fromJson(Map<String, dynamic> j) => _$SubtaskResponseFromJson(j);
}

@JsonSerializable()
class TaskDetailResponse {
	final String id, title;
	final String? description, status, priority;
	final DateTime? dueDate;
	final double? estimatedHours;
	final String projectId;
	final AssigneeBrief? assignee, createdBy;
	final List<SubtaskResponse>? subtasks;
	final List<TagBrief>? tags;
	final int commentsCount, attachmentsCount;
	final DateTime createdAt, updatedAt;
	const TaskDetailResponse({required this.id, required this.title, this.description, this.status, this.priority, this.dueDate, this.estimatedHours, required this.projectId, this.assignee, this.createdBy, this.subtasks, this.tags, required this.commentsCount, required this.attachmentsCount, required this.createdAt, required this.updatedAt});
	factory TaskDetailResponse.fromJson(Map<String, dynamic> j) => _$TaskDetailResponseFromJson(j);
}

@JsonSerializable()
class CreateTaskRequest {
	final String projectId, title;
	final String? description, status, priority, assigneeId;
	final DateTime? dueDate;
	final double? estimatedHours;
	final List<CreateSubtaskRequest>? subtasks;
	final List<String>? tagIds;
	const CreateTaskRequest({required this.projectId, required this.title, this.description, this.status, this.priority, this.dueDate, this.estimatedHours, this.assigneeId, this.subtasks, this.tagIds});
	Map<String, dynamic> toJson() => _$CreateTaskRequestToJson(this);
}

@JsonSerializable()
class UpdateTaskRequest {
	final String? title, description, status, priority, assigneeId;
	final DateTime? dueDate;
	final double? estimatedHours;
	const UpdateTaskRequest({this.title, this.description, this.status, this.priority, this.dueDate, this.estimatedHours, this.assigneeId});
	Map<String, dynamic> toJson() => _$UpdateTaskRequestToJson(this);
}

@JsonSerializable()
class UpdateStatusRequest { final String status; const UpdateStatusRequest({required this.status}); Map<String, dynamic> toJson() => _$UpdateStatusRequestToJson(this); }

@JsonSerializable()
class ReorderTaskRequest {
	final String taskId;
	final int newPosition;
	final String? newStatus;
	const ReorderTaskRequest({required this.taskId, required this.newPosition, this.newStatus});
	Map<String, dynamic> toJson() => _$ReorderTaskRequestToJson(this);
}

@JsonSerializable()
class CreateSubtaskRequest { final String title; final int position; const CreateSubtaskRequest({required this.title, required this.position}); Map<String, dynamic> toJson() => _$CreateSubtaskRequestToJson(this); }

@JsonSerializable()
class UpdateSubtaskRequest { final String? title; final int? position; final bool? isCompleted; const UpdateSubtaskRequest({this.title, this.position, this.isCompleted}); Map<String, dynamic> toJson() => _$UpdateSubtaskRequestToJson(this); }
```

### 8.2 Remote DataSource

```csharp
class TasksRemoteDataSource {
	final Dio dio;
	TasksRemoteDataSource(this.dio);

	Future<List<TaskSummary>> listByProject(String projectId) =>
			dio.getData(ApiPaths.projectTasks(projectId),
				(j) => (j as List).map((e) => TaskSummary.fromJson(e as Map<String, dynamic>)).toList());

	Future<TaskDetailResponse> create(CreateTaskRequest r) =>
			dio.postData(ApiPaths.tasks, r.toJson(),
				(j) => TaskDetailResponse.fromJson(j as Map<String, dynamic>));

	Future<TaskDetailResponse> get(String id) =>
			dio.getData(ApiPaths.task(id), (j) => TaskDetailResponse.fromJson(j as Map<String, dynamic>));

	Future<TaskResponse> update(String id, UpdateTaskRequest r) =>
			dio.putData(ApiPaths.task(id), r.toJson(), (j) => TaskResponse.fromJson(j as Map<String, dynamic>));

	Future<void> delete(String id) => dio.deleteOk(ApiPaths.task(id));

	Future<void> updateStatus(String id, TaskStatus s) async {
		final r = await dio.patch(ApiPaths.taskStatus(id), data: UpdateStatusRequest(status: s.toApi()).toJson());
		final env = ApiResponse<dynamic>.fromJson(r.data, (j) => j);
		if (!env.succeeded) throw ServerFailure(env.message ?? 'Status failed');
	}

	Future<void> reorder(String id, ReorderTaskRequest r) async {
		final res = await dio.patch(ApiPaths.taskPosition(id), data: r.toJson());
		final env = ApiResponse<dynamic>.fromJson(res.data, (j) => j);
		if (!env.succeeded) throw ServerFailure(env.message ?? 'Reorder failed');
	}

	Future<SubtaskResponse> addSubtask(String id, CreateSubtaskRequest r) =>
			dio.postData(ApiPaths.subtasks(id), r.toJson(), (j) => SubtaskResponse.fromJson(j as Map<String, dynamic>));

	Future<SubtaskResponse> updateSubtask(String id, String sid, UpdateSubtaskRequest r) =>
			dio.patchData(ApiPaths.subtask(id, sid), r.toJson(), (j) => SubtaskResponse.fromJson(j as Map<String, dynamic>));

	Future<void> deleteSubtask(String id, String sid) => dio.deleteOk(ApiPaths.subtask(id, sid));
}
```

### 8.3 BLoCs

- **`TasksBloc`** — for `TasksPage` per-project. Events: `LoadByProject(projectId)`, `Refreshed`, `Created`, `Updated`, `Deleted`, `StatusChanged(taskId, newStatus)`, `Reordered(taskId, newStatus, newPosition)`. Apply optimistic updates; revert on error.
- **`TaskDetailBloc`** — single task hydrate, subtask add/toggle/delete, refresh after attachments/comments change.
- **`TaskFilterCubit`** — local filter state (status, priority, assignee, dueDate range).

### 8.4 Kanban — Drag handler sketch

```csharp
Future<void> onCardDropped(TaskDetailResponse task, TaskStatus newStatus, int newPosition) async {
	// optimistic
	_optimisticMove(task.id, newStatus, newPosition);
	try {
		await remote.reorder(task.id, ReorderTaskRequest(
			taskId: task.id, newStatus: newStatus.toApi(), newPosition: newPosition));
	} catch (_) {
		_revertOptimistic(task.id);
		rethrow;
	}
}
```

### 8.5 Pages & Widgets

- `TasksPage` — chooses project (or aggregates with `Future.wait` over projects from `ProjectsRepository.list()`), renders `KanbanBoard` or `TaskList`.
- `TaskDetailPage` — header (status/priority badges), description, `SubtaskCheckList`, `CommentThread`, `AttachmentGrid`, edit FAB.
- `TaskFormSheet` — fields locked to API: title, description, status, priority, dueDate, estimatedHours, assignee (single), tagIds, subtasks. **No multi-assignee** (server only stores one).

## 9. Feature: Comments

### 9.1 Models

```csharp
@JsonSerializable()
class CommentResponse {
	final String id;
	final String? content, authorName, authorAvatar;
	final DateTime createdAt, updatedAt;
	const CommentResponse({required this.id, this.content, this.authorName, this.authorAvatar, required this.createdAt, required this.updatedAt});
	factory CommentResponse.fromJson(Map<String, dynamic> j) => _$CommentResponseFromJson(j);
}

@JsonSerializable()
class CreateCommentRequest {
	final String taskId;
	final String? content, parentId;
	const CreateCommentRequest({required this.taskId, this.content, this.parentId});
	Map<String, dynamic> toJson() => _$CreateCommentRequestToJson(this);
}
```

### 9.2 Remote DataSource

```csharp
class CommentsRemoteDataSource {
	final Dio dio;
	CommentsRemoteDataSource(this.dio);

	Future<List<CommentResponse>> list(String taskId) =>
			dio.getData(ApiPaths.comments(taskId),
				(j) => (j as List).map((e) => CommentResponse.fromJson(e as Map<String, dynamic>)).toList());

	Future<CommentResponse> create(String taskId, String content, {String? parentId}) =>
			dio.postData(ApiPaths.comments(taskId),
				CreateCommentRequest(taskId: taskId, content: content, parentId: parentId).toJson(),
				(j) => CommentResponse.fromJson(j as Map<String, dynamic>));

	Future<void> delete(String taskId, String cid) => dio.deleteOk(ApiPaths.comment(taskId, cid));
}
```

<aside>
ℹ️

Backend has **no `PUT` for comments** — hide the "Edit" option in `CommentTile`'s overflow menu, leave only "Delete".

</aside>

## 10. Feature: Tags

```csharp
@JsonSerializable()
class TagResponse { final String id, name; final String? color; const TagResponse({required this.id, required this.name, this.color}); factory TagResponse.fromJson(Map<String, dynamic> j) => _$TagResponseFromJson(j); }

@JsonSerializable()
class CreateTagRequest { final String? name, color; const CreateTagRequest({this.name, this.color}); Map<String, dynamic> toJson() => _$CreateTagRequestToJson(this); }

class TagsRemoteDataSource {
	final Dio dio;
	TagsRemoteDataSource(this.dio);
	Future<List<TagResponse>> list() => dio.getData(ApiPaths.tags, (j) => (j as List).map((e) => TagResponse.fromJson(e as Map<String, dynamic>)).toList());
	Future<TagResponse> create(CreateTagRequest r) => dio.postData(ApiPaths.tags, r.toJson(), (j) => TagResponse.fromJson(j as Map<String, dynamic>));
	Future<void> delete(String id) => dio.deleteOk(ApiPaths.tag(id));
}
```

`TagsBloc` cubit: `loaded(List<TagResponse>)` + create/delete with optimistic update. Pre-fetch on app start so `TaskFormSheet` can open without delay.

## 11. Feature: Notifications

```csharp
@JsonSerializable()
class NotificationResponse {
	final String id;
	final String? type, message;
	final bool isRead;
	final DateTime createdAt;
	const NotificationResponse({required this.id, this.type, this.message, required this.isRead, required this.createdAt});
	factory NotificationResponse.fromJson(Map<String, dynamic> j) => _$NotificationResponseFromJson(j);
}

@JsonSerializable()
class RegisterPushTokenRequest {
	final String? token, platform, deviceId;
	const RegisterPushTokenRequest({this.token, this.platform, this.deviceId});
	Map<String, dynamic> toJson() => _$RegisterPushTokenRequestToJson(this);
}
```

```csharp
class NotificationsRemoteDataSource {
	final Dio dio;
	NotificationsRemoteDataSource(this.dio);

	Future<PagedResult<NotificationResponse>> list({int page = 1, int pageSize = 20}) =>
			dio.getData(ApiPaths.notifications,
				(j) => PagedResult<NotificationResponse>.fromJson(j as Map<String, dynamic>,
					(p) => NotificationResponse.fromJson(p as Map<String, dynamic>)),
				query: {'page': page, 'pageSize': pageSize});

	Future<void> markRead(String id) async {
		final r = await dio.patch(ApiPaths.notificationRead(id));
		final env = ApiResponse<dynamic>.fromJson(r.data, (j) => j);
		if (!env.succeeded) throw ServerFailure(env.message ?? 'Failed');
	}

	Future<void> markAllRead() async {
		final r = await dio.post(ApiPaths.notificationsReadAll);
		final env = ApiResponse<dynamic>.fromJson(r.data, (j) => j);
		if (!env.succeeded) throw ServerFailure(env.message ?? 'Failed');
	}

	Future<void> delete(String id) => dio.deleteOk(ApiPaths.notification(id));

	Future<void> registerPushToken(String fcmToken, String platform, String deviceId) async {
		await dio.post(ApiPaths.notificationsPushToken,
			data: RegisterPushTokenRequest(token: fcmToken, platform: platform, deviceId: deviceId).toJson());
	}
}
```

### FCM bootstrap

```csharp
Future<void> initFcm(NotificationsRemoteDataSource ds) async {
	await Firebase.initializeApp();
	final messaging = FirebaseMessaging.instance;
	await messaging.requestPermission();
	final token = await messaging.getToken();
	if (token != null) {
		final info = await DeviceInfoPlugin().deviceInfo;
		await ds.registerPushToken(token, Platform.isAndroid ? 'android' : 'ios', info.toString());
	}
	FirebaseMessaging.onTokenRefresh.listen((t) =>
		ds.registerPushToken(t, Platform.isAndroid ? 'android' : 'ios', 'auto'));
	FirebaseMessaging.onMessage.listen(_showLocalNotification);
	FirebaseMessaging.onMessageOpenedApp.listen(_handleDeepLink);
}
```

## 12. Feature: Attachments

```csharp
@JsonSerializable()
class AttachmentResponse {
	final String id;
	final String? fileName, fileUrl, mimeType;
	final int fileSize;
	final String uploadedById;
	final DateTime createdAt;
	const AttachmentResponse({required this.id, this.fileName, this.fileUrl, required this.fileSize, this.mimeType, required this.uploadedById, required this.createdAt});
	factory AttachmentResponse.fromJson(Map<String, dynamic> j) => _$AttachmentResponseFromJson(j);
}
```

```csharp
class AttachmentsRemoteDataSource {
	final Dio dio;
	AttachmentsRemoteDataSource(this.dio);

	Future<List<AttachmentResponse>> projectFiles(String projectId) =>
			dio.getData(ApiPaths.projectAttachments(projectId),
				(j) => (j as List).map((e) => AttachmentResponse.fromJson(e as Map<String, dynamic>)).toList());

	Future<AttachmentResponse> uploadProject(String projectId, File f, ProgressCallback? onProgress) =>
			_upload(ApiPaths.projectAttachments(projectId), f, onProgress);

	Future<List<AttachmentResponse>> taskFiles(String taskId) =>
			dio.getData(ApiPaths.taskAttachments(taskId),
				(j) => (j as List).map((e) => AttachmentResponse.fromJson(e as Map<String, dynamic>)).toList());

	Future<AttachmentResponse> uploadTask(String taskId, File f, ProgressCallback? onProgress) =>
			_upload(ApiPaths.taskAttachments(taskId), f, onProgress);

	Future<void> deleteTaskAttachment(String taskId, String aid) =>
			dio.deleteOk(ApiPaths.taskAttachment(taskId, aid));

	Future<AttachmentResponse> _upload(String path, File f, ProgressCallback? onProgress) async {
		final form = FormData.fromMap({'file': await MultipartFile.fromFile(f.path)});
		final r = await dio.post(path, data: form, onSendProgress: onProgress);
		final env = ApiResponse<AttachmentResponse>.fromJson(r.data,
			(j) => AttachmentResponse.fromJson(j as Map<String, dynamic>));
		if (!env.succeeded || env.data == null) throw ServerFailure(env.message ?? 'Upload failed');
		return env.data!;
	}
}
```

`AttachmentGrid` widget — thumbnails for images, file-type icon otherwise. Tap → `open_filex` after `download` via `dio.download(fileUrl)`.

## 13. Routing (`go_router`)

```csharp
final router = GoRouter(
	initialLocation: '/',
	refreshListenable: GoRouterRefreshStream(authBloc.stream),
	redirect: AuthRedirect.handle,
	routes: [
		GoRoute(path: '/', builder: (_, __) => const SplashPage()),
		GoRoute(path: '/onboarding', builder: (_, __) => const OnboardingPage()),
		GoRoute(path: '/login', builder: (_, __) => const LoginPage()),
		GoRoute(path: '/register', builder: (_, __) => const RegisterPage()),
		ShellRoute(
			builder: (ctx, state, child) => MainShell(child: child),
			routes: [
				GoRoute(path: '/app/home', builder: (_, __) => const DashboardPage()),
				GoRoute(path: '/app/projects', builder: (_, __) => const ProjectsPage(), routes: [
					GoRoute(path: ':id', builder: (_, s) => ProjectDetailPage(id: s.pathParameters['id']!)),
				]),
				GoRoute(path: '/app/tasks', builder: (_, __) => const TasksPage(), routes: [
					GoRoute(path: ':id', builder: (_, s) => TaskDetailPage(id: s.pathParameters['id']!)),
				]),
				GoRoute(path: '/app/notifications', builder: (_, __) => const NotificationsPage()),
				GoRoute(path: '/app/profile', builder: (_, __) => const ProfilePage()),
			],
		),
	],
);
```

`AuthRedirect`:

```csharp
class AuthRedirect {
	static String? handle(BuildContext ctx, GoRouterState s) {
		final authState = ctx.read<AuthBloc>().state;
		final isAuth = authState is Authenticated;
		final goingToAuthArea = s.matchedLocation.startsWith('/app');
		final goingToPublic = ['/login', '/register', '/onboarding'].contains(s.matchedLocation);
		if (!isAuth && goingToAuthArea) return '/login';
		if (isAuth && goingToPublic) return '/app/home';
		return null;
	}
}
```

## 14. Dependency Injection (`core/di/injection.dart`)

```csharp
final sl = GetIt.instance;

Future<void> initDi(AppConfig config) async {
	// Storage
	sl.registerLazySingleton(() => const FlutterSecureStorage());
	sl.registerLazySingleton(() => SecureStorage(sl()));
	sl.registerLazySingleton(() => AuthEventBus());

	// Network
	sl.registerLazySingleton(() => AuthInterceptor(sl(), sl()));
	sl.registerLazySingleton<Dio>(() => DioClient.create(config, sl()));

	// Datasources
	sl.registerLazySingleton(() => AuthRemoteDataSource(sl()));
	sl.registerLazySingleton(() => UsersRemoteDataSource(sl()));
	sl.registerLazySingleton(() => ProjectsRemoteDataSource(sl()));
	sl.registerLazySingleton(() => TasksRemoteDataSource(sl()));
	sl.registerLazySingleton(() => CommentsRemoteDataSource(sl()));
	sl.registerLazySingleton(() => TagsRemoteDataSource(sl()));
	sl.registerLazySingleton(() => NotificationsRemoteDataSource(sl()));
	sl.registerLazySingleton(() => AttachmentsRemoteDataSource(sl()));

	// Repositories
	sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(sl(), sl()));
	// ... rest

	// UseCases (one line per usecase)
	sl.registerFactory(() => LoginUseCase(sl()));
	sl.registerFactory(() => RegisterUseCase(sl()));
	sl.registerFactory(() => LogoutUseCase(sl()));

	// BLoCs
	sl.registerFactory(() => AuthBloc(sl(), sl(), sl(), sl()));
	sl.registerFactory(() => ProjectsBloc(sl()));
	sl.registerFactory(() => TasksBloc(sl(), sl()));
	sl.registerFactory(() => NotificationsBloc(sl()));
	sl.registerFactory(() => ProfileBloc(sl()));
}
```

## 15. main.dart bootstrap

```csharp
Future<void> main() async {
	WidgetsFlutterBinding.ensureInitialized();
	await Hive.initFlutter();
	await Firebase.initializeApp();
	FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
	final config = AppConfig.dev();				// or .prod() based on flavor
	await initDi(config);
	await initFcm(sl());
	runApp(const TaskFlowApp());
}

class TaskFlowApp extends StatelessWidget {
	const TaskFlowApp({super.key});
	@override
	Widget build(BuildContext context) {
		return MultiBlocProvider(
			providers: [
				BlocProvider(create: (_) => sl<AuthBloc>()..add(AuthCheckRequested())),
				BlocProvider(create: (_) => sl<ProjectsBloc>()),
				BlocProvider(create: (_) => sl<NotificationsBloc>()),
			],
			child: MaterialApp.router(
				debugShowCheckedModeBanner: false,
				theme: AppTheme.light(),
				darkTheme: AppTheme.dark(),
				routerConfig: router,
			),
		);
	}
}
```

## 16. Sprint Plan — Day-by-Day

| **Day** | **Deliverable** | **Files / Endpoints** |
| --- | --- | --- |
| D1 | Project init, pubspec, theme, colors, spacing, native splash | `pubspec.yaml`, `core/theme`, `core/constants` |
| D2 | Dio + AuthInterceptor + ApiResponse/PagedResult + ErrorMapper | `core/network/*`, `core/error/*` |
| D3 | SecureStorage + Hive boxes + DI bootstrap + GoRouter shell | `core/storage/*`, `core/di`, `core/router` |
| D4 | Auth feature — login + register + AuthBloc + AuthRedirect | `/Auth/login`, `/Auth/register` |
| D5 | SplashPage + OnboardingPage + LoginPage + RegisterPage UI | `features/auth/presentation` |
| D6 | Users feature — `/users/me`, `/users/me/stats`, avatar upload | `features/users`, `features/profile` |
| D7 | Dashboard — greeting, stats card, recent projects (uses users/me/stats + projects) | `features/dashboard` |
| D8 | Projects list + detail + form sheet + stats | `/projects`, `/projects/{id}`, `/projects/{id}/stats` |
| D9 | Project members tab — invite/remove/change role + user search | `/projects/{id}/members*`, `/users/search` |
| D10 | Tasks list per project + Kanban board widget | `/projects/{id}/tasks` |
| D11 | Task CRUD + status + reorder (optimistic) | `/tasks/*`, `/tasks/{id}/status`, `/tasks/{id}/position` |
| D12 | Subtasks add/toggle/delete + TaskDetailPage shell | `/tasks/{id}/subtasks*` |
| D13 | Comments thread (no edit) + comment input bar | `/tasks/{id}/comments*` |
| D14 | Tags CRUD + TagChip in TaskFormSheet | `/tags*` |
| D15 | Attachments upload + grid + delete (tasks only) | `/projects/{id}/attachments`, `/tasks/{id}/attachments*` |
| D16 | Notifications page + read/read-all/delete + badge | `/notifications*` |
| D17 | FCM init + push-token registration + foreground & background handlers | `/notifications/push-token` |
| D18 | Connectivity banner, offline cache (Hive), shimmer loaders | `core/storage`, shared widgets |
| D19 | Global error overlay, validation polish, accessibility pass | shared widgets |
| D20 | Unit tests (UseCases, Repos), BLoC tests, integration smoke (login → create task) | `test/`, `integration_test/` |
| D21 | App icons + splash + release build (AAB + iOS archive) | `flutter_launcher_icons`, CI |

## 17. Backend TODO List (to unblock Flutter)

<aside>
🛠

These are the API gaps you need to fill on the .NET side **before final release**. Without them, parts of the original Flutter UX must stay disabled.

</aside>

1. `POST /api/v1/Auth/refresh` — refresh access token using refresh token.
2. `POST /api/v1/Auth/logout` — revoke refresh token server-side.
3. `POST /api/v1/Auth/forgot-password` + `verify-otp` + `reset-password` — full OTP flow (already in your `OtpService` — just expose endpoints).
4. `GET /api/v1/tasks` — global task list with filters (`status`, `priority`, `assigneeId`, `dueBefore`, `q`).
5. `PUT /api/v1/tasks/{taskId}/comments/{cid}` — edit own comment.
6. `DELETE /api/v1/projects/{projectId}/attachments/{aid}` — delete project attachments (currently tasks-only).
7. `DELETE /api/v1/users/me` — GDPR account deletion.
8. `GET /api/v1/projects/{id}/attachments/{aid}/download` and `…/tasks/{id}/attachments/{aid}/download` — signed URL or stream so Flutter doesn't need raw Supabase keys.
9. **SignalR hub `/hubs/notifications`** — wire to Flutter via `signalr_netcore` package for realtime in-app notifications.

Close those nine items and the Flutter app will hit 100% feature parity with the original Figma.

<aside>
✅

**Done.** This page is the single source of truth for Flutter ↔ API integration. Follow Sections 4–15 to build the layers, then walk Section 16 day-by-day. Section 17 is the backlog you ship to the .NET side in parallel.

</aside>