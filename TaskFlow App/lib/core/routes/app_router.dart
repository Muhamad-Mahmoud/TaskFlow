import 'package:go_router/go_router.dart';
import '../../features/onboarding/presentation/pages/onboarding_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/signup_page.dart';
import '../../features/onboarding/presentation/pages/welcome_page.dart';
import '../../features/tasks/presentation/pages/create_task_page.dart';
import '../../features/tasks/presentation/pages/task_details_page.dart';
import '../../features/projects/presentation/pages/create_project_page.dart';
import '../../features/projects/presentation/pages/project_details_page.dart';
import '../../features/projects/presentation/pages/invite_member_page.dart';
import '../../features/admin/presentation/pages/admin_dashboard.dart';
import '../widgets/app_shell.dart';

final appRouter = GoRouter(
  initialLocation: '/onboarding',
  routes: [
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingPage(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: '/signup',
      builder: (context, state) => const SignupPage(),
    ),
    GoRoute(
      path: '/welcome',
      builder: (context, state) => const WelcomePage(),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => const AppShell(),
    ),
    GoRoute(
      path: '/create-task',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        final projectId = extra?['projectId'] as String?;
        final taskToEdit = extra?['taskToEdit'];
        return CreateTaskPage(
          preselectedProjectId: projectId,
          taskToEdit: taskToEdit,
        );
      },
    ),
    GoRoute(
      path: '/task-details',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        final taskId = extra?['taskId'] as String?;
        return TaskDetailsPage(taskId: taskId);
      },
    ),
    GoRoute(
      path: '/create-project',
      builder: (context, state) => const CreateProjectPage(),
    ),
    GoRoute(
      path: '/project-details',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        final projectId = extra?['projectId'] as String? ?? '';
        return ProjectDetailsPage(projectId: projectId);
      },
    ),
    GoRoute(
      path: '/invite-member',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        final projectId = extra?['projectId'] as String? ?? '';
        return InviteMemberPage(projectId: projectId);
      },
    ),
    GoRoute(
      path: '/admin',
      builder: (context, state) => const AdminDashboard(),
    ),
  ],
);
