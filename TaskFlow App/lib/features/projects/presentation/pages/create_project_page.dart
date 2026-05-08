import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:taskflow/core/constants/app_colors.dart';
import 'package:taskflow/core/di/injection.dart';
import '../bloc/projects_bloc.dart';
import '../../data/models/project_models.dart';

class CreateProjectPage extends StatefulWidget {
  const CreateProjectPage({super.key});

  @override
  State<CreateProjectPage> createState() => _CreateProjectPageState();
}

class _CreateProjectPageState extends State<CreateProjectPage> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime? _selectedDueDate;
  String _selectedPriority = 'Medium';
  String _selectedColor = '#6366f1';
  bool _isSubmitting = false;

  static const _bgColor = Color(0xFFF8FAFF);
  static const _inputFill = Color(0xFFF1F5F9);
  static const _labelColor = Color(0xFF64748B);
  static const _textColor = Color(0xFF1E293B);

  final _colorOptions = const [
    {'label': 'Indigo', 'hex': '#6366f1', 'color': Color(0xFF6366f1)},
    {'label': 'Pink', 'hex': '#EC4899', 'color': Color(0xFFEC4899)},
    {'label': 'Emerald', 'hex': '#10B981', 'color': Color(0xFF10B981)},
    {'label': 'Amber', 'hex': '#F59E0B', 'color': Color(0xFFF59E0B)},
    {'label': 'Sky', 'hex': '#0EA5E9', 'color': Color(0xFF0EA5E9)},
    {'label': 'Rose', 'hex': '#F43F5E', 'color': Color(0xFFF43F5E)},
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<ProjectsBloc>(),
      child: BlocListener<ProjectsBloc, ProjectsState>(
        listener: (context, state) {
          if (state is ProjectsLoaded) {
            setState(() => _isSubmitting = false);
            context.pop();
          } else if (state is ProjectsFailure) {
            setState(() => _isSubmitting = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        child: Scaffold(
          backgroundColor: _bgColor,
          appBar: AppBar(
            backgroundColor: _bgColor,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: AppColors.primary),
              onPressed: () => context.pop(),
            ),
            title: const Text(
              'Create Project',
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
                  'Define your mission.',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: _textColor,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Give your project a name and set it up.',
                  style: TextStyle(fontSize: 14, color: _labelColor),
                ),
                const SizedBox(height: 32),

                // Project Name
                _buildLabel('PROJECT NAME'),
                const SizedBox(height: 8),
                _buildTextField(
                  controller: _nameController,
                  hint: 'e.g. Brand Identity 2024',
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
                      lastDate: DateTime.now().add(const Duration(days: 730)),
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
                              ? 'Select target date...'
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
                _buildLabel('PRIORITY'),
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
                      _buildPrioritySegment(
                          'Low', const Color(0xFF10B981)),
                      _buildPrioritySegment(
                          'Medium', const Color(0xFFF59E0B)),
                      _buildPrioritySegment(
                          'High', const Color(0xFFEF4444)),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Color Label
                _buildLabel('COLOR LABEL'),
                const SizedBox(height: 12),
                Row(
                  children: _colorOptions.map((opt) {
                    final isSelected = _selectedColor == opt['hex'];
                    return Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: GestureDetector(
                        onTap: () => setState(
                            () => _selectedColor = opt['hex'] as String),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: opt['color'] as Color,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected
                                  ? _textColor
                                  : Colors.transparent,
                              width: 2.5,
                            ),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: (opt['color'] as Color)
                                          .withValues(alpha: 0.4),
                                      blurRadius: 8,
                                      offset: const Offset(0, 3),
                                    )
                                  ]
                                : null,
                          ),
                          child: isSelected
                              ? const Icon(Icons.check,
                                  color: Colors.white, size: 18)
                              : null,
                        ),
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 24),

                // Description
                _buildLabel('DESCRIPTION'),
                const SizedBox(height: 8),
                _buildTextField(
                  controller: _descriptionController,
                  hint: 'Briefly describe the project goals...',
                  maxLines: 3,
                ),

                const SizedBox(height: 48),

                // Submit
                Builder(builder: (context) {
                  return SizedBox(
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : () => _submit(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor:
                            AppColors.primary.withValues(alpha: 0.5),
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                      ),
                      child: _isSubmitting
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.5,
                              ),
                            )
                          : const Text(
                              'Create Project',
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white),
                            ),
                    ),
                  );
                }),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => context.pop(),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(
                        color: _labelColor,
                        fontSize: 15,
                        fontWeight: FontWeight.w500),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _submit(BuildContext context) {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a project name'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final request = CreateProjectRequest(
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      dueDate: _selectedDueDate,
      priority: _selectedPriority,
      colorLabel: _selectedColor,
    );

    context.read<ProjectsBloc>().add(CreateProjectRequested(request));
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

  Widget _buildPrioritySegment(String label, Color accentColor) {
    final isSelected = _selectedPriority == label;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedPriority = label),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? accentColor.withValues(alpha: 0.12)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: isSelected
                ? Border.all(
                    color: accentColor.withValues(alpha: 0.4), width: 1.5)
                : null,
          ),
          child: Center(
            child: Text(
              label,
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
}
