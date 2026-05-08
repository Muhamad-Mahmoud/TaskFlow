# Task-Flow Flutter — Part 2: Deep Implementation, Realtime, Offline & Release

<aside>
📲

**Part 2 of the Flutter plan.** Part 1 (`mapped to live API`) is on the previous page. This part goes deeper into UI code, offline-first storage, SignalR realtime, FCM deep linking, attachments with image compression, localization (ar/en + RTL), theming, formz validation, error/loading UX, testing pyramid, performance, analytics, CI/CD on Codemagic, and a 14-day extension sprint to ship to stores.

</aside>

## 0. What Part 2 covers (and what it assumes)

**Assumes you already have** (from Part 1):

- `core/network/dio_client.dart`, `auth_interceptor.dart`, `error_mapper.dart`, `ApiResponse<T>`, `PagedResult<T>`.
- `features/auth`, `projects`, `tasks`, `comments`, `tags`, `notifications`, `attachments` skeletons with BLoC + datasource + repo.
- GoRouter wired with `AuthRedirect`.

**Part 2 adds:**

1. Design system + theming (light/dark) with tokens.
2. Localization with `flutter_localizations` + `intl` + ARB files (ar + en) + RTL.
3. Form validation with `formz` (typed inputs, no string validators in BLoC).
4. Reusable UI components (buttons, text fields, empty states, loaders, error widgets).
5. Detailed screens with code: Login, Register, Projects list, Project detail (Kanban), Task detail, Comments, Profile, Notifications center.
6. Offline-first cache with **Drift** (sqlite) + sync queue.
7. Realtime via **SignalR** (`signalr_netcore`) — task updates + notifications.
8. FCM push: setup, channels, topic subscription, deep link from payload.
9. Attachments: `file_picker` + `image_picker` + `flutter_image_compress` + upload progress.
10. Error & loading UX patterns (skeletons, retry, snackbars).
11. Testing pyramid: unit (BLoC + repos), widget, integration (`patrol`).
12. Performance: image caching, list virtualization, `const` discipline, build perf overlays.
13. Analytics + Crashlytics + Sentry fallback.
14. CI/CD on **Codemagic** with Firebase App Distribution + Play internal track.
15. Release checklist (Play Console + App Store Connect).
16. Sprint plan **D22 → D35** (2 more weeks).

---

## 1. Design system & theming

### 1.1 Tokens — `core/theme/app_tokens.dart`

```dart
import 'package:flutter/material.dart';

class AppColors {
  static const primary = Color(0xFF4F46E5);   // indigo-600
  static const primaryDark = Color(0xFF4338CA);
  static const accent = Color(0xFF06B6D4);    // cyan-500
  static const success = Color(0xFF10B981);
  static const warning = Color(0xFFF59E0B);
  static const danger = Color(0xFFEF4444);

  // surfaces
  static const bgLight = Color(0xFFF8FAFC);
  static const bgDark = Color(0xFF0F172A);
  static const cardLight = Colors.white;
  static const cardDark = Color(0xFF1E293B);

  // status chips
  static const statusTodo = Color(0xFF94A3B8);
  static const statusInProgress = Color(0xFF3B82F6);
  static const statusReview = Color(0xFFA855F7);
  static const statusDone = Color(0xFF10B981);

  // priority
  static const priorityLow = Color(0xFF64748B);
  static const priorityMedium = Color(0xFFF59E0B);
  static const priorityHigh = Color(0xFFEF4444);
  static const priorityCritical = Color(0xFFB91C1C);
}

class AppRadius {
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 24.0;
}

class AppSpacing {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 24.0;
  static const xxl = 32.0;
}
```

### 1.2 ThemeData — `core/theme/app_theme.dart`

```dart
import 'package:flutter/material.dart';
import 'app_tokens.dart';

class AppTheme {
  static ThemeData light() {
    final base = ThemeData.light(useMaterial3: true);
    return base.copyWith(
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: AppColors.bgLight,
      cardTheme: CardTheme(
        color: AppColors.cardLight,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          side: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
      ),
      inputDecorationTheme: _input(false),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
        ),
      ),
      snackBarTheme: const SnackBarThemeData(behavior: SnackBarBehavior.floating),
    );
  }

  static ThemeData dark() {
    final base = ThemeData.dark(useMaterial3: true);
    return base.copyWith(
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.dark,
      ),
      scaffoldBackgroundColor: AppColors.bgDark,
      cardTheme: CardTheme(
        color: AppColors.cardDark,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          side: const BorderSide(color: Color(0xFF334155)),
        ),
      ),
      inputDecorationTheme: _input(true),
    );
  }

  static InputDecorationTheme _input(bool dark) => InputDecorationTheme(
    filled: true,
    fillColor: dark ? const Color(0xFF1E293B) : Colors.white,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.md),
      borderSide: BorderSide(color: dark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.md),
      borderSide: BorderSide(color: dark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.md),
      borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
    ),
  );
}
```

