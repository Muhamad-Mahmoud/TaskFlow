import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:taskflow/core/constants/app_colors.dart';
import 'package:taskflow/core/di/injection.dart';
import '../../../projects/presentation/bloc/projects_bloc.dart';
import '../../../projects/data/models/project_models.dart';
import '../bloc/tasks_bloc.dart';
import '../../domain/models/task_models.dart';

class CreateTaskPage extends StatefulWidget {
  final String? preselectedProjectId;
  const CreateTaskPage({super.key, this.preselectedProjectId});

  @override
  State<CreateTaskPage> createState() => _CreateTaskPageState();
}

class _CreateTaskPageState extends State<CreateTaskPage> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  int _selectedPriority = 1; // 0=Low, 1=Medium, 2=High
  String? _selectedProjectId;
  DateTime? _selectedDueDate;
  final _assigneeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedProjectId = widget.preselectedProjectId;
  }

  static const _bgColor = Color(0xFFF8FAFF);
  static const _inputFill = Color(0xFFF1F5F9);
  static const _labelColor = Color(0xFF64748B);
  static const _textColor = Color(0xFF1E293B);

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _assigneeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) =>
              getIt<ProjectsBloc>()..add(const LoadProjectsRequested()),
        ),
      ],
      child: Scaffold(
        backgroundColor: _bgColor,
        appBar: AppBar(
          backgroundColor: _bgColor,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.close, color: AppColors.primary),
            onPressed: () => context.pop(),
          ),
          title: const Text(
            'New Task',
            style: TextStyle(
              color: _textColor,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          centerTitle: false,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Create Task',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: _textColor,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Fill in the details below to create a new task.',
                style: TextStyle(fontSize: 14, color: _labelColor),
              ),
              const SizedBox(height: 32),

              // Task Title
              _buildLabel('TASK TITLE'),
              const SizedBox(height: 8),
              _buildTextField(
                controller: _titleController,
                hint: 'e.g., Design System Audit',
              ),

              const SizedBox(height: 24),

              // Assign to Project
              _buildLabel('ASSIGN TO PROJECT'),
              const SizedBox(height: 8),
              BlocBuilder<ProjectsBloc, ProjectsState>(
                builder: (context, state) {
                  if (state is ProjectsLoading) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: LinearProgressIndicator(
                        color: AppColors.primary,
                        backgroundColor: Color(0xFFE0E7FF),
                      ),
                    );
                  }
                  if (state is ProjectsLoaded) {
                    if (state.projects.isEmpty) {
                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: _inputFill,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'No projects found. Create a project first.',
                          style: TextStyle(color: _labelColor, fontSize: 14),
                        ),
                      );
                    }
                    return Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: state.projects
                          .map((p) => _buildProjectChip(p))
                          .toList(),
                    );
                  }
                  if (state is ProjectsFailure) {
                    return Text(
                      'Failed to load projects: ${state.message}',
                      style: const TextStyle(color: AppColors.error, fontSize: 13),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),

              const SizedBox(height: 24),

              // Due Date
              _buildLabel('DUE DATE'),
              const SizedBox(height: 8),
              InkWell(
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                    builder: (context, child) => Theme(
                      data: Theme.of(context).copyWith(
                        colorScheme: const ColorScheme.light(
                          primary: AppColors.primary,
                          onPrimary: Colors.white,
                          surface: Colors.white,
                          onSurface: _textColor,
                        ),
                      ),
                      child: child!,
                    ),
                  );
                  if (date != null) setState(() => _selectedDueDate = date);
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 16),
                  decoration: BoxDecoration(
                    color: _inputFill,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today_outlined,
                          color: AppColors.primary, size: 20),
                      const SizedBox(width: 12),
                      Text(
                        _selectedDueDate == null
                            ? 'Select date'
                            : _selectedDueDate!
                                .toLocal()
                                .toString()
                                .split(' ')[0],
                        style: TextStyle(
                          color: _selectedDueDate == null
                              ? _labelColor
                              : _textColor,
                          fontSize: 15,
                          fontWeight: _selectedDueDate == null
                              ? FontWeight.normal
                              : FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Priority
              _buildLabel('PRIORITY LEVEL'),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: _inputFill,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  children: [
                    _buildPrioritySegment(0, 'Low', const Color(0xFF10B981)),
                    _buildPrioritySegment(1, 'Medium', const Color(0xFFF59E0B)),
                    _buildPrioritySegment(2, 'High', const Color(0xFFEF4444)),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Assignee Email or Phone
              _buildLabel('ASSIGNEE EMAIL OR PHONE (Optional)'),
              const SizedBox(height: 8),
              _buildTextField(
                controller: _assigneeController,
                hint: 'e.g., teammate@example.com or 01xxxxxxxxx',
              ),

              const SizedBox(height: 24),

              // Description
              _buildLabel('DESCRIPTION'),
              const SizedBox(height: 8),
              _buildTextField(
                controller: _descriptionController,
                hint: 'Briefly describe the task...',
                maxLines: 4,
              ),

              const SizedBox(height: 48),

              // Submit button
              SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text(
                    'Create Task',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Center(
                child: Text(
                  'Task will be saved and synced to the project',
                  style: TextStyle(fontSize: 12, color: _labelColor),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  void _submit() {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a task title'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }
    if (_selectedProjectId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a project'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    final priorities = ['Low', 'Medium', 'High'];
    final assigneeIdStr = _assigneeController.text.trim();
    final request = CreateTaskRequest(
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      projectId: _selectedProjectId!,
      priority: priorities[_selectedPriority],
      dueDate: _selectedDueDate,
      assigneeEmailOrPhone: assigneeIdStr.isNotEmpty ? assigneeIdStr : null,
    );

    getIt<TasksBloc>().add(CreateTaskRequested(request));
    context.pop();
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: _labelColor,
        letterSpacing: 0.8,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(color: _textColor, fontSize: 15),
      cursorColor: AppColors.primary,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: _labelColor, fontSize: 15),
        filled: true,
        fillColor: _inputFill,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
    );
  }

  Widget _buildPrioritySegment(int index, String text, Color accentColor) {
    final isSelected = _selectedPriority == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedPriority = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? accentColor.withValues(alpha: 0.12) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: isSelected
                ? Border.all(color: accentColor.withValues(alpha: 0.4), width: 1.5)
                : null,
          ),
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? accentColor : _labelColor,
                fontSize: 13,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProjectChip(ProjectSummary project) {
    final isSelected = _selectedProjectId == project.id;
    return GestureDetector(
      onTap: () => setState(
          () => _selectedProjectId = isSelected ? null : project.id),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.1)
              : _inputFill,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? AppColors.primary.withValues(alpha: 0.5)
                : const Color(0xFFE2E8F0),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Text(
          project.name,
          style: TextStyle(
            color: isSelected ? AppColors.primary : _labelColor,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
