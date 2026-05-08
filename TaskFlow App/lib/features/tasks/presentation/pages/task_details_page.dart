import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:taskflow/core/constants/app_colors.dart';
import 'package:taskflow/core/di/injection.dart';
import 'package:intl/intl.dart';
import '../bloc/tasks_bloc.dart';
import '../../domain/models/task_models.dart';

class TaskDetailsPage extends StatelessWidget {
  final String? taskId;
  const TaskDetailsPage({super.key, this.taskId});

  @override
  Widget build(BuildContext context) {
    if (taskId == null) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => context.pop()),
        ),
        body: const Center(child: Text("Task ID is missing")),
      );
    }
    return BlocProvider(
      create: (_) =>
          getIt<TasksBloc>()..add(LoadTaskDetailRequested(taskId!)),
      child: const _TaskDetailsView(),
    );
  }
}

class _TaskDetailsView extends StatefulWidget {
  const _TaskDetailsView();

  @override
  State<_TaskDetailsView> createState() => _TaskDetailsViewState();
}

class _TaskDetailsViewState extends State<_TaskDetailsView> {
  late TasksBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = context.read<TasksBloc>();
  }

  void _refresh() {
    final state = _bloc.state;
    if (state is TaskDetailLoaded) {
      _bloc.add(LoadTaskDetailRequested(state.task.id));
    }
  }

  void _showAssignDialog(TaskResponse task) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Assign Task'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Email or Phone Number',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final val = controller.text.trim();
              if (val.isNotEmpty) {
                _bloc.add(UpdateTaskRequested(
                  task.id,
                  UpdateTaskRequest(
                    title: task.title,
                    description: task.description,
                    status: task.status,
                    priority: task.priority,
                    dueDate: task.dueDate,
                    estimatedHours: task.estimatedHours,
                    assigneeEmailOrPhone: val,
                  ),
                ));
              }
              Navigator.pop(ctx);
            },
            child: const Text('Assign'),
          ),
        ],
      ),
    );
  }

  void _deleteTask(TaskResponse task) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Task'),
        content: const Text('Are you sure you want to delete this task?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () {
              _bloc.add(DeleteTaskRequested(task.id));
              Navigator.pop(ctx);
              context.pop(); // Go back to previous screen
            },
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFBFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFAFBFC),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primary),
          onPressed: () => context.pop(),
        ),
        title: const Text('Task Details',
            style: TextStyle(color: AppColors.textPrimaryLight, fontSize: 16)),
        centerTitle: true,
        actions: [
          BlocBuilder<TasksBloc, TasksState>(
            builder: (context, state) {
              if (state is TaskDetailLoaded) {
                return PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, color: AppColors.primary),
                  onSelected: (value) {
                    if (value == 'assign') {
                      _showAssignDialog(state.task);
                    } else if (value == 'delete') {
                      _deleteTask(state.task);
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'assign',
                      child: Text('Assign Task'),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Text('Delete Task', style: TextStyle(color: AppColors.error)),
                    ),
                  ],
                );
              }
              return const SizedBox.shrink();
            },
          ),
          const Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              radius: 14,
              backgroundColor: AppColors.textPrimaryLight,
              child: Icon(Icons.person, color: Colors.white, size: 16),
            ),
          ),
        ],
      ),
      body: BlocBuilder<TasksBloc, TasksState>(
        builder: (context, state) {
          if (state is TaskDetailLoading) {
            return const Center(
                child: CircularProgressIndicator(color: AppColors.primary));
          } else if (state is TaskDetailFailure) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline,
                      color: AppColors.error, size: 48),
                  const SizedBox(height: 16),
                  Text(state.message,
                      style: const TextStyle(color: AppColors.textSecondaryLight)),
                ],
              ),
            );
          } else if (state is TaskDetailLoaded) {
            final task = state.task;
            return RefreshIndicator(
              color: AppColors.primary,
              onRefresh: () async {
                _bloc.add(LoadTaskDetailRequested(task.id));
              },
              child: _buildContent(context, task),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, TaskResponse task) {
    final progress = task.subtasks.isEmpty
        ? (task.status == 'Done' || task.status == 'Completed' ? 1.0 : 0.0)
        : task.subtasks.where((s) => s.isCompleted).length / task.subtasks.length;

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics()),
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Tags and Status
                Row(
                  children: [
                    Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _getStatusColor(task.status),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        task.status.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '#${task.id.substring(0, 8)}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondaryLight,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Title
                Text(
                  task.title,
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimaryLight,
                    height: 1.1,
                  ),
                ),

                const SizedBox(height: 24),

                // Action Buttons
                Row(
                  children: [
                    _buildActionButton(Icons.edit, 'Edit'),
                    const SizedBox(width: 8),
                    _buildActionButton(Icons.share, 'Share'),
                    const SizedBox(width: 8),
                    _buildActionButton(Icons.copy, 'Copy Link'),
                  ],
                ),

                const SizedBox(height: 32),

                // Description
                if (task.description != null && task.description!.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(24),
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'DESCRIPTION',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          task.description!,
                          style: const TextStyle(
                            fontSize: 15,
                            color: AppColors.textSecondaryLight,
                            height: 1.6,
                          ),
                        ),
                      ],
                    ),
                  ),

                if (task.description != null && task.description!.isNotEmpty)
                  const SizedBox(height: 24),

                // Properties Cards
                if (task.dueDate != null)
                  _buildPropertyCard(
                    icon: Icons.calendar_today_outlined,
                    iconColor: AppColors.primary,
                    label: 'DUE DATE',
                    valueWidget: Text(
                      DateFormat('MMM d, yyyy').format(task.dueDate!),
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: AppColors.textPrimaryLight),
                    ),
                  ),
                if (task.dueDate != null) const SizedBox(height: 12),
                
                _buildPropertyCard(
                  icon: Icons.error_outline,
                  iconColor: _getPriorityColor(task.priority),
                  label: 'PRIORITY',
                  valueWidget: Row(
                    children: [
                      Text(task.priority.toUpperCase(),
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: _getPriorityColor(task.priority))),
                      const SizedBox(width: 4),
                      Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                              color: _getPriorityColor(task.priority),
                              shape: BoxShape.circle)),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                
                GestureDetector(
                  onTap: () => _showAssignDialog(task),
                  child: _buildPropertyCard(
                    iconWidget: CircleAvatar(
                      radius: 12,
                      backgroundColor: AppColors.primary.withValues(alpha: 0.2),
                      backgroundImage: task.assignee?.avatarUrl != null
                          ? NetworkImage(task.assignee!.avatarUrl!)
                          : null,
                      child: task.assignee?.avatarUrl == null
                          ? const Icon(Icons.person, size: 16, color: AppColors.primary)
                          : null,
                    ),
                    label: 'ASSIGNEE',
                    valueWidget: Text(
                      task.assignee?.fullName ?? 'Unassigned',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: AppColors.textPrimaryLight),
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                // Checklist Section
                if (task.subtasks.isNotEmpty) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Checklist',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimaryLight,
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${(progress * 100).toInt()}% COMPLETE',
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                              letterSpacing: 1.0,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            width: 100,
                            height: 4,
                            decoration: BoxDecoration(
                              color: const Color(0xFFEBEFF5),
                              borderRadius: BorderRadius.circular(2),
                            ),
                            child: FractionallySizedBox(
                              alignment: Alignment.centerLeft,
                              widthFactor: progress,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
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
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Column(
                      children: [
                        ...task.subtasks.map((s) => Column(
                              children: [
                                _buildChecklistItem(s.title, s.isCompleted),
                                if (s != task.subtasks.last)
                                  const Divider(height: 1, color: Color(0xFFF0F4FA)),
                              ],
                            )),
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            children: [
                              const Icon(Icons.add,
                                  color: AppColors.primary, size: 20),
                              const SizedBox(width: 8),
                              const Text('Add subtask',
                                  style: TextStyle(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                ],

                // Activity Section
                const Text(
                  'Activity',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimaryLight,
                  ),
                ),
                const SizedBox(height: 24),

                // Activity item 2 (system)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.history,
                          size: 16, color: AppColors.primary),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RichText(
                            text: TextSpan(
                              style: const TextStyle(
                                  color: AppColors.textSecondaryLight, fontSize: 14),
                              children: [
                                const TextSpan(text: 'Task created by '),
                                TextSpan(
                                    text: task.createdBy.fullName,
                                    style: const TextStyle(
                                        color: AppColors.textPrimaryLight,
                                        fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                              DateFormat('MMM d, yyyy - h:mm a')
                                  .format(task.createdAt.toLocal()),
                              style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textSecondaryLight
                                      .withValues(alpha: 0.5))),
                        ],
                      ),
                    ),
                  ],
                ),

                // Comment and Actions Panel
                Container(
                  margin: const EdgeInsets.only(top: 24),
                  padding: const EdgeInsets.all(24),
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
                  child: Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFFAFBFC),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: AppColors.borderLight),
                        ),
                        padding:
                            const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        child: Row(
                          children: [
                            const Icon(Icons.add, color: AppColors.primary, size: 20),
                            const SizedBox(width: 8),
                            const Expanded(
                              child: TextField(
                                decoration: InputDecoration(
                                  hintText: 'Add a comment...',
                                  border: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.send, color: Colors.white, size: 16),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton.icon(
                          onPressed: task.status == 'Done' ? null : () {
                            _bloc.add(UpdateTaskRequested(
                              task.id,
                              UpdateTaskRequest(
                                title: task.title,
                                description: task.description,
                                status: 'Done',
                                priority: task.priority,
                                dueDate: task.dueDate,
                                estimatedHours: task.estimatedHours,
                              ),
                            ));
                          },
                          icon: Icon(task.status == 'Done' ? Icons.check_circle : Icons.check_circle_outline),
                          label: Text(task.status == 'Done' ? 'Completed' : 'Mark Complete',
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w600)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: task.status == 'Done' ? AppColors.success : AppColors.primary,
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: AppColors.success.withValues(alpha: 0.5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFEBEFF5).withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFEBEFF5)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.textSecondaryLight),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimaryLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPropertyCard({
    IconData? icon,
    Widget? iconWidget,
    Color? iconColor,
    required String label,
    required Widget valueWidget,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.01),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              color: Color(0xFFFAFBFC),
              shape: BoxShape.circle,
            ),
            child: iconWidget ?? Icon(icon, size: 18, color: iconColor),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textSecondaryLight.withValues(alpha: 0.6),
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 4),
              valueWidget,
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChecklistItem(String label, bool isChecked) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: isChecked ? AppColors.primary : Colors.white,
              border: Border.all(
                  color: isChecked
                      ? AppColors.primary
                      : AppColors.textSecondaryLight),
              borderRadius: BorderRadius.circular(6),
            ),
            child: isChecked
                ? const Icon(Icons.check, size: 14, color: Colors.white)
                : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: isChecked
                    ? AppColors.textSecondaryLight
                    : AppColors.textPrimaryLight,
                decoration: isChecked ? TextDecoration.lineThrough : null,
              ),
            ),
          ),
          const Icon(Icons.drag_indicator, color: Color(0xFFEBEFF5)),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'InProgress':
        return AppColors.warning;
      case 'Done':
      case 'Completed':
        return AppColors.success;
      case 'Blocked':
        return AppColors.error;
      case 'Review':
        return AppColors.info;
      default:
        return AppColors.primary;
    }
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'High':
        return AppColors.error;
      case 'Medium':
        return AppColors.warning;
      case 'Low':
        return AppColors.success;
      default:
        return AppColors.textSecondaryLight;
    }
  }
}