### 1.3 Status & priority color helpers — `core/theme/status_colors.dart`

```dart
import 'package:flutter/material.dart';
import '../enums/task_status.dart';
import '../enums/task_priority.dart';
import 'app_tokens.dart';

Color statusColor(TaskStatus s) => switch (s) {
  TaskStatus.toDo => AppColors.statusTodo,
  TaskStatus.inProgress => AppColors.statusInProgress,
  TaskStatus.inReview => AppColors.statusReview,
  TaskStatus.done => AppColors.statusDone,
};

Color priorityColor(TaskPriority p) => switch (p) {
  TaskPriority.low => AppColors.priorityLow,
  TaskPriority.medium => AppColors.priorityMedium,
  TaskPriority.high => AppColors.priorityHigh,
  TaskPriority.critical => AppColors.priorityCritical,
};
```

---

## 2. Localization — Arabic + English with RTL

### 2.1 Add deps

```yaml
dependencies:
	flutter_localizations:
		sdk: flutter
	intl: ^0.19.0

flutter:
	generate: true
```

### 2.2 `l10n.yaml` at project root

```yaml
arb-dir: lib/l10n
template-arb-file: app_en.arb
output-localization-file: app_localizations.dart
output-class: AppL10n
synthetic-package: false
output-dir: lib/l10n/generated
```

### 2.3 `lib/l10n/app_en.arb`

```json
{
	"@@locale": "en",
	"appTitle": "Task-Flow",
	"login": "Sign in",
	"register": "Create account",
	"email": "Email",
	"password": "Password",
	"emailInvalid": "Please enter a valid email",
	"passwordTooShort": "Password must be at least 8 characters",
	"projects": "Projects",
	"newProject": "New project",
	"tasks": "Tasks",
	"comments": "Comments",
	"notifications": "Notifications",
	"profile": "Profile",
	"logout": "Sign out",
	"retry": "Retry",
	"emptyTasks": "No tasks yet — add one with the + button.",
	"taskStatusToDo": "To do",
	"taskStatusInProgress": "In progress",
	"taskStatusInReview": "In review",
	"taskStatusDone": "Done"
}
```

### 2.4 `lib/l10n/app_ar.arb`

```json
{
	"@@locale": "ar",
	"appTitle": "تاسك فلو",
	"login": "تسجيل الدخول",
	"register": "إنشاء حساب",
	"email": "البريد الإلكتروني",
	"password": "كلمة المرور",
	"emailInvalid": "من فضلك أدخل بريدًا صحيحًا",
	"passwordTooShort": "كلمة المرور يجب أن تكون 8 أحرف على الأقل",
	"projects": "المشاريع",
	"newProject": "مشروع جديد",
	"tasks": "المهام",
	"comments": "التعليقات",
	"notifications": "الإشعارات",
	"profile": "الملف الشخصي",
	"logout": "تسجيل الخروج",
	"retry": "إعادة المحاولة",
	"emptyTasks": "لا توجد مهام بعد — أضف واحدة باستخدام زر +.",
	"taskStatusToDo": "قيد الانتظار",
	"taskStatusInProgress": "قيد التنفيذ",
	"taskStatusInReview": "قيد المراجعة",
	"taskStatusDone": "تم"
}
```

### 2.5 Wire it in `MaterialApp.router`

```dart
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/generated/app_localizations.dart';

MaterialApp.router(
	localizationsDelegates: AppL10n.localizationsDelegates,
	supportedLocales: AppL10n.supportedLocales,
	locale: appState.locale, // from a LocaleCubit
	// ...
)
```

### 2.6 RTL behavior

- Arabic locale automatically flips layout via `Directionality.of(context)`.
- For Kanban board, **don't** auto-flip column order — wrap the horizontal `ListView` in `Directionality(textDirection: TextDirection.ltr, child: ...)` so columns stay To Do → Done in both locales.
- Icons: prefer `Icons.arrow_forward_ios` (auto flips) over manually using `chevron_right`.

---

## 3. Form validation with `formz`

### 3.1 Inputs — `features/auth/presentation/inputs/`

```dart
// email_input.dart
import 'package:formz/formz.dart';

enum EmailError { empty, invalid }

class EmailInput extends FormzInput<String, EmailError> {
	const EmailInput.pure() : super.pure('');
	const EmailInput.dirty([super.value = '']) : super.dirty();

	static final _re = RegExp(r'^[\w.+-]+@[\w-]+\.[\w.-]+$');

	@override
	EmailError? validator(String value) {
		if (value.isEmpty) return EmailError.empty;
		if (!_re.hasMatch(value)) return EmailError.invalid;
		return null;
	}
}
```

```dart
// password_input.dart
import 'package:formz/formz.dart';

enum PasswordError { empty, tooShort }

class PasswordInput extends FormzInput<String, PasswordError> {
	const PasswordInput.pure() : super.pure('');
	const PasswordInput.dirty([super.value = '']) : super.dirty();

	@override
	PasswordError? validator(String value) {
		if (value.isEmpty) return PasswordError.empty;
		if (value.length < 8) return PasswordError.tooShort;
		return null;
	}
}
```

