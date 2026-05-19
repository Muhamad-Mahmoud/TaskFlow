import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:taskflow/core/constants/app_colors.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool pushNotifications = true;
  bool emailDigests = false;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24.0, 24.0, 24.0, 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Profile Header
          Row(
            children: [
              Stack(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.teal.shade200,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: const Center(
                      child: Icon(Icons.person, size: 64, color: Colors.white),
                    ),
                  ),
                  Positioned(
                    bottom: -5,
                    right: -5,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.edit, color: Colors.white, size: 14),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Alex Thorne',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimaryLight,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'alex.thorne@taskflow.io',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondaryLight,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'PRO PLAN',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 48),
          
          // Notification Preferences
          Row(
            children: [
              Icon(Icons.notifications, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                'NOTIFICATION PREFERENCES',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  color: AppColors.textSecondaryLight.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Push Notifications', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                  subtitle: const Text('Receive real-time alerts for task updates', style: TextStyle(fontSize: 13, color: AppColors.textSecondaryLight)),
                  value: pushNotifications,
                  onChanged: (v) => setState(() => pushNotifications = v),
                  activeThumbColor: Colors.white,
                  activeTrackColor: AppColors.primary,
                  inactiveThumbColor: Colors.white,
                  inactiveTrackColor: AppColors.borderLight,
                  contentPadding: const EdgeInsets.all(16),
                ),
                Divider(height: 1, color: AppColors.borderLight),
                SwitchListTile(
                  title: const Text('Email Digests', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                  subtitle: const Text('Weekly summary of project progress', style: TextStyle(fontSize: 13, color: AppColors.textSecondaryLight)),
                  value: emailDigests,
                  onChanged: (v) => setState(() => emailDigests = v),
                  activeThumbColor: Colors.white,
                  activeTrackColor: AppColors.primary,
                  inactiveThumbColor: Colors.white,
                  inactiveTrackColor: AppColors.borderLight,
                  contentPadding: const EdgeInsets.all(16),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 40),
          
          // Workspace Settings
          Row(
            children: [
              Icon(Icons.workspaces, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                'WORKSPACE SETTINGS',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  color: AppColors.textSecondaryLight.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSettingsTile(
            icon: Icons.payments_outlined,
            iconColor: AppColors.primary,
            title: 'Billing & Subscription',
            subtitle: 'Manage your plans and invoices',
          ),
          const SizedBox(height: 16),
          _buildSettingsTile(
            icon: Icons.shield_outlined,
            iconColor: AppColors.secondary,
            title: 'Privacy & Security',
            subtitle: 'Passwords and authentication',
          ),
          
          const SizedBox(height: 48),
          
          OutlinedButton.icon(
            onPressed: () {
              context.go('/login');
            },
            icon: Icon(Icons.logout, color: AppColors.error),
            label: const Text('Sign Out', style: TextStyle(color: AppColors.error, fontSize: 16, fontWeight: FontWeight.w600)),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              side: BorderSide(color: AppColors.error.withValues(alpha: 0.5)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
            ),
          ),
          
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                const SizedBox(height: 4),
                Text(subtitle, style: const TextStyle(fontSize: 13, color: AppColors.textSecondaryLight)),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: AppColors.textSecondaryLight),
        ],
      ),
    );
  }
}

