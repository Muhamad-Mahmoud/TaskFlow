import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:taskflow/core/constants/app_colors.dart';
import '../bloc/auth_bloc.dart';
import '../../domain/models/auth_models.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is Authenticated) {
          context.go('/home');
        } else if (state is AuthFailure) {
          final errorMsg = state.errors != null && state.errors!.isNotEmpty
              ? state.errors!.join('\n')
              : state.message;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMsg),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 4),
            ),
          );
        }
      },
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFFF0F4FA),
                Color(0xFFFAFBFC),
              ],
              stops: [0.0, 0.3],
            ),
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  children: [
                    const SizedBox(height: 32),
                    
                    // Top Logo and Text
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.account_tree_rounded,
                        color: AppColors.textPrimaryLight,
                        size: 32,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'TaskFlow',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimaryLight,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Orchestrate your productivity with ease.',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.textSecondaryLight,
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Main Card
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Header
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Signup',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimaryLight,
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  context.go('/login');
                                },
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  foregroundColor: AppColors.primary,
                                ),
                                child: const Text('Login', style: TextStyle(fontWeight: FontWeight.w600)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 32),
                          
                          // Name Field
                          const Text(
                            'Full Name',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimaryLight,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            style: const TextStyle(color: Colors.black87),
                            controller: _nameController,
                            keyboardType: TextInputType.name,
                            decoration: InputDecoration(
                              hintText: 'John Doe',
                              prefixIcon: Icon(Icons.person_outline, color: AppColors.textSecondaryLight),
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                          ),
                          const SizedBox(height: 24),
                          
                          // Email Field
                          const Text(
                            'Email Address',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimaryLight,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            style: const TextStyle(color: Colors.black87),
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              hintText: 'name@company.com',
                              prefixIcon: Icon(Icons.mail_outline, color: AppColors.textSecondaryLight),
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                          ),
                          const SizedBox(height: 24),
                          
                          // Password Field
                          const Text(
                            'Password',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimaryLight,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            style: const TextStyle(color: Colors.black87),
                            controller: _passwordController,
                            obscureText: true,
                            decoration: InputDecoration(
                              hintText: '••••••••',
                              prefixIcon: Icon(Icons.lock_outline, color: AppColors.textSecondaryLight),
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                          ),
                          
                          const SizedBox(height: 32),
                          
                          // Signup Button
                          BlocBuilder<AuthBloc, AuthState>(
                            builder: (context, state) {
                              return SizedBox(
                                height: 56,
                                child: ElevatedButton(
                                  onPressed: state is AuthLoading 
                                    ? null 
                                    : () {
                                        context.read<AuthBloc>().add(RegisterRequested(
                                          RegisterRequest(
                                            fullName: _nameController.text,
                                            email: _emailController.text,
                                            password: _passwordController.text,
                                            confirmPassword: _passwordController.text,
                                          ),
                                        ));
                                      },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: state is AuthLoading
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2),
                                      )
                                    : const Text(
                                        'Sign Up',
                                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                                      ),
                                ),
                              );
                            },
                          ),
                          
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Footer Text
                    const Text(
                      'By logging in, you agree to TaskFlow\'s\nTerms of Service and Privacy Policy.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondaryLight,
                        height: 1.5,
                      ),
                    ),
                    
                    const SizedBox(height: 48),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