### 3.2 LoginCubit using formz

```dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import 'inputs/email_input.dart';
import 'inputs/password_input.dart';

class LoginState with FormzMixin {
	final EmailInput email;
	final PasswordInput password;
	final FormzSubmissionStatus status;
	final String? errorMessage;

	const LoginState({
		this.email = const EmailInput.pure(),
		this.password = const PasswordInput.pure(),
		this.status = FormzSubmissionStatus.initial,
		this.errorMessage,
	});

	@override
	List<FormzInput> get inputs => [email, password];

	LoginState copyWith({EmailInput? email, PasswordInput? password, FormzSubmissionStatus? status, String? errorMessage}) =>
		LoginState(
			email: email ?? this.email,
			password: password ?? this.password,
			status: status ?? this.status,
			errorMessage: errorMessage,
		);
}

class LoginCubit extends Cubit<LoginState> {
	final AuthRepository _repo;
	LoginCubit(this._repo) : super(const LoginState());

	void emailChanged(String v) => emit(state.copyWith(email: EmailInput.dirty(v)));
	void passwordChanged(String v) => emit(state.copyWith(password: PasswordInput.dirty(v)));

	Future<void> submit() async {
		if (!state.isValid) return;
		emit(state.copyWith(status: FormzSubmissionStatus.inProgress));
		try {
			await _repo.login(state.email.value, state.password.value);
			emit(state.copyWith(status: FormzSubmissionStatus.success));
		} on ApiException catch (e) {
			emit(state.copyWith(status: FormzSubmissionStatus.failure, errorMessage: e.message));
		}
	}
}
```

---

## 4. Reusable UI primitives

### 4.1 Buttons — `core/widgets/app_button.dart`

```dart
import 'package:flutter/material.dart';
import '../theme/app_tokens.dart';

class AppButton extends StatelessWidget {
	final String label;
	final VoidCallback? onPressed;
	final bool loading;
	final IconData? icon;
	const AppButton({super.key, required this.label, this.onPressed, this.loading = false, this.icon});

	@override
	Widget build(BuildContext context) {
		return SizedBox(
			height: 48,
			width: double.infinity,
			child: ElevatedButton(
				onPressed: loading ? null : onPressed,
				child: loading
					? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
					: Row(
							mainAxisAlignment: MainAxisAlignment.center,
							children: [
								if (icon != null) ...[Icon(icon, size: 20), const SizedBox(width: AppSpacing.sm)],
								Text(label),
							],
						),
			),
		);
	}
}
```

### 4.2 Empty state

```dart
class EmptyState extends StatelessWidget {
	final IconData icon;
	final String title;
	final String? subtitle;
	final Widget? action;
	const EmptyState({super.key, required this.icon, required this.title, this.subtitle, this.action});

	@override
	Widget build(BuildContext context) {
		return Center(
			child: Padding(
				padding: const EdgeInsets.all(AppSpacing.xl),
				child: Column(
					mainAxisSize: MainAxisSize.min,
					children: [
						Icon(icon, size: 64, color: Theme.of(context).colorScheme.outline),
						const SizedBox(height: AppSpacing.lg),
						Text(title, style: Theme.of(context).textTheme.titleMedium),
						if (subtitle != null) ...[
							const SizedBox(height: AppSpacing.sm),
							Text(subtitle!, textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyMedium),
						],
						if (action != null) ...[const SizedBox(height: AppSpacing.lg), action!],
					],
				),
			),
		);
	}
}
```

### 4.3 Skeleton loader (shimmer)

```dart
// uses package: shimmer
import 'package:shimmer/shimmer.dart';

class SkeletonTile extends StatelessWidget {
	const SkeletonTile({super.key});
	@override
	Widget build(BuildContext context) => Shimmer.fromColors(
		baseColor: Colors.grey.shade300,
		highlightColor: Colors.grey.shade100,
		child: Container(
			height: 72,
			margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
			decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
		),
	);
}
```

### 4.4 Error widget

```dart
class ErrorRetry extends StatelessWidget {
	final String message;
	final VoidCallback onRetry;
	const ErrorRetry({super.key, required this.message, required this.onRetry});

	@override
	Widget build(BuildContext context) => Center(
		child: Column(
			mainAxisSize: MainAxisSize.min,
			children: [
				const Icon(Icons.error_outline, size: 48, color: Colors.red),
				const SizedBox(height: 12),
				Text(message, textAlign: TextAlign.center),
				const SizedBox(height: 12),
				FilledButton.tonal(onPressed: onRetry, child: const Text('Retry')),
			],
		),
	);
}
```

---

## 5. Detailed screens

### 5.1 Login — `features/auth/presentation/pages/login_page.dart`

