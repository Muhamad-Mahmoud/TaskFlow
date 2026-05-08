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
        title: const Text('Create Project', style: TextStyle(color: AppColors.textPrimaryLight, fontSize: 16)),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Define your mission.',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.textPrimaryLight),
            ),
            const SizedBox(height: 40),
            
            _buildLabel('PROJECT NAME'),
            const SizedBox(height: 8),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                hintText: 'e.g. Brand Identity 2024',
                filled: true,
                fillColor: const Color(0xFFEBEFF5).withValues(alpha: 0.5),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
            
            const SizedBox(height: 24),
            
            _buildLabel('DUE DATE'),
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
                hintText: _selectedDueDate == null ? 'Select target date...' : _selectedDueDate.toString().split(' ')[0],
                suffixIcon: Icon(Icons.calendar_today_outlined, color: AppColors.textSecondaryLight),
                filled: true,
                fillColor: const Color(0xFFEBEFF5).withValues(alpha: 0.5),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),

            const SizedBox(height: 24),
            _buildLabel('DESCRIPTION'),
            const SizedBox(height: 8),
            TextField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Briefly describe the project goals...',
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
                child: const Text('Create Project', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => context.pop(),
              child: const Text('Skip for now', style: TextStyle(color: AppColors.primary, fontSize: 15, fontWeight: FontWeight.w600)),
            ),
            const SizedBox(height: 48),
            Center(
              child: RichText(
                textAlign: TextAlign.center,
                text: const TextSpan(
                  style: TextStyle(fontSize: 12, color: AppColors.textSecondaryLight),
                  children: [
                    TextSpan(text: 'By creating, you agree to the '),
                    TextSpan(text: 'Team Workspace Guidelines', style: TextStyle(decoration: TextDecoration.underline)),
                    TextSpan(text: '.'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  void _submit() {
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter project name')));
      return;
    }

    final request = CreateProjectRequest(
      name: _nameController.text,
      description: _descriptionController.text,
      dueDate: _selectedDueDate,
      priority: 'Medium',
      colorLabel: '#6366f1',
    );

    getIt<ProjectsBloc>().add(CreateProjectRequested(request));
    context.pop();
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimaryLight, letterSpacing: 0.5),
    );
  }
}
