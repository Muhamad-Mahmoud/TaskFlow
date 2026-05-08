import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:taskflow/core/constants/app_colors.dart';
import 'package:taskflow/core/di/injection.dart';
import '../bloc/projects_bloc.dart';
import '../../data/models/project_models.dart';

class ProjectsPage extends StatefulWidget {
  const ProjectsPage({super.key});

  @override
  State<ProjectsPage> createState() => _ProjectsPageState();
}

class _ProjectsPageState extends State<ProjectsPage> {
  late ProjectsBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = getIt<ProjectsBloc>()..add(LoadProjectsRequested());
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  void _refresh() {
    _bloc.add(LoadProjectsRequested());
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bloc,
      child: Scaffold(
        backgroundColor: AppColors.backgroundLight,
        body: BlocBuilder<ProjectsBloc, ProjectsState>(
          buildWhen: (prev, curr) =>
              curr is ProjectsLoading ||
              curr is ProjectsLoaded ||
              curr is ProjectsFailure,
          builder: (context, state) {
            return RefreshIndicator(
              color: AppColors.primary,
              onRefresh: () async => _refresh(),
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics()),
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
                                ? '${state.projects.length} active project${state.projects.length != 1 ? 's' : ''}'
                                : 'Loading projects...',
                            style: TextStyle(
                              fontSize: 16,
                              color: AppColors.textSecondaryLight
                                  .withValues(alpha: 0.8),
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
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
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
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.error_outline,
                                color: AppColors.error, size: 48),
                            const SizedBox(height: 16),
                            Text(state.message,
                                style: const TextStyle(
                                    color: AppColors.textSecondaryLight)),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _refresh,
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.white),
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      ),
                    )
                  else if (state is ProjectsLoaded)
                    state.projects.isEmpty
                        ? SliverFillRemaining(
                            child: Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.folder_open,
                                      size: 64,
                                      color: AppColors.primary
                                          .withValues(alpha: 0.3)),
                                  const SizedBox(height: 16),
                                  const Text('No projects yet',
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.textSecondaryLight)),
                                  const SizedBox(height: 8),
                                  const Text('Tap + to create a project',
                                      style: TextStyle(
                                          color: AppColors.textSecondaryLight)),
                                ],
                              ),
                            ),
                          )
                        : SliverPadding(
                            padding:
                                const EdgeInsets.fromLTRB(24, 0, 24, 120),
                            sliver: SliverGrid(
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
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
                                    project: project,
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
              ),
            );
          },
        ),
      ),
    );
  }

  Color _getColorForIndex(int index) {
    final colors = [
      AppColors.primary,
      AppColors.secondary,
      AppColors.accent,
      AppColors.warning
    ];
    return colors[index % colors.length];
  }

  IconData _getIconForIndex(int index) {
    final icons = [
      Icons.brush_rounded,
      Icons.smartphone_rounded,
      Icons.language_rounded,
      Icons.campaign_rounded
    ];
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
          Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(14))),
          const Spacer(),
          Container(width: 100, height: 20, color: Colors.grey[200]),
          const SizedBox(height: 8),
          Container(width: 60, height: 14, color: Colors.grey[200]),
          const SizedBox(height: 20),
          Container(width: double.infinity, height: 6, color: Colors.grey[200]),
        ],
      ),
    );
  }

  Widget _buildProjectCard({
    required BuildContext context,
    required ProjectSummary project,
    required Color color,
    required IconData icon,
    required int delay,
  }) {
    final progress = (project.completionPercentage / 100).clamp(0.0, 1.0);

    return GestureDetector(
      onTap: () => context
          .push('/project-details', extra: {'projectId': project.id})
          .then((_) => _refresh()),
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
              project.name,
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
              '${project.taskCount} task${project.taskCount != 1 ? 's' : ''}',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textSecondaryLight.withValues(alpha: 0.6),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
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
                Text(
                  '${project.memberCount} 👥',
                  style: const TextStyle(
                      fontSize: 11, color: AppColors.textSecondaryLight),
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
      ).animate().fadeIn(delay: delay.ms).scale(curve: Curves.easeOutBack),
    );
  }
}