```dart
class LoginPage extends StatelessWidget {
	const LoginPage({super.key});

	@override
	Widget build(BuildContext context) {
		final l = AppL10n.of(context)!;
		return BlocProvider(
			create: (_) => LoginCubit(getIt()),
			child: Scaffold(
				body: SafeArea(
					child: BlocConsumer<LoginCubit, LoginState>(
						listener: (ctx, s) {
							if (s.status.isSuccess) ctx.go('/');
							if (s.status.isFailure) {
								ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text(s.errorMessage ?? 'Failed')));
							}
						},
						builder: (ctx, s) => Padding(
							padding: const EdgeInsets.all(24),
							child: Column(
								crossAxisAlignment: CrossAxisAlignment.stretch,
								mainAxisAlignment: MainAxisAlignment.center,
								children: [
									Text(l.appTitle, textAlign: TextAlign.center, style: Theme.of(ctx).textTheme.headlineMedium),
									const SizedBox(height: 32),
									TextField(
										decoration: InputDecoration(labelText: l.email, errorText: _emailError(s, l)),
										keyboardType: TextInputType.emailAddress,
										onChanged: ctx.read<LoginCubit>().emailChanged,
									),
									const SizedBox(height: 16),
									TextField(
										decoration: InputDecoration(labelText: l.password, errorText: _pwdError(s, l)),
										obscureText: true,
										onChanged: ctx.read<LoginCubit>().passwordChanged,
									),
									const SizedBox(height: 24),
									AppButton(
										label: l.login,
										loading: s.status.isInProgress,
										onPressed: s.isValid ? ctx.read<LoginCubit>().submit : null,
									),
									TextButton(onPressed: () => ctx.push('/register'), child: Text(l.register)),
								],
							),
						),
					),
				),
			),
		);
	}

	String? _emailError(LoginState s, AppL10n l) {
		if (s.email.isPure) return null;
		return s.email.error == EmailError.invalid ? l.emailInvalid : null;
	}

	String? _pwdError(LoginState s, AppL10n l) {
		if (s.password.isPure) return null;
		return s.password.error == PasswordError.tooShort ? l.passwordTooShort : null;
	}
}
```

### 5.2 Project detail — Kanban board

Wraps four columns (To Do / In Progress / In Review / Done) with `flutter_reorderable_grid_view` or hand-rolled `LongPressDraggable` per task card. On drop, calls `MoveTaskInColumn` with the new index.

```dart
class KanbanBoard extends StatelessWidget {
	final List<TaskItem> tasks;
	final Future<void> Function(String taskId, TaskStatus newStatus, int newIndex) onMove;
	const KanbanBoard({super.key, required this.tasks, required this.onMove});

	@override
	Widget build(BuildContext context) {
		return Directionality(
			textDirection: TextDirection.ltr, // keep columns left-to-right even in Arabic
			child: ListView(
				scrollDirection: Axis.horizontal,
				padding: const EdgeInsets.all(12),
				children: TaskStatus.values.map((status) {
					final column = tasks.where((t) => t.status == status).toList()
						..sort((a, b) => a.position.compareTo(b.position));
					return _Column(status: status, tasks: column, onMove: onMove);
				}).toList(),
			),
		);
	}
}

class _Column extends StatelessWidget {
	final TaskStatus status;
	final List<TaskItem> tasks;
	final Future<void> Function(String, TaskStatus, int) onMove;
	const _Column({required this.status, required this.tasks, required this.onMove});

	@override
	Widget build(BuildContext context) {
		return DragTarget<TaskItem>(
			onAcceptWithDetails: (d) => onMove(d.data.id, status, tasks.length),
			builder: (ctx, _, __) => Container(
				width: 280,
				margin: const EdgeInsets.only(right: 12),
				decoration: BoxDecoration(
					color: statusColor(status).withOpacity(.08),
					borderRadius: BorderRadius.circular(16),
				),
				child: Column(
					crossAxisAlignment: CrossAxisAlignment.stretch,
					children: [
						Padding(
							padding: const EdgeInsets.all(12),
							child: Text(status.label, style: const TextStyle(fontWeight: FontWeight.w700)),
						),
						Expanded(
							child: ListView.builder(
								itemCount: tasks.length,
								itemBuilder: (_, i) => LongPressDraggable<TaskItem>(
									data: tasks[i],
									feedback: Material(elevation: 6, child: TaskCard(task: tasks[i])),
									childWhenDragging: const Opacity(opacity: .3, child: TaskCardPlaceholder()),
									child: TaskCard(task: tasks[i]),
								),
							),
						),
					],
				),
			),
		);
	}
}
```

### 5.3 Task detail — comments + subtasks

Uses an `IndexedStack` with three tabs (Details, Subtasks, Comments). Comments tab uses pull-to-refresh + paginated `ListView` driven by `CommentsBloc.loadMore()`.

---

## 6. Offline-first cache with Drift

### 6.1 Why Drift

- Type-safe SQL.
- Generates DAOs.
- Stream-based queries integrate naturally with BLoC.

