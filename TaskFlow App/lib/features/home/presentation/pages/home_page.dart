import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:taskflow/core/constants/app_colors.dart';
import 'package:taskflow/core/di/injection.dart';
import 'package:taskflow/features/home/presentation/bloc/home_bloc.dart';
import 'package:taskflow/features/home/domain/models/home_stats.dart';
import 'package:taskflow/features/tasks/domain/models/task_models.dart';
import 'package:go_router/go_router.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  late final HomeBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = getIt<HomeBloc>()..add(const HomeEvent.started());
  }

  void refresh() {
    _bloc.add(const HomeEvent.started());
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bloc,
      child: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          return state.map(
            initial: (_) => const SizedBox(),
            loading: (_) => const Center(child: CircularProgressIndicator()),
            failure: (f) => Center(child: Text(f.message)),
            success: (s) => _buildContent(context, s.stats, s.priorityTasks),
          );
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, HomeStats stats, List<TaskSummary> tasks) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Greeting Section
          const Text(
            'Good morning 👋',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w900,
              color: AppColors.textPrimaryLight,
              letterSpacing: -1,
            ),
          ).animate().fadeIn(duration: 600.ms).slideX(begin: -0.1),
          
          const SizedBox(height: 12),
          
          _buildStatsRow(stats).animate().fadeIn(delay: 200.ms).slideX(begin: -0.1),
          
          const SizedBox(height: 40),
          
          // Section Title
          _buildSectionHeader('Recent Tasks', () {
            // Can navigate to tasks tab if needed
          }),
          
          const SizedBox(height: 16),
          
          // Task List
          if (tasks.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.borderLight.withValues(alpha: 0.5)),
              ),
              child: const Column(
                children: [
                  Icon(Icons.task_outlined, size: 48, color: AppColors.borderLight),
                  SizedBox(height: 16),
                  Text(
                    'No tasks assigned to you yet',
                    style: TextStyle(
                      color: AppColors.textSecondaryLight,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            )
          else
            ...tasks.asMap().entries.map((entry) {
              final task = entry.value;
              final isDone = task.status == 'Done' || task.status == 'Completed';
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: GestureDetector(
                  onTap: () => context.push('/task-details', extra: {'taskId': task.id}),
                  child: _buildTaskCard(
                    title: task.title,
                    time: task.dueDate != null ? task.dueDate.toString().split(' ')[0] : 'No date',
                    category: task.projectName,
                    dotColor: isDone ? const Color(0xFF22C55E) : _getPriorityColor(task.priority),
                    delay: 400 + (entry.key * 100),
                    isDone: isDone,
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high': return AppColors.accent;
      case 'medium': return AppColors.secondary;
      default: return AppColors.primary;
    }
  }

  Widget _buildStatsRow(HomeStats stats) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(stats.completedCount.toString().padLeft(2, '0'), 'Completed'),
          Container(width: 1, height: 40, color: Colors.white.withValues(alpha: 0.2)),
          _buildStatItem(stats.inProgressCount.toString().padLeft(2, '0'), 'Pending'),
          Container(width: 1, height: 40, color: Colors.white.withValues(alpha: 0.2)),
          _buildStatItem(stats.blockedCount.toString().padLeft(2, '0'), 'Blocked'),
        ],
      ),
    );
  }

  Widget _buildStatItem(String count, String label) {
    return Column(
      children: [
        Text(
          count,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w900,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.white.withValues(alpha: 0.8),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, VoidCallback onSeeAll) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: AppColors.textPrimaryLight,
          ),
        ),
        TextButton(
          onPressed: onSeeAll,
          child: const Text(
            'See All',
            style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
          ),
        ),
      ],
    );
  }

  Widget _buildTaskCard({
    required String title,
    required String time,
    required String category,
    required Color dotColor,
    required int delay,
    bool isDone = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.borderLight, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: dotColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: isDone
                ? Icon(Icons.check_circle_rounded, color: dotColor, size: 28)
                : Icon(Icons.calendar_today_rounded, color: dotColor, size: 24),
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
                    color: isDone ? AppColors.textSecondaryLight : AppColors.textPrimaryLight,
                    decoration: isDone ? TextDecoration.lineThrough : null,
                    decorationColor: AppColors.textSecondaryLight,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Text(
                      time,
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondaryLight.withValues(alpha: 0.7),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(width: 4, height: 4, decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.borderLight)),
                    const SizedBox(width: 8),
                    Text(
                      category,
                      style: TextStyle(
                        fontSize: 13,
                        color: dotColor,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: delay.ms).slideY(begin: 0.1);
  }
}

