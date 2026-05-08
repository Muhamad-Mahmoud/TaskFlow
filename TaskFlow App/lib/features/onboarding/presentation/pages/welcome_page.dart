import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:taskflow/core/constants/app_colors.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: Stack(
        children: [
          // Decorative background elements
          Positioned(
            top: -100,
            right: -100,
            child: CircleAvatar(
              radius: 200,
              backgroundColor: AppColors.primary.withValues(alpha: 0.03),
            ),
          ),
          
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 40),
                  
                  // Illustration Hero
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(40),
                        border: Border.all(color: AppColors.borderLight, width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 40,
                            offset: const Offset(0, 20),
                          ),
                        ],
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Concentric circles animation
                          ...List.generate(3, (index) => 
                            Container(
                              width: 150 + (index * 50).toDouble(),
                              height: 150 + (index * 50).toDouble(),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppColors.primary.withValues(alpha: 0.05 / (index + 1)),
                                  width: 2,
                                ),
                              ),
                            ).animate(onPlay: (c) => c.repeat())
                             .scale(begin: const Offset(1, 1), end: const Offset(1.2, 1.2), duration: (2 + index).seconds, curve: Curves.easeInOut)
                             .fadeIn(duration: 1.seconds).fadeOut(delay: (1 + index).seconds)
                          ),
                          
                          const Icon(
                            Icons.auto_awesome_rounded,
                            size: 120,
                            color: AppColors.primary,
                          ).animate().scale(duration: 800.ms, curve: Curves.easeOut),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 64),
                  
                  // Text Content
                  Column(
                    children: [
                      RichText(
                        textAlign: TextAlign.center,
                        text: const TextSpan(
                          style: TextStyle(
                            fontSize: 38,
                            fontWeight: FontWeight.w900,
                            color: AppColors.textPrimaryLight,
                            height: 1.1,
                            letterSpacing: -1,
                          ),
                          children: [
                            TextSpan(text: 'Ready to '),
                            TextSpan(
                              text: 'Launch?',
                              style: TextStyle(color: AppColors.primary),
                            ),
                          ],
                        ),
                      ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2),
                      
                      const SizedBox(height: 20),
                      
                      const Text(
                        'Your workspace is ready. Let\'s build something extraordinary together.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          color: AppColors.textSecondaryLight,
                          height: 1.6,
                          fontWeight: FontWeight.w500,
                        ),
                      ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2),
                    ],
                  ),
                  
                  const SizedBox(height: 64),
                  
                  // Actions
                  Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => context.go('/home'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 22),
                            elevation: 10,
                            shadowColor: AppColors.primary.withValues(alpha: 0.4),
                          ),
                          child: const Text(
                            'Create Your First Project',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.2),
                      
                      const SizedBox(height: 32),
                      
                      // Social proof / Users mock
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 100,
                            height: 40,
                            child: Stack(
                              children: List.generate(4, (i) => 
                                Positioned(
                                  left: i * 22,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(color: Colors.white, width: 2),
                                    ),
                                    child: CircleAvatar(
                                      radius: 18,
                                      backgroundColor: [
                                        Colors.indigo.shade100,
                                        Colors.pink.shade100,
                                        const Color(0xFF50C878),
                                        AppColors.primary,
                                      ][i],
                                      child: i == 3 
                                        ? const Text('+12', style: TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold))
                                        : Icon(Icons.person, size: 18, color: [
                                            Colors.indigo,
                                            Colors.pink,
                                            const Color(0xFF50C878),
                                            Colors.white,
                                          ][i]),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'Join 12,000+ creators',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondaryLight,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ).animate().fadeIn(delay: 800.ms),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