### 6.2 Schema — `core/db/app_db.dart`

```dart
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'app_db.g.dart';

class Projects extends Table {
	TextColumn get id => text()();
	TextColumn get name => text()();
	TextColumn get description => text().nullable()();
	TextColumn get status => text()();
	DateTimeColumn get updatedAt => dateTime()();
	IntColumn get version => integer().withDefault(const Constant(1))();
	BoolColumn get pendingSync => boolean().withDefault(const Constant(false))();
	@override
	Set<Column> get primaryKey => {id};
}

class Tasks extends Table {
	TextColumn get id => text()();
	TextColumn get projectId => text()();
	TextColumn get title => text()();
	TextColumn get description => text().nullable()();
	TextColumn get status => text()();
	TextColumn get priority => text()();
	IntColumn get position => integer()();
	TextColumn get assigneeId => text().nullable()();
	DateTimeColumn get dueDate => dateTime().nullable()();
	DateTimeColumn get updatedAt => dateTime()();
	BoolColumn get pendingSync => boolean().withDefault(const Constant(false))();
	@override
	Set<Column> get primaryKey => {id};
}

class SyncQueue extends Table {
	IntColumn get id => integer().autoIncrement()();
	TextColumn get entity => text()(); // 'project' | 'task' | 'comment'
	TextColumn get op => text()();     // 'create' | 'update' | 'delete'
	TextColumn get payload => text()();// json
	DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
	IntColumn get attempts => integer().withDefault(const Constant(0))();
}

@DriftDatabase(tables: [Projects, Tasks, SyncQueue])
class AppDb extends _$AppDb {
	AppDb() : super(_open());
	@override int get schemaVersion => 1;
}

LazyDatabase _open() => LazyDatabase(() async {
	final dir = await getApplicationDocumentsDirectory();
	return NativeDatabase(File(p.join(dir.path, 'taskflow.db')));
});
```

### 6.3 Repository pattern (offline-first)

```dart
class TaskRepository {
	final AppDb _db;
	final TaskRemoteDataSource _remote;
	final Connectivity _conn;
	TaskRepository(this._db, this._remote, this._conn);

	Stream<List<TaskItem>> watchProjectTasks(String projectId) =>
		(_db.select(_db.tasks)..where((t) => t.projectId.equals(projectId)))
			.watch().map((rows) => rows.map(_toDomain).toList());

	Future<void> refreshProjectTasks(String projectId) async {
		final results = await _remote.list(projectId); // hits API
		await _db.batch((b) {
			b.deleteWhere(_db.tasks, (t) => t.projectId.equals(projectId));
			b.insertAll(_db.tasks, results.items.map(_toRow).toList());
		});
	}

	Future<TaskItem> createTask(CreateTaskInput input) async {
		final optimistic = TaskItem.optimistic(input);
		await _db.into(_db.tasks).insert(_toRow(optimistic).copyWith(pendingSync: const Value(true)));
		final online = (await _conn.checkConnectivity()).contains(ConnectivityResult.mobile)
				|| (await _conn.checkConnectivity()).contains(ConnectivityResult.wifi);
		if (online) {
			final real = await _remote.create(input);
			await _db.transaction(() async {
				await (_db.delete(_db.tasks)..where((t) => t.id.equals(optimistic.id))).go();
				await _db.into(_db.tasks).insert(_toRow(real));
			});
			return real;
		} else {
			await _db.into(_db.syncQueue).insert(SyncQueueCompanion.insert(
				entity: 'task', op: 'create', payload: jsonEncode(input.toJson())));
			return optimistic;
		}
	}
}
```

### 6.4 SyncWorker

- Runs on app start + on `Connectivity` changes.
- Drains `SyncQueue` FIFO, retries with exponential backoff up to 5 attempts, then surfaces a banner.

```dart
class SyncWorker {
	final AppDb _db;
	final TaskRemoteDataSource _tasks;
	final ProjectRemoteDataSource _projects;
	SyncWorker(this._db, this._tasks, this._projects);

	Future<void> drain() async {
		final items = await _db.select(_db.syncQueue).get();
		for (final item in items) {
			try {
				switch ('${item.entity}:${item.op}') {
					case 'task:create':
						await _tasks.create(CreateTaskInput.fromJson(jsonDecode(item.payload)));
						break;
					case 'task:update':
						await _tasks.update(UpdateTaskInput.fromJson(jsonDecode(item.payload)));
						break;
				}
				await (_db.delete(_db.syncQueue)..where((t) => t.id.equals(item.id))).go();
			} catch (_) {
				await (_db.update(_db.syncQueue)..where((t) => t.id.equals(item.id)))
					.write(SyncQueueCompanion(attempts: Value(item.attempts + 1)));
			}
		}
	}
}
```

---

## 7. Realtime via SignalR

Backend exposes `/hubs/notifications`. Client uses `signalr_netcore`.

### 7.1 Add dep

```yaml
signalr_netcore: ^1.4.1
```

