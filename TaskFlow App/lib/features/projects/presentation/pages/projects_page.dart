import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:taskflow/core/constants/app_colors.dart';
import 'package:taskflow/core/di/injection.dart';
import '../bloc/projects_bloc.dart';
import '../../data/models/project_models.dart';

class ProjectsPage extends StatelessWidget {
  const ProjectsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<ProjectsBloc>()..add(LoadProjectsRequested()),
      child: Scaffold(
        backgroundColor: AppColors.backgroundLight,
        body: BlocBuilder<ProjectsBloc, ProjectsState>(
          builder: (context, state) {
            return CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                  sliver: SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'All Projects',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                            color: AppColors.textPrimaryLight,
                            letterSpacing: -1,
                          ),
                        ).animate().fadeIn().slideX(begin: -0.1),
                        const SizedBox(height: 8),
                        Text(
                          state is ProjectsLoaded 
                            ? 'You have ${state.projects.length} active projects'
                            : 'Loading projects...',
                          style: TextStyle(
                            fontSize: 16,
                            color: AppColors.textSecondaryLight.withValues(alpha: 0.8),
                            fontWeight: FontWeight.w500,
                          ),
                        ).animate().fadeIn(delay: 100.ms).slideX(begin: -0.1),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
                
                if (state is ProjectsLoading)
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    sliver: SliverGrid(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        mainAxisExtent: 220,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => _buildShimmerCard(),
                        childCount: 4,
                      ),
                    ),
                  )
                else if (state is ProjectsFailure)
                  SliverFillRemaining(
                    child: Center(child: Text(state.message)),
                  )
                else if (state is ProjectsLoaded)
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 120),
                    sliver: SliverGrid(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        mainAxisExtent: 220,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final project = state.projects[index];
                          return _buildProjectCard(
                            context: context,
                            title: project.name,
                            tasks: project.taskCount,
                            progress: project.completionPercentage / 100,
                            color: _getColorForIndex(index),
                            icon: _getIconForIndex(index),
                            delay: 200 + (index * 100),
                          );
                        },
                        childCount: state.projects.length,
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Color _getColorForIndex(int index) {
    final colors = [AppColors.primary, AppColors.secondary, AppColors.accent, AppColors.warning];
    return colors[index % colors.length];
  }

  IconData _getIconForIndex(int index) {
    final icons = [Icons.brush_rounded, Icons.smartphone_rounded, Icons.language_rounded, Icons.campaign_rounded];
    return icons[index % icons.length];
  }

  Widget _buildShimmerCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.borderLight, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(width: 44, height: 44, decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(14))),
          const Spacer(),
          Container(width: 100, height: 20, color: Colors.grey[200]),
          const SizedBox(height: 8),
          Container(width: 60, height: 14, color: Colors.grey[200]),
          const SizedBox(height: 20),
          Container(width: 30, height: 12, color: Colors.grey[200]),
          const SizedBox(height: 8),
          Container(width: double.infinity, height: 6, color: Colors.grey[200]),
        ],
      ),
    );
  }

  Widget _buildProjectCard({
    required BuildContext context,
    required String title,
    required int tasks,
    required double progress,
    required Color color,
    required IconData icon,
    required int delay,
  }) {
    return GestureDetector(
      onTap: () => context.push('/project-details'),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: AppColors.borderLight, width: 1),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.05),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const Spacer(),
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: AppColors.textPrimaryLight,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '$tasks Tasks',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textSecondaryLight.withValues(alpha: 0.6),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${(progress * 100).toInt()}%',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: color.withValues(alpha: 0.1),
                valueColor: AlwaysStoppedAnimation<Color>(color),
                minHeight: 6,
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: delay.ms).scale(curve: Curves.easeOutBack);
  }
}

