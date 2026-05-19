import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:taskflow/core/constants/app_colors.dart';
import 'package:taskflow/core/di/injection.dart';
import '../bloc/projects_bloc.dart';
import '../../data/models/project_models.dart';

class InviteMemberPage extends StatefulWidget {
  final String projectId;
  const InviteMemberPage({super.key, required this.projectId});

  @override
  State<InviteMemberPage> createState() => _InviteMemberPageState();
}

class _InviteMemberPageState extends State<InviteMemberPage> {
  final _emailController = TextEditingController();
  String _selectedRole = 'Editor';

  static const _roles = ['Viewer', 'Editor', 'Owner'];

  static const _bgColor = Color(0xFFF8FAFF);
  static const _inputFill = Color(0xFFF1F5F9);
  static const _labelColor = Color(0xFF64748B);
  static const _textColor = Color(0xFF1E293B);

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<ProjectsBloc>(),
      child: BlocListener<ProjectsBloc, ProjectsState>(
        listener: (context, state) {
          if (state is InviteMemberSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${state.member.fullName} invited successfully!'),
                backgroundColor: AppColors.success,
              ),
            );
            context.pop();
          } else if (state is InviteMemberFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        child: Builder(builder: (context) {
          return Scaffold(
            backgroundColor: _bgColor,
            appBar: AppBar(
              backgroundColor: _bgColor,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: AppColors.primary),
                onPressed: () => context.pop(),
              ),
              title: const Text(
                'Invite Member',
                style: TextStyle(
                    color: _textColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w600),
              ),
              centerTitle: true,
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Add a teammate',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: _textColor,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Enter the email address or phone number of the person you want to invite.',
                    style: TextStyle(fontSize: 14, color: _labelColor),
                  ),
                  const SizedBox(height: 32),

                  // Email or Phone field
                  _buildSectionLabel('EMAIL OR PHONE'),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    style: const TextStyle(color: _textColor, fontSize: 15),
                    cursorColor: AppColors.primary,
                    decoration: InputDecoration(
                      hintText: 'e.g. teammate@example.com or 01xxxxxxxxx',
                      hintStyle:
                          const TextStyle(color: _labelColor, fontSize: 13),
                      prefixIcon: const Icon(Icons.person_search_outlined,
                          color: AppColors.primary),
                      filled: true,
                      fillColor: _inputFill,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide:
                            const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide:
                            const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(
                            color: AppColors.primary, width: 2),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 16),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Role selector
                  _buildSectionLabel('ROLE'),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: _inputFill,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      children: _roles.map((role) {
                        final isSelected = _selectedRole == role;
                        return Expanded(
                          child: GestureDetector(
                            onTap: () =>
                                setState(() => _selectedRole = role),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding:
                                  const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Colors.white
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: isSelected
                                    ? [
                                        BoxShadow(
                                          color: Colors.black
                                              .withValues(alpha: 0.06),
                                          blurRadius: 8,
                                        )
                                      ]
                                    : null,
                              ),
                              child: Center(
                                child: Text(
                                  role,
                                  style: TextStyle(
                                    fontWeight: isSelected
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                    color: isSelected
                                        ? AppColors.primary
                                        : _labelColor,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  // Role descriptions
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _selectedRole == 'Viewer'
                          ? '👁 Viewer: Can view tasks and project details, but cannot make changes.'
                          : _selectedRole == 'Editor'
                              ? '✏️ Editor: Can create and edit tasks, but cannot manage members.'
                              : '👑 Owner: Full access to project — can manage tasks, members, and settings.',
                      style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.primary,
                          height: 1.4),
                    ),
                  ),

                  const SizedBox(height: 40),

                  BlocBuilder<ProjectsBloc, ProjectsState>(
                    builder: (context, state) {
                      final isLoading = state is ProjectsLoading;
                      return SizedBox(
                        height: 56,
                        child: ElevatedButton.icon(
                          onPressed: isLoading ? null : () => _submit(context),
                          icon: isLoading
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                      color: Colors.white, strokeWidth: 2.5),
                                )
                              : const Icon(Icons.send_outlined, size: 18),
                          label: Text(
                            isLoading ? 'Sending...' : 'Send Invite',
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            disabledBackgroundColor:
                                AppColors.primary.withValues(alpha: 0.5),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16)),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () => context.pop(),
                    child: const Text('Cancel',
                        style: TextStyle(
                            color: _labelColor,
                            fontSize: 15,
                            fontWeight: FontWeight.w500)),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  void _submit(BuildContext context) {
    final emailOrPhone = _emailController.text.trim();
    if (emailOrPhone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter an email address or phone number'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    context.read<ProjectsBloc>().add(
          InviteMemberRequested(
            widget.projectId,
            InviteMemberRequest(emailOrPhone: emailOrPhone, role: _selectedRole),
          ),
        );
  }

  Widget _buildSectionLabel(String text) {
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
}
