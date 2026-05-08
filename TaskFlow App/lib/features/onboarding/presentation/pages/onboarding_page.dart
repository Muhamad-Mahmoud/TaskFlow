import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:taskflow/core/constants/app_colors.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  final List<Map<String, dynamic>> _pages = [
    {
      'title': ['Master your team\'s ', 'workflow'],
      'body': 'Experience fluid task orchestration designed for high-performing teams who value clarity over chaos.',
      'icon': Icons.rocket_launch_rounded,
    },
    {
      'title': ['Achieve more with ', 'clarity'],
      'body': 'Organize, prioritize, and track all your work seamlessly in one intuitive space.',
      'icon': Icons.auto_awesome_rounded,
    },
    {
      'title': ['Collaborate ', 'effortlessly'],
      'body': 'Stay connected with your team and keep everyone on the same page, always.',
      'icon': Icons.groups_rounded,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: Stack(
        children: [
          // Background Glow
          Positioned(
            top: -100,
            right: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withValues(alpha: 0.08),
              ),
            ).animate().fadeIn(duration: 800.ms).scale(begin: const Offset(0.8, 0.8)),
          ),
          
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 32),
                // Logo
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.primary, AppColors.primaryLight],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.account_tree_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 14),
                    const Text(
                      'TaskFlow',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textPrimaryLight,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ).animate().fadeIn(delay: 200.ms, duration: 600.ms).slideY(begin: -0.2),
                
                Expanded(
                  child: PageView.builder(
                    controller: _controller,
                    onPageChanged: (i) => setState(() => _currentPage = i),
                    itemCount: _pages.length,
                    itemBuilder: (ctx, i) => _buildPage(_pages[i]),
                  ),
                ),
                
                // Bottom Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Pager indicators
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          _pages.length,
                          (i) => AnimatedContainer(
                            duration: const Duration(milliseconds: 400),
                            curve: Curves.easeInOut,
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: _currentPage == i ? 32 : 8,
                            height: 8,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: _currentPage == i
                                  ? AppColors.primary
                                  : AppColors.primary.withValues(alpha: 0.15),
                            ),
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // Action Buttons
                      Row(
                        children: [
                          if (_currentPage != _pages.length - 1)
                            Expanded(
                              child: TextButton(
                                onPressed: () => _controller.animateToPage(
                                  _pages.length - 1,
                                  duration: 600.ms,
                                  curve: Curves.easeOutQuart,
                                ),
                                child: const Text(
                                  'Skip',
                                  style: TextStyle(
                                    color: AppColors.textSecondaryLight,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          
                          Expanded(
                            flex: 2,
                            child: ElevatedButton(
                              onPressed: () {
                                if (_currentPage == _pages.length - 1) {
                                  context.go('/login');
                                } else {
                                  _controller.nextPage(
                                    duration: 600.ms,
                                    curve: Curves.easeOutQuart,
                                  );
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 20),
                                backgroundColor: AppColors.primary,
                                elevation: 8,
                                shadowColor: AppColors.primary.withValues(alpha: 0.3),
                              ),
                              child: Text(
                                _currentPage == _pages.length - 1 ? 'Get Started' : 'Next',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPage(Map<String, dynamic> data) {
    final titleParts = data['title'] as List<String>;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Illustration Hero
          Flexible(
            child: Container(
              constraints: const BoxConstraints(maxHeight: 320, minHeight: 180),
              width: double.infinity,
              decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(32),
              border: Border.all(color: AppColors.borderLight, width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 30,
                  offset: const Offset(0, 15),
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Abstract background shapes
                Positioned(
                  top: 40,
                  left: 40,
                  child: Icon(Icons.circle, color: AppColors.primary.withValues(alpha: 0.05), size: 100),
                ),
                Icon(
                  data['icon'],
                  size: 100,
                  color: AppColors.primary,
                ).animate(onPlay: (controller) => controller.repeat(reverse: true))
                 .moveY(begin: -10, end: 10, duration: 2.seconds, curve: Curves.easeInOut),
              ],
            ),
          ).animate().scale(delay: 300.ms, duration: 600.ms, curve: Curves.easeOut),
          ),
          
          const SizedBox(height: 32),
          
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: const TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.w900,
                color: AppColors.textPrimaryLight,
                height: 1.1,
                letterSpacing: -0.5,
              ),
              children: [
                TextSpan(text: titleParts[0]),
                TextSpan(
                  text: titleParts[1],
                  style: const TextStyle(color: AppColors.primary),
                ),
              ],
            ),
          ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.1),
          
          const SizedBox(height: 20),
          
          Text(
            data['body']!,
            style: const TextStyle(
              fontSize: 17,
              color: AppColors.textSecondaryLight,
              height: 1.6,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: 700.ms).slideY(begin: 0.1),
        ],
      ),
    );
  }
}