### 7.2 Hub client — `core/realtime/notifications_hub.dart`

```dart
import 'package:signalr_netcore/signalr_client.dart';

class NotificationsHub {
	final String baseUrl;
	final Future<String?> Function() tokenProvider;
	HubConnection? _connection;

	NotificationsHub({required this.baseUrl, required this.tokenProvider});

	Future<void> start({
		required void Function(Map<String, dynamic>) onTaskUpdated,
		required void Function(Map<String, dynamic>) onNotification,
	}) async {
		final opts = HttpConnectionOptions(
			accessTokenFactory: () async => (await tokenProvider()) ?? '',
			logger: null,
		);
		_connection = HubConnectionBuilder()
			.withUrl('$baseUrl/hubs/notifications', options: opts)
			.withAutomaticReconnect(retryDelays: [0, 2000, 5000, 10000, 30000])
			.build();

		_connection!.on('TaskUpdated', (args) {
			if (args == null || args.isEmpty) return;
			onTaskUpdated(Map<String, dynamic>.from(args.first as Map));
		});
		_connection!.on('Notify', (args) {
			if (args == null || args.isEmpty) return;
			onNotification(Map<String, dynamic>.from(args.first as Map));
		});

		await _connection!.start();
	}

	Future<void> joinProject(String projectId) =>
		_connection?.invoke('JoinProject', args: [projectId]) ?? Future.value();

	Future<void> leaveProject(String projectId) =>
		_connection?.invoke('LeaveProject', args: [projectId]) ?? Future.value();

	Future<void> stop() => _connection?.stop() ?? Future.value();
}
```

### 7.3 Wiring

- Start hub in `AppShell.initState` after auth success.
- On `TaskUpdated`, call `_db.into(_db.tasks).insertOnConflictUpdate(_toRow(task))`. BLoC sees the change via `watchProjectTasks` stream and re-renders.
- On project page enter, call `joinProject(projectId)`. On leave, `leaveProject`.

---

## 8. FCM push notifications

### 8.1 Bootstrap — `core/push/fcm_service.dart`

```dart
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class FcmService {
	final FlutterLocalNotificationsPlugin _local;
	final NotificationRemoteDataSource _remote;
	FcmService(this._local, this._remote);

	static const _channel = AndroidNotificationChannel(
		'taskflow_default', 'Task-Flow',
		importance: Importance.high,
	);

	Future<void> init() async {
		await Firebase.initializeApp();
		await _local.initialize(
			const InitializationSettings(
				android: AndroidInitializationSettings('@mipmap/ic_launcher'),
				iOS: DarwinInitializationSettings(),
			),
			onDidReceiveNotificationResponse: _handleTap,
		);
		await _local.resolvePlatformSpecificImplementation<
				AndroidFlutterLocalNotificationsPlugin>()?.createNotificationChannel(_channel);

		await FirebaseMessaging.instance.requestPermission(alert: true, badge: true, sound: true);
		final token = await FirebaseMessaging.instance.getToken();
		if (token != null) {
			// API does not currently expose a push-token endpoint; queue locally
			// or POST to /api/v1/users/me/push-tokens once backend ships it.
		}

		FirebaseMessaging.onMessage.listen(_onForeground);
		FirebaseMessaging.onMessageOpenedApp.listen(_onOpened);
		FirebaseMessaging.onBackgroundMessage(_bgHandler);
	}

	void _onForeground(RemoteMessage m) {
		final n = m.notification;
		if (n == null) return;
		_local.show(
			n.hashCode, n.title, n.body,
			NotificationDetails(android: AndroidNotificationDetails(_channel.id, _channel.name)),
			payload: m.data['deepLink'] as String?,
		);
	}

	void _onOpened(RemoteMessage m) {
		final link = m.data['deepLink'] as String?;
		if (link != null) appRouter.go(link);
	}

	static void _handleTap(NotificationResponse r) {
		if (r.payload != null) appRouter.go(r.payload!);
	}

	@pragma('vm:entry-point')
	static Future<void> _bgHandler(RemoteMessage m) async {
		await Firebase.initializeApp();
	}
}
```

### 8.2 Deep-link conventions (sync with backend)

| Notification | data.deepLink |
| --- | --- |
| Task assigned | `/projects/{projectId}/tasks/{taskId}` |
| Comment added | `/projects/{projectId}/tasks/{taskId}#comments` |
| Project invite | `/projects/{projectId}` |
| Due-date reminder | `/projects/{projectId}/tasks/{taskId}` |

---

## 9. Attachments — pick, compress, upload with progress

### 9.1 Add deps

```yaml
file_picker: ^8.0.0
image_picker: ^1.1.0
flutter_image_compress: ^2.3.0
```

### 9.2 Service

