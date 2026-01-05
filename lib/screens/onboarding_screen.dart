import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../services/storage_service.dart';
import '../services/haptic_service.dart';
import '../widgets/animated_background.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  late AnimationController _fadeController;
  late AnimationController _pulseController;
  int _currentPage = 0;

  final List<OnboardingPage> _pages = [
    OnboardingPage(
      title: 'ONE TRUTH',
      subtitle: 'Per category. Forever.',
      description: 'No drafts. No edits. No second chances.\nJust one shot to say what matters.',
      icon: Icons.looks_one_rounded,
    ),
    OnboardingPage(
      title: 'LOCKED',
      subtitle: 'The moment you hit seal.',
      description: 'Your words become permanent.\nNo one can read them. Not even you.',
      icon: Icons.lock_rounded,
    ),
    OnboardingPage(
      title: 'FOREVER',
      subtitle: 'Until the end of time.',
      description: 'What you write here exists eternally.\nChoose your words carefully.',
      icon: Icons.all_inclusive_rounded,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: AppAnimations.slow,
    )..forward();
    
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _fadeController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _nextPage() {
    HapticService.instance.lightImpact();
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: AppAnimations.normal,
        curve: AppAnimations.smooth,
      );
    } else {
      _complete();
    }
  }

  Future<void> _complete() async {
    HapticService.instance.mediumImpact();
    final storage = await StorageService.getInstance();
    await storage.setOnboardingComplete(true);
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/category');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.void_,
      body: AnimatedBackground(
        showParticles: true,
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeController,
            child: Column(
              children: [
                // Skip button
                Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: GestureDetector(
                      onTap: _complete,
                      child: Text(
                        'SKIP',
                        style: AppTypography.labelMedium.copyWith(
                          color: AppColors.textMuted,
                        ),
                      ),
                    ),
                  ),
                ),
                
                // Pages
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (page) => setState(() => _currentPage = page),
                    itemCount: _pages.length,
                    itemBuilder: (context, index) => _buildPage(_pages[index]),
                  ),
                ),
                
                // Progress + button
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: Column(
                    children: [
                      // Progress dots
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(_pages.length, (index) {
                          final isActive = index == _currentPage;
                          return AnimatedContainer(
                            duration: AppAnimations.fast,
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: isActive ? 24 : 8,
                            height: 8,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4),
                              color: isActive ? AppColors.sacred : AppColors.frostBorder,
                            ),
                          );
                        }),
                      ),
                      
                      const SizedBox(height: AppSpacing.xl),
                      
                      // Continue button
                      GestureDetector(
                        onTap: _nextPage,
                        child: AnimatedBuilder(
                          animation: _pulseController,
                          builder: (context, child) {
                            final isLast = _currentPage == _pages.length - 1;
                            return Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: AppSpacing.md + 4),
                              decoration: BoxDecoration(
                                color: isLast 
                                    ? AppColors.sacred.withOpacity(0.15)
                                    : AppColors.frost,
                                borderRadius: BorderRadius.circular(AppRadius.full),
                                border: Border.all(
                                  color: isLast ? AppColors.sacred : AppColors.frostBorder,
                                  width: isLast ? 2 : 1,
                                ),
                                boxShadow: isLast ? AppShadows.glow(
                                  AppColors.sacred,
                                  intensity: 0.2 + (_pulseController.value * 0.1),
                                ) : null,
                              ),
                              child: Text(
                                isLast ? 'I UNDERSTAND. BEGIN.' : 'CONTINUE',
                                textAlign: TextAlign.center,
                                style: AppTypography.labelLarge.copyWith(
                                  color: isLast ? AppColors.sacred : AppColors.textSecondary,
                                  letterSpacing: 3,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPage(OnboardingPage page) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.sacred.withOpacity(0.5), width: 2),
              boxShadow: AppShadows.glow(AppColors.sacred, intensity: 0.3),
            ),
            child: Icon(page.icon, color: AppColors.sacred, size: 44),
          ),
          
          const SizedBox(height: AppSpacing.xxl),
          
          // Title
          Text(
            page.title,
            style: AppTypography.displayMedium.copyWith(
              color: AppColors.textPrimary,
              letterSpacing: 8,
            ),
          ),
          
          const SizedBox(height: AppSpacing.sm),
          
          // Subtitle
          Text(
            page.subtitle,
            style: AppTypography.bodyLarge.copyWith(
              color: AppColors.sacred,
              fontStyle: FontStyle.italic,
            ),
          ),
          
          const SizedBox(height: AppSpacing.xl),
          
          // Description
          Text(
            page.description,
            textAlign: TextAlign.center,
            style: AppTypography.bodyLarge.copyWith(
              color: AppColors.textSecondary,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}

class OnboardingPage {
  final String title;
  final String subtitle;
  final String description;
  final IconData icon;

  OnboardingPage({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.icon,
  });
}
