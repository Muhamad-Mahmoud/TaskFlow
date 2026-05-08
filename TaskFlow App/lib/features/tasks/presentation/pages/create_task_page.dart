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
  const CreateTaskPage({super.key});

  @override
  State<CreateTaskPage> createState() => _CreateTaskPageState();
}

class _CreateTaskPageState extends State<CreateTaskPage> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  int _selectedPriority = 1; // 0=Low, 1=Medium, 2=High
  String? _selectedProjectId;
  DateTime? _selectedDueDate;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => getIt<ProjectsBloc>()..add(const LoadProjectsRequested())),
      ],
      child: Scaffold(
        backgroundColor: const Color(0xFFFAFBFC),
        appBar: AppBar(
          backgroundColor: const Color(0xFFFAFBFC),
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.close, color: AppColors.primary),
            onPressed: () => context.pop(),
          ),
          title: const Text('New Task', style: TextStyle(color: AppColors.primary, fontSize: 16)),
          centerTitle: false,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Create Task',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.textPrimaryLight),
              ),
              const SizedBox(height: 32),
              
              _buildLabel('Task Title'),
              const SizedBox(height: 8),
              TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  hintText: 'e.g., Design System Audit',
                  filled: true,
                  fillColor: const Color(0xFFEBEFF5).withValues(alpha: 0.5),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
              
              const SizedBox(height: 24),
              
              _buildLabel('Assign to Project'),
              const SizedBox(height: 8),
              BlocBuilder<ProjectsBloc, ProjectsState>(
                builder: (context, state) {
                  if (state is ProjectsLoading) return const LinearProgressIndicator();
                  if (state is ProjectsLoaded) {
                    return Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: state.projects.map((p) => _buildProjectChip(p)).toList(),
                    );
                  }
                  return const Text('Failed to load projects');
                },
              ),
              
              const SizedBox(height: 24),
              
              _buildLabel('Due Date'),
              const SizedBox(height: 8),
              TextField(
                readOnly: true,
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (date != null) setState(() => _selectedDueDate = date);
                },
                decoration: InputDecoration(
                  hintText: _selectedDueDate == null ? 'Select date' : _selectedDueDate.toString().split(' ')[0],
                  suffixIcon: Icon(Icons.calendar_today_outlined, color: AppColors.textSecondaryLight),
                  filled: true,
                  fillColor: const Color(0xFFEBEFF5).withValues(alpha: 0.5),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
              
              const SizedBox(height: 24),
              
              _buildLabel('PRIORITY LEVEL'),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(color: const Color(0xFFEBEFF5).withValues(alpha: 0.5), borderRadius: BorderRadius.circular(12)),
                child: Row(
                  children: [
                    _buildPrioritySegment(0, 'Low'),
                    _buildPrioritySegment(1, 'Medium'),
                    _buildPrioritySegment(2, 'High'),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              _buildLabel('Description'),
              const SizedBox(height: 8),
              TextField(
                controller: _descriptionController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Briefly describe the task...',
                  filled: true,
                  fillColor: const Color(0xFFEBEFF5).withValues(alpha: 0.5),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
              
              const SizedBox(height: 48),
              
              SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('Create Task', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
                ),
              ),
              const SizedBox(height: 16),
              const Center(
                child: Text(
                  'Press Enter ↵ to quickly submit',
                  style: TextStyle(fontSize: 12, color: AppColors.textSecondaryLight),
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
    if (_titleController.text.isEmpty || _selectedProjectId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter title and select project')));
      return;
    }

    final priorities = ['Low', 'Medium', 'High'];
    final request = CreateTaskRequest(
      title: _titleController.text,
      description: _descriptionController.text,
      projectId: _selectedProjectId!,
      priority: priorities[_selectedPriority],
      dueDate: _selectedDueDate,
    );

    getIt<TasksBloc>().add(CreateTaskRequested(request));
    context.pop();
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimaryLight, letterSpacing: 0.5),
    );
  }

  Widget _buildPrioritySegment(int index, String text) {
    final isSelected = _selectedPriority == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedPriority = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              text,
              style: TextStyle(fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500, color: isSelected ? AppColors.primary : AppColors.textPrimaryLight),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProjectChip(ProjectSummary project) {
    final isSelected = _selectedProjectId == project.id;
    return ChoiceChip(
      label: Text(project.name),
      selected: isSelected,
      onSelected: (val) => setState(() => _selectedProjectId = val ? project.id : null),
      selectedColor: AppColors.primary.withValues(alpha: 0.1),
      side: BorderSide.none,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    );
  }
}
