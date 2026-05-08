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
      builder: (context, state) => const CreateTaskPage(),
    ),
    GoRoute(
      path: '/task-details',
      builder: (context, state) => const TaskDetailsPage(),
    ),
    GoRoute(
      path: '/create-project',
      builder: (context, state) => const CreateProjectPage(),
    ),
    GoRoute(
      path: '/project-details',
      builder: (context, state) => const ProjectDetailsPage(),
    ),
    GoRoute(
      path: '/invite-member',
      builder: (context, state) => const InviteMemberPage(),
    ),
    GoRoute(
      path: '/admin',
      builder: (context, state) => const AdminDashboard(),
    ),
  ],
);

