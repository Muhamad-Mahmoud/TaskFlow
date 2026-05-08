import 'package:flutter/material.dart';
import 'package:taskflow/core/constants/app_colors.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFBFC),
      appBar: AppBar(
        title: const Text('Admin Dashboard', style: TextStyle(color: AppColors.textPrimaryLight, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: AppColors.textPrimaryLight),
      ),
      body: Row(
        children: [
          NavigationRail(
            backgroundColor: Colors.white,
            selectedIconTheme: const IconThemeData(color: AppColors.primary),
            selectedLabelTextStyle: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
            unselectedIconTheme: const IconThemeData(color: AppColors.textSecondaryLight),
            destinations: const [
              NavigationRailDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard), label: Text('Overview')),
              NavigationRailDestination(icon: Icon(Icons.people_outline), selectedIcon: Icon(Icons.people), label: Text('Users')),
              NavigationRailDestination(icon: Icon(Icons.folder_outlined), selectedIcon: Icon(Icons.folder), label: Text('Projects')),
              NavigationRailDestination(icon: Icon(Icons.settings_outlined), selectedIcon: Icon(Icons.settings), label: Text('Settings')),
            ],
            selectedIndex: _selectedIndex,
            onDestinationSelected: (i) => setState(() => _selectedIndex = i),
            extended: MediaQuery.of(context).size.width > 1200,
          ),
          const VerticalDivider(thickness: 1, width: 1, color: AppColors.borderLight),
          Expanded(
            child: _buildBody(),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return _buildOverview();
      case 1:
        return const Center(child: Text('Users Management'));
      case 2:
        return const Center(child: Text('Projects Management'));
      case 3:
        return const Center(child: Text('System Settings'));
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildOverview() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'System Overview',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textPrimaryLight),
          ),
          const SizedBox(height: 24),
          GridView.count(
            crossAxisCount: MediaQuery.of(context).size.width > 1000 ? 3 : 2,
            crossAxisSpacing: 24,
            mainAxisSpacing: 24,
            shrinkWrap: true,
            childAspectRatio: 2.5,
            physics: const NeverScrollableScrollPhysics(),
            children: const [
              AdminStatCard(title: 'Total Users', count: '1,204', icon: Icons.people, color: Colors.blue),
              AdminStatCard(title: 'Active Projects', count: '85', icon: Icons.folder, color: Colors.deepPurple),
              AdminStatCard(title: 'Tasks Completed', count: '4,392', icon: Icons.check_circle, color: Colors.green),
              AdminStatCard(title: 'System Health', count: '99.9%', icon: Icons.monitor_heart, color: Colors.teal),
            ],
          ),
        ],
      ),
    );
  }
}

class AdminStatCard extends StatelessWidget {
  final String title;
  final String count;
  final IconData icon;
  final Color color;

  const AdminStatCard({
    super.key,
    required this.title,
    required this.count,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 32),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 14, color: AppColors.textSecondaryLight),
                ),
                const SizedBox(height: 4),
                Text(
                  count,
                  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.textPrimaryLight),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

