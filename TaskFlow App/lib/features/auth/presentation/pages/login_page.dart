import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:taskflow/core/constants/app_colors.dart';
import '../bloc/auth_bloc.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
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
        backgroundColor: AppColors.backgroundLight,
        body: Stack(
          children: [
            // Background Shapes
            Positioned(
              top: -50,
              left: -50,
              child: CircleAvatar(
                radius: 100,
                backgroundColor: AppColors.primary.withValues(alpha: 0.05),
              ),
            ),
            
            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  children: [
                    const SizedBox(height: 64),
                    
                    // Brand Header
                    Column(
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [AppColors.primary, AppColors.primaryLight],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withValues(alpha: 0.3),
                                blurRadius: 15,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.account_tree_rounded,
                            color: AppColors.textPrimaryLight,
                            size: 36,
                          ),
                        ).animate().fadeIn(duration: 600.ms).scale(curve: Curves.easeOut),
                        const SizedBox(height: 24),
                        const Text(
                          'Welcome Back',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                            color: AppColors.textPrimaryLight,
                            letterSpacing: -1,
                          ),
                        ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2),
                        const SizedBox(height: 8),
                        Text(
                          'Login to continue your productivity journey',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: AppColors.textSecondaryLight.withValues(alpha: 0.8),
                            fontWeight: FontWeight.w500,
                          ),
                        ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2),
                      ],
                    ),
                    
                    const SizedBox(height: 48),
                    
                    // Login Card
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(32),
                        border: Border.all(color: AppColors.borderLight, width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
                            blurRadius: 30,
                            offset: const Offset(0, 15),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Email Input
                          _buildLabel('Email Address'),
                          const SizedBox(height: 10),
                          TextField(
                            style: const TextStyle(color: Colors.black87),
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              hintText: 'name@company.com',
                              prefixIcon: const Icon(Icons.mail_outline_rounded),
                              filled: true,
                              fillColor: Colors.white,
                              hintStyle: TextStyle(color: AppColors.textSecondaryLight.withValues(alpha: 0.4)),
                            ),
                          ),
                          
                          const SizedBox(height: 24),
                          
                          // Password Input
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildLabel('Password'),
                              TextButton(
                                onPressed: () {},
                                style: TextButton.styleFrom(
                                  foregroundColor: AppColors.primary,
                                  padding: EdgeInsets.zero,
                                  minimumSize: Size.zero,
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: const Text('Forgot?', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          TextField(
                            style: const TextStyle(color: Colors.black87),
                            controller: _passwordController,
                            obscureText: true,
                            decoration: InputDecoration(
                              hintText: '••••••••',
                              prefixIcon: const Icon(Icons.lock_outline_rounded),
                              filled: true,
                              fillColor: Colors.white,
                              hintStyle: TextStyle(color: AppColors.textSecondaryLight.withValues(alpha: 0.4)),
                            ),
                          ),
                          
                          const SizedBox(height: 40),
                          
                          // Login Button
                          BlocBuilder<AuthBloc, AuthState>(
                            builder: (context, state) {
                              return ElevatedButton(
                                onPressed: state is AuthLoading 
                                  ? null 
                                  : () {
                                      context.read<AuthBloc>().add(LoginRequested(
                                        _emailController.text,
                                        _passwordController.text,
                                      ));
                                    },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  padding: const EdgeInsets.symmetric(vertical: 20),
                                  elevation: 8,
                                  shadowColor: AppColors.primary.withValues(alpha: 0.3),
                                ),
                                child: state is AuthLoading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2),
                                    )
                                  : const Text(
                                      'Sign In',
                                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                    ),
                              );
                            },
                          ),
                        ],
                      ),
                    ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.1),
                    
                    const SizedBox(height: 24),
                    
                    // Signup Link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Don\'t have an account? ',
                          style: TextStyle(color: AppColors.textSecondaryLight.withValues(alpha: 0.8), fontWeight: FontWeight.w500),
                        ),
                        TextButton(
                          onPressed: () => context.go('/signup'),
                          child: const Text(
                            'Sign Up',
                            style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ).animate().fadeIn(delay: 700.ms),
                    
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimaryLight,
      ),
    );
  }
}

