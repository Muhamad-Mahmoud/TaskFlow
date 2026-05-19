import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/tasks/presentation/pages/tasks_page.dart';
import '../../features/projects/presentation/pages/projects_page.dart';
import '../../features/profile/presentation/pages/settings_page.dart';
import '../../../core/constants/app_colors.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _currentIndex = 0;

  // Keys allow us to call refresh methods on the child pages.
  final _homeKey = GlobalKey<HomePageState>();
  final _tasksKey = GlobalKey<TasksPageState>();
  final _projectsKey = GlobalKey<ProjectsPageState>();

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      HomePage(key: _homeKey),
      TasksPage(key: _tasksKey),
      ProjectsPage(key: _projectsKey),
      const SettingsPage(),
    ];
  }

  void _refreshCurrentPage() {
    if (_currentIndex == 0) {
      _homeKey.currentState?.refresh();
    } else if (_currentIndex == 1) {
      _tasksKey.currentState?.refresh();
    } else if (_currentIndex == 2) {
      _projectsKey.currentState?.refresh();
    }
  }

  static const _tabTitles = ['TaskFlow', 'My Tasks', 'Projects', 'Settings'];
  static const _tabIcons = [
    Icons.grid_view_rounded,
    Icons.task_alt_rounded,
    Icons.folder_copy_rounded,
    Icons.settings_rounded,
  ];
  static const _tabLabels = ['Home', 'Tasks', 'Projects', 'Settings'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: _buildAppBar(),
      body: Stack(
        children: [
          // Use IndexedStack to preserve state between tabs
          IndexedStack(
            index: _currentIndex,
            children: _pages,
          ),
          
          // Floating Bottom Navigation
          Positioned(
            left: 20,
            right: 20,
            bottom: 30,
            child: Container(
              height: 72,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white.withValues(alpha: 0.2), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: List.generate(
                    4,
                    (i) => _buildNavItem(i, _tabIcons[i], _tabLabels[i]),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 90.0),
        child: FloatingActionButton(
          onPressed: () async {
            if (_currentIndex == 2) {
              await context.push('/create-project');
            } else {
              await context.push('/create-task');
            }
            _refreshCurrentPage();
          },
          backgroundColor: AppColors.primary,
          elevation: 8,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: const Icon(Icons.add, color: Colors.white, size: 32),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    if (_currentIndex == 0) return _buildHomeAppBar();
    return AppBar(
      backgroundColor: AppColors.backgroundLight,
      scrolledUnderElevation: 0,
      elevation: 0,
      title: Text(
        _tabTitles[_currentIndex],
        style: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w900,
          color: AppColors.textPrimaryLight,
          letterSpacing: -0.5,
        ),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Divider(height: 1, color: AppColors.borderLight.withValues(alpha: 0.5)),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () {
        if (_currentIndex == index) {
          _refreshCurrentPage();
        } else {
          setState(() => _currentIndex = index);
          _refreshCurrentPage();
        }
      },
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary.withValues(alpha: 0.1) : Colors.transparent,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              icon,
              color: isSelected ? AppColors.primary : AppColors.textSecondaryLight,
              size: 26,
            ),
          ),
          const SizedBox(height: 4),
          if (isSelected)
            Container(
              width: 4,
              height: 4,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
            ).animate().scale(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildHomeAppBar() {
    return AppBar(
      title: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primary, AppColors.primaryLight],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.account_tree_rounded, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 12),
          const Text(
            'TaskFlow',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: AppColors.textPrimaryLight,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_none_rounded, color: AppColors.textPrimaryLight),
          onPressed: () {},
        ),
        const SizedBox(width: 8),
        const CircleAvatar(
          radius: 18,
          backgroundColor: AppColors.borderLight,
          child: Icon(Icons.person_rounded, color: AppColors.textSecondaryLight, size: 22),
        ),
        const SizedBox(width: 16),
      ],
    );
  }
}

