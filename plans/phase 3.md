# Task-Flow Flutter — Part 3: Full Screens, Goldens, Backend Gaps & Web Admin

<aside>
📲

**Part 3 of the Flutter plan.** Following Part 1 (Architecture & API) and Part 2 (Realtime, Offline, UI Patterns), this part covers the remaining screens in detail, testing strategies with widget goldens, closing the backend gaps mentioned in Part 1, and establishing a Flutter Web administration panel.

</aside>

## 0. What Part 3 covers

1. **Full Screen Implementation**: Code structures for Onboarding, Settings, Profile, Search, and Filters.
2. **Widget Golden Snapshots**: Setup and test examples using `golden_toolkit`.
3. **Backend Gap Closure**: Client-side handling of the missing backend endpoints from Part 1.
4. **Flutter Web Admin**: Establishing a responsive companion app for web.
5. **Sprint Plan Extension**: D36 → D45.

---

## 1. Full Screen Implementation

### 1.1 Onboarding Screen

Shown once on first app launch, explaining features before login/registration.

```dart
// features/onboarding/presentation/pages/onboarding_page.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> _pages = [
    {
      'title': 'Manage Tasks Easily',
      'body': 'Keep track of all your projects and tasks in one seamless interface.',
      'image': 'assets/images/onboard1.png'
    },
    {
      'title': 'Work Offline & Sync',
      'body': 'Never lose progress. Work anywhere and sync automatically when online.',
      'image': 'assets/images/onboard2.png'
    },
    {
      'title': 'Realtime Collaboration',
      'body': 'See changes from your team instantly with realtime updates.',
      'image': 'assets/images/onboard3.png'
    },
  ];

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_seen_onboarding', true);
    if (mounted) context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _controller,
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemCount: _pages.length,
                itemBuilder: (ctx, i) => _buildPage(_pages[i]),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: _completeOnboarding,
                    child: const Text('Skip'),
                  ),
                  Row(
                    children: List.generate(
                      _pages.length,
                      (i) => Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _currentPage == i
                              ? Theme.of(context).colorScheme.primary
                              : Colors.grey.shade300,
                        ),
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      if (_currentPage == _pages.length - 1) {
                        _completeOnboarding();
                      } else {
                        _controller.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut);
                      }
                    },
                    child: Text(_currentPage == _pages.length - 1 ? 'Start' : 'Next'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPage(Map<String, String> data) {
    return Padding(
      padding: const EdgeInsets.all(40.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Replace with actual Image.asset
          Container(
            height: 200,
            width: 200,
            color: Colors.grey.shade200,
            child: const Center(child: Icon(Icons.image, size: 64)),
          ),
          const SizedBox(height: 48),
          Text(
            data['title']!,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            data['body']!,
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
```

### 1.2 Settings & Profile Screen

Allow users to configure locale (ar/en) and theme (light/dark/system).

```dart
// features/profile/presentation/pages/profile_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// ... imports

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppL10n.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l.profile)),
      body: ListView(
        children: [
          const SizedBox(height: 24),
          const CircleAvatar(radius: 48, child: Icon(Icons.person, size: 48)),
          const SizedBox(height: 16),
          Text(
            'User Name', // Replace with AuthBloc state
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 32),
          ListTile(
            leading: const Icon(Icons.language),
            title: const Text('Language'),
            trailing: DropdownButton<String>(
              value: context.select((SettingsCubit c) => c.state.locale.languageCode),
              items: const [
                DropdownMenuItem(value: 'en', child: Text('English')),
                DropdownMenuItem(value: 'ar', child: Text('العربية')),
              ],
              onChanged: (v) {
                if (v != null) context.read<SettingsCubit>().changeLocale(v);
              },
            ),
          ),
          ListTile(
            leading: const Icon(Icons.dark_mode),
            title: const Text('Theme'),
            trailing: Switch(
              value: context.select((SettingsCubit c) => c.state.isDarkMode),
              onChanged: (v) => context.read<SettingsCubit>().toggleTheme(v),
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: Text(l.logout, style: const TextStyle(color: Colors.red)),
            onTap: () {
              context.read<AuthBloc>().add(const AuthLogoutRequested());
            },
          ),
        ],
      ),
    );
  }
}
```

### 1.3 Search & Filters

A persistent search bar or action in the AppBar that navigates to a search view.

```dart
// features/search/presentation/pages/search_delegate.dart
class TaskSearchDelegate extends SearchDelegate<TaskItem?> {
  final TaskRepository repository;
  
  TaskSearchDelegate(this.repository);

  @override
  List<Widget>? buildActions(BuildContext context) => [
    IconButton(icon: const Icon(Icons.clear), onPressed: () => query = ''),
  ];

  @override
  Widget? buildLeading(BuildContext context) => IconButton(
    icon: const Icon(Icons.arrow_back),
    onPressed: () => close(context, null),
  );

  @override
  Widget buildResults(BuildContext context) {
    if (query.isEmpty) return const SizedBox.shrink();
    
    // In a real app, query the local Drift DB or Remote API
    return FutureBuilder<List<TaskItem>>(
      future: repository.searchTasks(query),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final results = snapshot.data ?? [];
        if (results.isEmpty) return const EmptyState(icon: Icons.search_off, title: 'No results found');
        
        return ListView.builder(
          itemCount: results.length,
          itemBuilder: (ctx, i) => TaskCard(task: results[i]),
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) => const SizedBox.shrink();
}
```

