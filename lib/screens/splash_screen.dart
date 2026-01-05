import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../services/ads_service.dart';
import '../services/storage_service.dart';
import '../services/premium_service.dart';
import '../services/firebase_service.dart';
import '../widgets/animated_background.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _vaultController;
  late AnimationController _textController;
  late AnimationController _counterController;
  late AnimationController _pulseController;
  
  late Animation<double> _vaultAnimation;
  late Animation<double> _textAnimation;
  late Animation<double> _counterAnimation;
  
  int _displayedCount = 0;
  int _targetCount = 523; // Will be fetched from Firebase
  bool _ready = false; // Show enter button when ready

  @override
  void initState() {
    super.initState();
    
    // Vault door opening
    _vaultController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    _vaultAnimation = CurvedAnimation(
      parent: _vaultController,
      curve: Curves.easeOutCubic,
    );
    
    // Text fade in
    _textController = AnimationController(
      vsync: this,
      duration: AppAnimations.slow,
    );
    _textAnimation = CurvedAnimation(
      parent: _textController,
      curve: Curves.easeOut,
    );
    
    // Counter animation
    _counterController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _counterAnimation = CurvedAnimation(
      parent: _counterController,
      curve: Curves.easeOutCubic,
    );
    _counterController.addListener(() {
      setState(() {
        _displayedCount = (_counterAnimation.value * _targetCount).toInt();
      });
    });
    
    // Pulse
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    
    _startSequence();
  }

  Future<void> _startSequence() async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Open vault
    _vaultController.forward();
    await Future.delayed(const Duration(milliseconds: 1200));
    
    // Show text
    _textController.forward();
    await Future.delayed(const Duration(milliseconds: 800));
    
    // Count up (social proof)
    _counterController.forward();
    
    // Initialize services
    await _initializeServices();
    
    // Show enter button
    await Future.delayed(const Duration(milliseconds: 1500));
    if (mounted) setState(() => _ready = true);
  }

  void _enter() {
    _navigate();
  }

  Future<void> _initializeServices() async {
    // Initialize Firebase first
    await FirebaseService.instance.initialize();
    
    // Fetch real count from Firebase
    final realCount = await FirebaseService.instance.getGlobalSealedCount();
    setState(() => _targetCount = realCount);
    
    await AdsService.instance.initialize();
    final storage = await StorageService.getInstance();
    await PremiumService.instance.initialize(storage);
  }

  Future<void> _navigate() async {
    if (!mounted) return;
    final storage = await StorageService.getInstance();
    final hasOnboarded = await storage.isOnboardingComplete();
    Navigator.pushReplacementNamed(
      context,
      hasOnboarded ? '/category' : '/onboarding',
    );
  }

  @override
  void dispose() {
    _vaultController.dispose();
    _textController.dispose();
    _counterController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.void_,
      body: Stack(
        children: [
          // Pulsing background glow
          AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              return Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.center,
                    radius: 1.5,
                    colors: [
                      AppColors.pulse.withOpacity(0.05 + (_pulseController.value * 0.03)),
                      AppColors.void_,
                    ],
                  ),
                ),
              );
            },
          ),
          
          // Content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Vault icon
                AnimatedBuilder(
                  animation: _vaultAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: 0.5 + (_vaultAnimation.value * 0.5),
                      child: Opacity(
                        opacity: _vaultAnimation.value,
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.sacred.withOpacity(0.6),
                              width: 2,
                            ),
                            boxShadow: AppShadows.glow(AppColors.sacred, intensity: 0.4),
                          ),
                          child: Icon(
                            _vaultAnimation.value < 0.5 
                                ? Icons.lock_rounded 
                                : Icons.lock_open_rounded,
                            color: AppColors.sacred,
                            size: 48,
                          ),
                        ),
                      ),
                    );
                  },
                ),
                
                const SizedBox(height: AppSpacing.xxl),
                
                // App name
                FadeTransition(
                  opacity: _textAnimation,
                  child: Text(
                    'LIMITED',
                    style: AppTypography.displayLarge.copyWith(
                      color: AppColors.textPrimary,
                      letterSpacing: 16,
                    ),
                  ),
                ),
                
                const SizedBox(height: AppSpacing.md),
                
                // Tagline
                FadeTransition(
                  opacity: _textAnimation,
                  child: Text(
                    'ONE TRUTH. LOCKED FOREVER.',
                    style: AppTypography.labelMedium.copyWith(
                      color: AppColors.textMuted,
                      letterSpacing: 4,
                    ),
                  ),
                ),
                
                const SizedBox(height: AppSpacing.huge),
                
                // FOMO Counter - Social proof
                FadeTransition(
                  opacity: _textAnimation,
                  child: Column(
                    children: [
                      Text(
                        _formatNumber(_displayedCount),
                        style: AppTypography.counter,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'TRUTHS SEALED FOREVER',
                        style: AppTypography.counterLabel,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Enter button at bottom
          Positioned(
            bottom: 60,
            left: 40,
            right: 40,
            child: AnimatedOpacity(
              opacity: _ready ? 1.0 : 0.0,
              duration: AppAnimations.slow,
              child: GestureDetector(
                onTap: _ready ? _enter : null,
                child: AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, child) {
                    return Container(
                      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md + 4),
                      decoration: BoxDecoration(
                        color: AppColors.sacred.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(AppRadius.full),
                        border: Border.all(
                          color: AppColors.sacred.withOpacity(0.5 + (_pulseController.value * 0.3)),
                          width: 2,
                        ),
                        boxShadow: AppShadows.glow(AppColors.sacred, intensity: 0.2 + (_pulseController.value * 0.15)),
                      ),
                      child: Text(
                        'ENTER',
                        textAlign: TextAlign.center,
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
          ),
        ],
      ),
    );
  }
  
  String _formatNumber(int num) {
    if (num >= 1000000) {
      return '${(num / 1000000).toStringAsFixed(1)}M';
    } else if (num >= 1000) {
      return '${(num / 1000).toStringAsFixed(0)},${(num % 1000).toString().padLeft(3, '0')}';
    }
    return num.toString();
  }
}
