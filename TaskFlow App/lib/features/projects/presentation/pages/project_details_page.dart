import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:taskflow/core/constants/app_colors.dart';

class ProjectDetailsPage extends StatelessWidget {
  const ProjectDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFBFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFAFBFC),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.primary),
          onPressed: () => context.pop(),
        ),
        title: const Text('Project Details', style: TextStyle(color: AppColors.textPrimaryLight, fontSize: 16)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.more_vert, color: AppColors.textSecondaryLight),
            onPressed: () {},
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: AppColors.primary,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Card
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Text(
                          'IN PROGRESS',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ),
                      const Text(
                        'Updated 2h ago',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondaryLight,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Redesign Mobile App Ecosystem',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimaryLight,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    '68%',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: const LinearProgressIndicator(
                      value: 0.68,
                      backgroundColor: Color(0xFFEBEFF5),
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                      minHeight: 8,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Row(
                    children: [
                      Row(
                        children: [
                          Align(
                            widthFactor: 0.75,
                            alignment: Alignment.centerLeft,
                            child: CircleAvatar(radius: 16, backgroundColor: Colors.orange.shade100, child: const Icon(Icons.person, size: 20)),
                          ),
                          Align(
                            widthFactor: 0.75,
                            alignment: Alignment.centerLeft,
                            child: CircleAvatar(radius: 16, backgroundColor: Colors.teal.shade100, child: const Icon(Icons.person, size: 20)),
                          ),
                          Align(
                            widthFactor: 0.75,
                            alignment: Alignment.centerLeft,
                            child: CircleAvatar(radius: 16, backgroundColor: Colors.amber.shade100, child: const Icon(Icons.person, size: 20)),
                          ),
                          const CircleAvatar(
                            radius: 16,
                            backgroundColor: Color(0xFFEBEFF5),
                            child: Text('+3', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondaryLight)),
                          ),
                        ],
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Design Squad', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                            const SizedBox(height: 2),
                            Text('6 active contributors', style: TextStyle(fontSize: 12, color: AppColors.textSecondaryLight.withValues(alpha: 0.8))),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () {
                        context.push('/invite-member');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: const Text('Invite Members', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Tabs Row
            Row(
              children: [
                Column(
                  children: [
                    Text(
                      'Active Tasks',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    SizedBox(height: 8),
                    Container(width: 80, height: 3, color: AppColors.primary),
                  ],
                ),
                const SizedBox(width: 24),
                Column(
                  children: [
                    Text(
                      'Completed',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondaryLight,
                      ),
                    ),
                    SizedBox(height: 11),
                  ],
                ),
                const Spacer(),
                Row(
                  children: [
                    Icon(Icons.filter_list, size: 18, color: AppColors.primary),
                    const SizedBox(width: 4),
                    const Text('Filter', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600)),
                  ],
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Active Tasks List
            _buildActiveTaskCard(
              priority: 'HIGH PRIORITY',
              priorityColor: AppColors.error,
              title: 'Finalize Design Tokens',
              description: 'Standardize all color variables and typography scales across the system for...',
              date: 'Oct 24, 2023',
            ),
            const SizedBox(height: 16),
            _buildActiveTaskCard(
              priority: 'MEDIUM',
              priorityColor: AppColors.primary,
              title: 'Review Component Hierarchy',
              description: 'Audit the structural layout and nesting rules of existing shared components.',
              date: 'Oct 26, 2023',
            ),
            
            const SizedBox(height: 32),
            
            const Text(
              'COMPLETED RECENTLY',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.0,
                color: AppColors.textSecondaryLight,
              ),
            ),
            const SizedBox(height: 16),
            
            // Completed Tasks List
            _buildCompletedTaskCard(
              title: 'Moodboard Approval',
              subtitle: 'Completed by Sarah Jenkins',
              time: 'Yesterday',
            ),
            const SizedBox(height: 12),
            _buildCompletedTaskCard(
              title: 'Information Architecture Draft',
              subtitle: 'Completed by David Chen',
              time: '2 days ago',
            ),
            
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveTaskCard({
    required String priority,
    required Color priorityColor,
    required String title,
    required String description,
    required String date,
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
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(width: 6, height: 6, decoration: BoxDecoration(color: priorityColor, shape: BoxShape.circle)),
                  const SizedBox(width: 8),
                  Text(
                    priority,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: priorityColor,
                      letterSpacing: 1.0,
                    ),
                  ),
                ],
              ),
              Icon(Icons.more_horiz, color: AppColors.textSecondaryLight),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimaryLight,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondaryLight,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.calendar_today_outlined, size: 14, color: AppColors.textSecondaryLight),
                  const SizedBox(width: 6),
                  Text(date, style: const TextStyle(fontSize: 12, color: AppColors.textSecondaryLight)),
                ],
              ),
              const CircleAvatar(radius: 12, backgroundColor: Colors.teal, child: Icon(Icons.person, size: 14, color: Colors.white)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCompletedTaskCard({
    required String title,
    required String subtitle,
    required String time,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFAFBFC),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.check, size: 16, color: AppColors.primary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimaryLight,
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondaryLight,
                  ),
                ),
              ],
            ),
          ),
          Text(
            time,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondaryLight,
            ),
          ),
        ],
      ),
    );
  }
}