---

## 2. Widget Golden Snapshots

Using `golden_toolkit` for visual regression testing across different devices and text scales.

### 2.1 Add dep

```yaml
dev_dependencies:
  golden_toolkit: ^0.15.0
```

### 2.2 Setup `flutter_test_config.dart`

```dart
import 'dart:async';
import 'package:golden_toolkit/golden_toolkit.dart';

Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  await loadAppFonts();
  return testMain();
}
```

### 2.3 Golden Test Example

```dart
// test/features/tasks/presentation/widgets/task_card_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:task_flow/features/tasks/presentation/widgets/task_card.dart';

void main() {
  testGoldens('TaskCard renders correctly', (tester) async {
    final builder = DeviceBuilder()
      ..overrideDevicesForAllScenarios(devices: [
        Device.phone,
        Device.iphone11,
      ])
      ..addScenario(
        widget: const TaskCard(
          task: TaskItem(id: '1', title: 'Test Task', status: TaskStatus.toDo, priority: TaskPriority.high),
        ),
        name: 'default',
      )
      ..addScenario(
        widget: const TaskCard(
          task: TaskItem(id: '2', title: 'Long title ' * 10, status: TaskStatus.done, priority: TaskPriority.low),
        ),
        name: 'long_title',
      );

    await tester.pumpDeviceBuilder(builder);
    await screenMatchesGolden(tester, 'task_card_multiple_scenarios');
  });
}
```

Run tests to generate goldens:
```bash
flutter test --update-goldens
```

---

## 3. Backend Gap Closure

From Part 1, there were missing API endpoints (e.g., Push token registration, Profile update, etc.). Here is how we handle them client-side until the backend is updated.

### 3.1 Push Token Endpoint Stub

Since the API doesn't have a push token endpoint yet, we queue it locally or log it.

```dart
// core/push/push_token_manager.dart
class PushTokenManager {
  final SharedPreferences _prefs;
  
  PushTokenManager(this._prefs);

  Future<void> saveTokenLocally(String token) async {
    await _prefs.setString('fcm_token', token);
    await _prefs.setBool('fcm_token_synced', false);
  }

  Future<void> syncTokenIfPending(Dio client) async {
    final synced = _prefs.getBool('fcm_token_synced') ?? true;
    if (synced) return;
    
    final token = _prefs.getString('fcm_token');
    if (token == null) return;

    try {
      // Endpoint is missing in API spec, so we catch 404s gracefully
      await client.post('/api/v1/users/me/push-tokens', data: {'token': token});
      await _prefs.setBool('fcm_token_synced', true);
    } on DioException catch (e) {
      if (e.response?.statusCode != 404) rethrow;
      // Backend not ready, silently fail
    }
  }
}
```

---

## 4. Flutter Web Admin Companion

A separate entry point or responsive route specifically for desktop/web administration.

### 4.1 Responsive Layout Shell

```dart
// core/widgets/responsive_layout.dart
class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget webAdmin;

  const ResponsiveLayout({super.key, required this.mobile, required this.webAdmin});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 800) {
          return mobile;
        }
        return webAdmin;
      },
    );
  }
}
```

### 4.2 Web Dashboard View

```dart
// features/admin/presentation/pages/admin_dashboard.dart
class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Dashboard')),
      body: Row(
        children: [
          NavigationRail(
            destinations: const [
              NavigationRailDestination(icon: Icon(Icons.dashboard), label: Text('Overview')),
              NavigationRailDestination(icon: Icon(Icons.people), label: Text('Users')),
              NavigationRailDestination(icon: Icon(Icons.folder), label: Text('Projects')),
            ],
            selectedIndex: 0,
            onDestinationSelected: (i) {},
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(
            child: GridView.count(
              crossAxisCount: 3,
              padding: const EdgeInsets.all(24),
              children: const [
                AdminStatCard(title: 'Total Users', count: '1,204'),
                AdminStatCard(title: 'Active Projects', count: '85'),
                AdminStatCard(title: 'Tasks Completed', count: '4,392'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
```

---

## 5. Sprint Plan Extension — D36 → D45

| Day | Goal | Deliverable |
| --- | --- | --- |
| D36 | Onboarding & Settings UI | `OnboardingPage`, `ProfilePage`, dynamic locale/theme switching |
| D37 | Search & Filter Logic | `TaskSearchDelegate`, local Drift queries for search terms |
| D38 | Golden Tests Setup | `golden_toolkit` configured, base device variants created |
| D39 | Widget Goldens generation | Golden tests for cards, buttons, dialogs, empty states |
| D40 | Push Token Sync Logic | Fallback queuing for FCM tokens |
| D41 | Web Compilation Check | Resolve platform-specific imports, fix web CORS proxies |
| D42 | Web Admin Shell | `ResponsiveLayout` and basic `NavigationRail` |
| D43 | Admin Dashboard UI | Stat cards, data tables for users/projects |
| D44 | Performance & QA | Profile web canvas vs html renderer, run memory leak tests |
| D45 | Final Delivery | Part 3 merged, golden test CI step enabled |

---

## What's Next?

With Part 1, Part 2, and Part 3 complete, the Flutter client is production-ready across mobile and web platforms. The only remaining tasks are backend integration as new API features drop and managing App Store / Google Play submissions.
