import 'dart:math';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../constants/app_constants.dart';
import '../services/haptic_service.dart';
import '../services/firebase_service.dart';

class RewardScreen extends StatefulWidget {
  const RewardScreen({super.key});

  @override
  State<RewardScreen> createState() => _RewardScreenState();
}

class _RewardScreenState extends State<RewardScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _cardController;
  late AnimationController _pulseController;
  
  String _rewardLine = '';
  int _globalCount = 0;

  @override
  void initState() {
    super.initState();
    
    _fadeController = AnimationController(
      vsync: this,
      duration: AppAnimations.slow,
    )..forward();
    
    _cardController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
    
    _selectReward();
    
    Future.delayed(const Duration(milliseconds: 400), () {
      _cardController.forward();
    });
  }

  void _selectReward() {
    final random = Random();
    _rewardLine = RewardLines.all[random.nextInt(RewardLines.all.length)];
    _loadGlobalCount();
  }

  Future<void> _loadGlobalCount() async {
    final count = await FirebaseService.instance.getGlobalSealedCount();
    if (mounted) setState(() => _globalCount = count);
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _cardController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _share() {
    HapticService.instance.mediumImpact();
    final shareText = '''
I just locked my truth forever.

"$_rewardLine"

You only get one chance.

LIMITED.
''';
    Share.share(shareText);
    _continue();
  }

  void _keepPrivate() {
    HapticService.instance.lightImpact();
    _continue();
  }

  void _continue() {
    Navigator.pushNamedAndRemoveUntil(context, '/category', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.void_,
      body: WillPopScope(
        onWillPop: () async => false, // Cannot go back - must choose
        child: Stack(
          children: [
            // Glow background
            AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                return Container(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: Alignment.center,
                      radius: 1.5,
                      colors: [
                        AppColors.sacred.withOpacity(0.06 + (_pulseController.value * 0.04)),
                        AppColors.void_,
                      ],
                    ),
                  ),
                );
              },
            ),
            
            SafeArea(
              child: FadeTransition(
                opacity: _fadeController,
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: Column(
                    children: [
                      const Spacer(),
                      
                      // Reward card
                      AnimatedBuilder(
                        animation: _cardController,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: 0.8 + (_cardController.value * 0.2),
                            child: Opacity(
                              opacity: _cardController.value,
                              child: child,
                            ),
                          );
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(AppSpacing.xxl),
                          decoration: BoxDecoration(
                            color: AppColors.frost.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(AppRadius.xl),
                            border: Border.all(
                              color: AppColors.sacred.withOpacity(0.4),
                              width: 2,
                            ),
                          ),
                          child: Column(
                            children: [
                              // Reward text - cryptic, no explanation
                              Text(
                                _rewardLine,
                                textAlign: TextAlign.center,
                                style: AppTypography.headlineMedium.copyWith(
                                  color: AppColors.textPrimary,
                                  fontStyle: FontStyle.italic,
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      const Spacer(),
                      
                      // FORCED DECISION - No skip button
                      // User MUST choose one
                      
                      GestureDetector(
                        onTap: _share,
                        child: AnimatedBuilder(
                          animation: _pulseController,
                          builder: (context, child) {
                            return Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: AppSpacing.md + 4),
                              decoration: BoxDecoration(
                                color: AppColors.sacred.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(AppRadius.full),
                                border: Border.all(color: AppColors.sacred, width: 2),
                                boxShadow: AppShadows.glow(
                                  AppColors.sacred,
                                  intensity: 0.2 + (_pulseController.value * 0.1),
                                ),
                              ),
                              child: Text(
                                'SHARE THE REWARD',
                                textAlign: TextAlign.center,
                                style: AppTypography.labelLarge.copyWith(
                                  color: AppColors.sacred,
                                  letterSpacing: 3,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      
                      const SizedBox(height: AppSpacing.md),
                      
                      GestureDetector(
                        onTap: _keepPrivate,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md + 4),
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(AppRadius.full),
                            border: Border.all(color: AppColors.frostBorder),
                          ),
                          child: Text(
                            'KEEP IT PRIVATE',
                            textAlign: TextAlign.center,
                            style: AppTypography.labelLarge.copyWith(
                              color: AppColors.textMuted,
                              letterSpacing: 3,
                            ),
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: AppSpacing.xl),
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
