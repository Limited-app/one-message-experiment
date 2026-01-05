import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../services/haptic_service.dart';
import '../services/firebase_service.dart';

class SealedScreen extends StatefulWidget {
  const SealedScreen({super.key});

  @override
  State<SealedScreen> createState() => _SealedScreenState();
}

class _SealedScreenState extends State<SealedScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _revealController;
  
  int _countdown = 10;
  bool _rewardReady = false;

  @override
  void initState() {
    super.initState();
    
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    
    _revealController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    
    _startDelayedReveal();
  }

  Future<void> _startDelayedReveal() async {
    // Countdown with heartbeat haptics
    for (int i = 10; i >= 1; i--) {
      if (!mounted) return;
      
      setState(() => _countdown = i);
      
      // Heartbeat effect
      HapticService.instance.lightImpact();
      await Future.delayed(const Duration(milliseconds: 100));
      HapticService.instance.lightImpact();
      
      await Future.delayed(const Duration(milliseconds: 900));
    }
    
    // Reward ready
    HapticService.instance.heavyImpact();
    _revealController.forward();
    setState(() => _rewardReady = true);
  }

  void _revealReward() {
    HapticService.instance.mediumImpact();
    Navigator.pushReplacementNamed(context, '/reward');
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _revealController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.void_,
      body: WillPopScope(
        onWillPop: () async => false, // Cannot go back
        child: Stack(
          children: [
            // Subtle glow
            AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                return Container(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: Alignment.center,
                      radius: 1.2,
                      colors: [
                        AppColors.sacred.withOpacity(0.05 + (_pulseController.value * 0.03)),
                        AppColors.void_,
                      ],
                    ),
                  ),
                );
              },
            ),
            
            // Content
            SafeArea(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Lock icon
                      AnimatedBuilder(
                        animation: _pulseController,
                        builder: (context, child) {
                          return Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.sacred.withOpacity(0.5 + (_pulseController.value * 0.3)),
                                width: 2,
                              ),
                            ),
                            child: const Icon(
                              Icons.lock_rounded,
                              color: AppColors.sacred,
                              size: 40,
                            ),
                          );
                        },
                      ),
                      
                      const SizedBox(height: AppSpacing.xxl),
                      
                      // Main text
                      Text(
                        'Your truth is sealed.',
                        style: AppTypography.headlineLarge.copyWith(
                          color: AppColors.textPrimary,
                        ),
                      ),
                      
                      const SizedBox(height: AppSpacing.lg),
                      
                      // Subtext
                      Text(
                        _rewardReady 
                            ? 'Your reward is ready.'
                            : 'Your reward will reveal itself shortly.',
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      
                      const SizedBox(height: AppSpacing.xxl),
                      
                      // Countdown or reveal button
                      if (!_rewardReady)
                        Text(
                          '$_countdown',
                          style: AppTypography.displayLarge.copyWith(
                            color: AppColors.sacred.withOpacity(0.5),
                          ),
                        ),
                      
                      if (_rewardReady)
                        FadeTransition(
                          opacity: _revealController,
                          child: GestureDetector(
                            onTap: _revealReward,
                            child: AnimatedBuilder(
                              animation: _pulseController,
                              builder: (context, child) {
                                return Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: AppSpacing.xxl,
                                    vertical: AppSpacing.md + 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.sacred.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(AppRadius.full),
                                    border: Border.all(
                                      color: AppColors.sacred,
                                      width: 2,
                                    ),
                                    boxShadow: AppShadows.glow(
                                      AppColors.sacred,
                                      intensity: 0.2 + (_pulseController.value * 0.15),
                                    ),
                                  ),
                                  child: Text(
                                    'REVEAL',
                                    style: AppTypography.labelLarge.copyWith(
                                      color: AppColors.sacred,
                                      letterSpacing: 6,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
