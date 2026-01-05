import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../constants/app_constants.dart';
import '../widgets/animated_background.dart';
import '../services/haptic_service.dart';

class WhyScreen extends StatefulWidget {
  const WhyScreen({super.key});

  @override
  State<WhyScreen> createState() => _WhyScreenState();
}

class _WhyScreenState extends State<WhyScreen> with TickerProviderStateMixin {
  late AnimationController _pulseController;
  final PageController _pageController = PageController();
  int _current = 0;

  final List<_Section> _sections = [
    _Section('We all carry weight.', 'Words unspoken. Feelings buried. Truths we\'ve hidden so deep we forgot they\'re there.\n\nBut they don\'t disappear. They echo.', Icons.favorite_border_rounded),
    _Section('Some things need to be said.', 'Not for validation. Not for a response.\n\nJust to exist outside of you. To be real. To be released.', Icons.chat_bubble_outline_rounded),
    _Section('One truth. One chance.', 'No edits. No deletes. No comments.\n\nJust your words, sealed forever. A ritual of release.', Icons.lock_outline_rounded),
    _Section('You deserve to be lighter.', 'The confession you\'ve held. The goodbye you never said. The love you never expressed.\n\nIt\'s time.', Icons.air_rounded),
  ];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(vsync: this, duration: const Duration(milliseconds: 2000))..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _next() {
    HapticService.instance.lightImpact();
    if (_current < _sections.length - 1) {
      _pageController.nextPage(duration: AppAnimations.normal, curve: AppAnimations.smooth);
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.void_,
      body: AnimatedBackground(
        showParticles: true,
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 44, height: 44,
                        decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.frost, border: Border.all(color: AppColors.frostBorder)),
                        child: const Icon(Icons.close, color: AppColors.textSecondary, size: 20),
                      ),
                    ),
                    Text('WHY LIMITED', style: AppTypography.labelMedium.copyWith(color: AppColors.textMuted)),
                    const SizedBox(width: 44),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                child: Row(
                  children: List.generate(_sections.length, (i) => Expanded(
                    child: AnimatedContainer(
                      duration: AppAnimations.fast,
                      height: 2,
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      decoration: BoxDecoration(
                        color: i <= _current ? AppColors.sacred : AppColors.frostBorder,
                        borderRadius: BorderRadius.circular(1),
                      ),
                    ),
                  )),
                ),
              ),
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (i) => setState(() => _current = i),
                  itemCount: _sections.length,
                  itemBuilder: (context, i) {
                    final s = _sections[i];
                    return Padding(
                      padding: const EdgeInsets.all(AppSpacing.xl),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 80, height: 80,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.sacred.withOpacity(0.5)),
                              boxShadow: AppShadows.glow(AppColors.sacred, intensity: 0.2),
                            ),
                            child: Icon(s.icon, color: AppColors.sacred, size: 32),
                          ),
                          const SizedBox(height: AppSpacing.xxl),
                          Text(s.title, textAlign: TextAlign.center, style: AppTypography.headlineLarge),
                          const SizedBox(height: AppSpacing.lg),
                          Text(s.body, textAlign: TextAlign.center, style: AppTypography.bodyLarge),
                        ],
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: _next,
                      child: AnimatedBuilder(
                        animation: _pulseController,
                        builder: (context, child) {
                          final isLast = _current == _sections.length - 1;
                          return Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: AppSpacing.md + 4),
                            decoration: BoxDecoration(
                              color: isLast ? AppColors.sacred.withOpacity(0.15) : AppColors.frost,
                              borderRadius: BorderRadius.circular(AppRadius.full),
                              border: Border.all(color: isLast ? AppColors.sacred : AppColors.frostBorder, width: isLast ? 2 : 1),
                              boxShadow: isLast ? AppShadows.glow(AppColors.sacred, intensity: 0.2 + (_pulseController.value * 0.1)) : null,
                            ),
                            child: Text(
                              isLast ? 'BEGIN' : 'CONTINUE',
                              textAlign: TextAlign.center,
                              style: AppTypography.labelLarge.copyWith(color: isLast ? AppColors.sacred : AppColors.textSecondary, letterSpacing: 3),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    GestureDetector(
                      onTap: () => Share.share(AppStrings.inviteMessage),
                      child: Text('SHARE THIS', style: AppTypography.labelMedium.copyWith(color: AppColors.textMuted)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Section {
  final String title, body;
  final IconData icon;
  _Section(this.title, this.body, this.icon);
}
