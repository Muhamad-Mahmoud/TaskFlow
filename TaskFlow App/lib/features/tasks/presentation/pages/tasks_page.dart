import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:taskflow/core/constants/app_colors.dart';
import 'package:taskflow/core/di/injection.dart';
import '../bloc/tasks_bloc.dart';
import '../../domain/models/task_models.dart';
import 'package:intl/intl.dart';

class TasksPage extends StatefulWidget {
  final String? projectId;
  const TasksPage({super.key, this.projectId});

  @override
  State<TasksPage> createState() => TasksPageState();
}

class TasksPageState extends State<TasksPage> {
  late TasksBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = getIt<TasksBloc>()..add(LoadTasksRequested(projectId: widget.projectId));
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  void _refresh() {
    _bloc.add(LoadTasksRequested(projectId: widget.projectId));
  }

  // Public method callable from AppShell via GlobalKey
  void refresh() => _refresh();

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bloc,
      child: Scaffold(
        backgroundColor: AppColors.backgroundLight,
        body: BlocBuilder<TasksBloc, TasksState>(
          builder: (context, state) {
            return RefreshIndicator(
              color: AppColors.primary,
              onRefresh: () async => _refresh(),
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                slivers: [
                  if (widget.projectId == null)
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                      sliver: SliverToBoxAdapter(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              DateFormat('EEEE, d MMMM').format(DateTime.now()),
                              style: TextStyle(
                                fontSize: 15,
                                color: AppColors.textSecondaryLight.withValues(alpha: 0.8),
                                fontWeight: FontWeight.w600,
                              ),
                            ).animate().fadeIn(delay: 100.ms).slideX(begin: -0.1),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),
                  if (widget.projectId != null)
                    const SliverPadding(padding: EdgeInsets.only(top: 24)),

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
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.error_outline, color: AppColors.error, size: 48),
                            const SizedBox(height: 16),
                            Text(state.message, style: const TextStyle(color: AppColors.textSecondaryLight)),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _refresh,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                              ),
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      ),
                    )
                  else if (state is TasksLoaded)
                    state.tasks.isEmpty
                        ? SliverFillRemaining(
                            child: Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.task_alt, size: 64, color: AppColors.primary.withValues(alpha: 0.3)),
                                  const SizedBox(height: 16),
                                  const Text('No tasks yet', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textSecondaryLight)),
                                  const SizedBox(height: 8),
                                  const Text('Tap + to create your first task', style: TextStyle(color: AppColors.textSecondaryLight)),
                                ],
                              ),
                            ),
                          )
                        : SliverPadding(
                            padding: const EdgeInsets.fromLTRB(24, 0, 24, 120),
                            sliver: SliverList(
                              delegate: SliverChildBuilderDelegate(
                                (context, index) {
                                  final task = state.tasks[index];
                                  return _buildTaskItem(
                                    context: context,
                                    task: task,
                                    delay: 200 + (index * 80),
                                  );
                                },
                                childCount: state.tasks.length,
                              ),
                            ),
                          ),
                ],
              ),
            );
          },
        ),
        floatingActionButton: widget.projectId != null
            ? FloatingActionButton(
                onPressed: () => context
                    .push('/create-task', extra: {'projectId': widget.projectId})
                    .then((_) => _refresh()),
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                child: const Icon(Icons.add, color: Colors.white, size: 28),
              )
            : null,
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
    required BuildContext context,
    required TaskSummary task,
    required int delay,
  }) {
    final isDone = task.status == 'Done' || task.status == 'Completed';
    final Color statusColor;
    final String statusLabel = task.status ?? 'Todo';

    switch (statusLabel) {
      case 'InProgress':
        statusColor = AppColors.warning;
        break;
      case 'Done':
      case 'Completed':
        statusColor = AppColors.success;
        break;
      case 'Blocked':
        statusColor = AppColors.error;
        break;
      case 'Review':
        statusColor = AppColors.info;
        break;
      default:
        statusColor = AppColors.textSecondaryLight;
    }

    return GestureDetector(
      onTap: () => context.push('/task-details', extra: {'taskId': task.id}),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDone ? Colors.white.withValues(alpha: 0.6) : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isDone ? Colors.transparent : AppColors.borderLight,
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
                color: isDone ? AppColors.success.withValues(alpha: 0.15) : Colors.transparent,
                border: Border.all(
                  color: isDone ? AppColors.success : AppColors.borderLight,
                  width: 2,
                ),
              ),
              child: isDone
                  ? const Icon(Icons.check, color: AppColors.success, size: 16)
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: isDone ? AppColors.textSecondaryLight : AppColors.textPrimaryLight,
                      decoration: isDone ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        statusLabel == 'InProgress' ? 'In Progress' : statusLabel,
                        style: TextStyle(
                          fontSize: 12,
                          color: statusColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (task.priority != null) ...[
                        const SizedBox(width: 12),
                        Text(
                          task.priority!,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondaryLight,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            if (task.dueDate != null)
              Text(
                DateFormat('MMM d').format(task.dueDate!),
                style: const TextStyle(fontSize: 11, color: AppColors.textSecondaryLight),
              ),
          ],
        ),
      ).animate().fadeIn(delay: delay.ms).slideX(begin: 0.1),
    );
  }
}