```dart
class AttachmentService {
	final Dio _dio;
	AttachmentService(this._dio);

	Future<File> pickAndCompressImage() async {
		final x = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 85);
		if (x == null) throw const CancelledException();
		final bytes = await FlutterImageCompress.compressWithFile(
			x.path, minWidth: 1600, minHeight: 1600, quality: 78,
		);
		final f = File('${x.path}.compressed.jpg');
		await f.writeAsBytes(bytes!);
		return f;
	}

	Future<File?> pickAnyFile() async {
		final r = await FilePicker.platform.pickFiles(allowMultiple: false);
		if (r == null || r.files.single.path == null) return null;
		return File(r.files.single.path!);
	}

	Future<Attachment> uploadTaskAttachment({
		required String taskId,
		required File file,
		required void Function(double progress) onProgress,
	}) async {
		final form = FormData.fromMap({
			'file': await MultipartFile.fromFile(file.path, filename: p.basename(file.path)),
		});
		final res = await _dio.post(
			'/api/v1/tasks/$taskId/attachments',
			data: form,
			onSendProgress: (s, t) => onProgress(t > 0 ? s / t : 0),
		);
		return Attachment.fromJson((res.data as Map)['data'] as Map<String, dynamic>);
	}
}
```

### 9.3 Upload sheet UI

Bottom sheet with: 📷 Camera · 🖼 Gallery · 📎 File. Each tile triggers the corresponding picker → compresses → calls service → displays a `LinearProgressIndicator(value: progress)`.

---

## 10. Error & loading UX patterns

| State | Pattern |
| --- | --- |
| Initial list load | Skeleton tiles (3–5) |
| Re-fetch (refresh) | `RefreshIndicator` only — keep current data visible |
| Mutation in flight | Disable the form's submit button + show inline spinner |
| 401 | `AuthInterceptor` clears token, GoRouter redirects to `/login`, snackbar `"Session expired"` |
| 403 | Snackbar `"You don't have permission"` |
| 422 (validation) | Map server errors[] back to fields by name when possible |
| 5xx / network | `ErrorRetry` widget; record to Crashlytics |
| Optimistic failure | Roll back local DB change, show snackbar `"Couldn't save — retry?"` |

---

## 11. Testing pyramid

### 11.1 Unit — `bloc_test`

```dart
test('LoginCubit submit success emits success', () async {
	final repo = MockAuthRepository();
	when(() => repo.login(any(), any())).thenAnswer((_) async => AuthSession.fixture());
	final cubit = LoginCubit(repo);
	cubit
		..emailChanged('a@b.co')
		..passwordChanged('verysecret');
	await expectLater(
		cubit.stream,
		emitsInOrder([
			isA<LoginState>().having((s) => s.status, 'status', FormzSubmissionStatus.inProgress),
			isA<LoginState>().having((s) => s.status, 'status', FormzSubmissionStatus.success),
		]),
	);
	await cubit.submit();
});
```

### 11.2 Widget — `flutter_test`

Goldens for: empty state, error retry, kanban column, task card. Uses `golden_toolkit`.

### 11.3 Integration — `patrol`

E2E flows: register → create project → create task → drag to Done → log out. Runs on real Firebase Test Lab device matrix from Codemagic.

```bash
patrol test --target integration_test/full_flow_test.dart
```

---

## 12. Performance

- `const` everywhere — enable `prefer_const_constructors` lint.
- Lists: always `ListView.builder` (never `.map().toList()` inside a Column).
- Images: `cached_network_image` with disk cache.
- Avoid rebuilds: `BlocSelector` and `context.select` instead of `BlocBuilder` for narrow slices.
- Profile with `flutter run --profile` and DevTools' performance overlay before each release.
- Defer heavy work off the main isolate (`compute(...)`) for JSON parsing of large lists (>500 rows).

---

## 13. Analytics, crash reporting, and logging

```yaml
firebase_analytics: ^11.0.0
firebase_crashlytics: ^4.0.0
sentry_flutter: ^8.5.0   # optional, fallback for non-Google distros
logger: ^2.0.0
```

```dart
FlutterError.onError = (d) {
	FirebaseCrashlytics.instance.recordFlutterFatalError(d);
};
PlatformDispatcher.instance.onError = (e, st) {
	FirebaseCrashlytics.instance.recordError(e, st, fatal: true);
	return true;
};
```

Log these events:

| Event | Params |
| --- | --- |
| `login_success` | method |
| `task_created` | project_id, priority |
| `task_moved` | from_status, to_status |
| `comment_added` | task_id |
| `attachment_uploaded` | size_bytes, mime |

---

## 14. CI/CD on Codemagic

`codemagic.yaml` at project root:

