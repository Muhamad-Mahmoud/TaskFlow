import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:taskflow/core/constants/app_colors.dart';
import 'package:taskflow/core/di/injection.dart';
import '../bloc/tasks_bloc.dart';
import '../../domain/models/task_models.dart';
import 'package:intl/intl.dart';

class TasksPage extends StatelessWidget {
  final String? projectId;
  const TasksPage({super.key, this.projectId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<TasksBloc>()..add(LoadTasksRequested(projectId: projectId)),
      child: Scaffold(
        backgroundColor: AppColors.backgroundLight,
        body: BlocBuilder<TasksBloc, TasksState>(
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
                        Text(
                          projectId != null ? 'Project Tasks' : 'Daily Tasks',
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                            color: AppColors.textPrimaryLight,
                            letterSpacing: -1,
                          ),
                        ).animate().fadeIn().slideX(begin: -0.1),
                        const SizedBox(height: 8),
                        Text(
                          DateFormat('EEEE, d MMMM').format(DateTime.now()),
                          style: TextStyle(
                            fontSize: 16,
                            color: AppColors.textSecondaryLight.withValues(alpha: 0.8),
                            fontWeight: FontWeight.w600,
                          ),
                        ).animate().fadeIn(delay: 100.ms).slideX(begin: -0.1),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),

                if (state is TasksLoading)
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => _buildShimmerItem(),
                        childCount: 5,
                      ),
                    ),
                  )
                else if (state is TasksFailure)
                  SliverFillRemaining(
                    child: Center(child: Text(state.message)),
                  )
                else if (state is TasksLoaded)
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 120),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final task = state.tasks[index];
                          return _buildTaskItem(
                            title: task.title,
                            status: task.status ?? 'To Do',
                            isCompleted: task.status == 'Completed',
                            delay: 200 + (index * 100),
                          );
                        },
                        childCount: state.tasks.length,
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

  Widget _buildShimmerItem() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.borderLight, width: 1),
      ),
      child: Row(
        children: [
          Container(width: 28, height: 28, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.grey[200])),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(width: 200, height: 18, color: Colors.grey[200]),
                const SizedBox(height: 8),
                Container(width: 100, height: 14, color: Colors.grey[200]),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskItem({
    required String title,
    required String status,
    required bool isCompleted,
    required int delay,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isCompleted ? Colors.white.withValues(alpha: 0.6) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isCompleted ? Colors.transparent : AppColors.borderLight,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isCompleted ? AppColors.success : Colors.transparent,
              border: Border.all(
                color: isCompleted ? AppColors.success : AppColors.borderLight,
                width: 2,
              ),
            ),
            child: isCompleted 
              ? const Icon(Icons.check, color: AppColors.success, size: 18)
              : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: isCompleted ? AppColors.textSecondaryLight : AppColors.textPrimaryLight,
                    decoration: isCompleted ? TextDecoration.lineThrough : null,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  status,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondaryLight.withValues(alpha: 0.6),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: delay.ms).slideX(begin: 0.1);
  }
}