```yaml
workflows:
	android-internal:
		name: Android Internal
		instance_type: mac_mini_m2
		environment:
			flutter: stable
			java: 17
			groups: [taskflow_secrets]
		scripts:
			- name: pub get
				script: flutter pub get
			- name: analyze
				script: flutter analyze
			- name: test
				script: flutter test --coverage
			- name: build appbundle
				script: |
					flutter build appbundle --release \
					  --dart-define=API_BASE_URL=$API_BASE_URL
		artifacts:
			- build/**/outputs/bundle/release/*.aab
		publishing:
			google_play:
				credentials: $GCLOUD_SERVICE_ACCOUNT_CREDENTIALS
				track: internal

	ios-testflight:
		name: iOS TestFlight
		instance_type: mac_mini_m2
		integrations:
			app_store_connect: TaskFlow_API_Key
		environment:
			ios_signing:
				distribution_type: app_store
				bundle_identifier: com.taskflow.app
			flutter: stable
		scripts:
			- flutter pub get
			- flutter build ipa --release --dart-define=API_BASE_URL=$API_BASE_URL
		artifacts:
			- build/ios/ipa/*.ipa
		publishing:
			app_store_connect:
				auth: integration
```

Secrets to set in `taskflow_secrets`: `API_BASE_URL`, `GOOGLE_SERVICES_JSON`, `GoogleService-Info.plist`, `keystore.jks`, key passwords.

---

## 15. Release checklist

### Android — Play Console

- [ ]  App ID `com.taskflow.app` reserved.
- [ ]  Upload key + Play app signing.
- [ ]  Privacy policy URL hosted publicly.
- [ ]  Data safety form filled (location: NO; contact info: email; encrypted in transit: YES).
- [ ]  Target API 35 (`compileSdk 35`, `targetSdk 35` in `android/app/build.gradle`).
- [ ]  App content questionnaire submitted.
- [ ]  Internal track → Closed → Production.

### iOS — App Store Connect

- [ ]  Bundle id `com.taskflow.app` registered.
- [ ]  APNs auth key uploaded to Firebase.
- [ ]  App Privacy answers filled (Crashlytics + Analytics declared).
- [ ]  Screenshots: 6.7", 6.5", 5.5" (iPhone) + 12.9" (iPad if shipping).
- [ ]  Export Compliance: `ITSAppUsesNonExemptEncryption=false` in Info.plist (HTTPS only).
- [ ]  TestFlight beta → External testers → Submit for review.

### Both stores

- [ ]  App icon (512×512 + 1024×1024).
- [ ]  Feature graphic 1024×500 (Play).
- [ ]  Localized listings (en + ar).
- [ ]  Versioning: `flutter_version_code` from CI build number.
- [ ]  Force-update mechanism: `/api/v1/app-config` returns `minSupportedVersion`; client compares on cold start.

---

## 16. Sprint plan extension — D22 → D35

| Day | Goal | Deliverable |
| --- | --- | --- |
| D22 | Design system + theming | `AppTheme.light/dark`, tokens, dark-mode toggle in profile |
| D23 | Localization scaffold | `l10n.yaml`, `app_en.arb`, `app_ar.arb`, locale switcher |
| D24 | RTL fixes + Kanban LTR override | Verified Arabic flow + Kanban columns stay To-Do→Done |
| D25 | formz inputs + login/register refactor | EmailInput, PasswordInput, NameInput; cubits use formz |
| D26 | Reusable widgets + skeletons | `AppButton`, `EmptyState`, `SkeletonTile`, `ErrorRetry` |
| D27 | Drift schema + migrations | `AppDb` with Projects, Tasks, SyncQueue tables, build_runner green |
| D28 | Offline-first repos | `TaskRepository.watch/refresh/create` with optimistic insert |
| D29 | SyncWorker + connectivity | Drains queue on reconnect, exponential backoff |
| D30 | SignalR hub client | `NotificationsHub` joins/leaves projects, updates Drift on `TaskUpdated` |
| D31 | FCM bootstrap + deep links | Foreground/background handlers, GoRouter `appRouter.go(deepLink)` |
| D32 | Attachments — pick, compress, upload progress | Working bottom sheet on task detail |
| D33 | Tests — unit + widget goldens | ≥70% coverage on cubits, golden snapshots committed |
| D34 | Crashlytics + Analytics + Codemagic green | First Android internal-track build live |
| D35 | iOS TestFlight + store assets | First TestFlight build invitable, screenshots + privacy filed |

---

## 17. What I still need from you to keep moving

<aside>
❓

1. Final brand colors / logo (or keep indigo/cyan defaults?).

2. Confirm Firebase project + bundle id `com.taskflow.app` is yours.

3. Codemagic vs GitHub Actions — pick one, I'll lock in the YAML.

4. Confirm we're shipping iOS in v1 (impacts Apple Developer Program $99 enrollment timing).

5. Backend SignalR hub group names — confirm `JoinProject(projectId)` and event names `TaskUpdated`, `Notify`.

</aside>

---

## 18. Status

- Part 1 page: live, mapped to OpenAPI spec.
- Part 2 (this page): adds UI/UX, offline, realtime, push, attachments, tests, CI/CD, release.
- Next candidates if you want a Part 3: (a) full code for **every** screen (settings, profile, onboarding, search, filters), (b) widget golden snapshots per screen, (c) backend gap closure (the 9 missing endpoints from Part 1 §17), (d) admin/web companion in Flutter Web.