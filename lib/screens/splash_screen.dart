import 'package:flutter/material.dart';
import 'dart:math' as math;
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
  late AnimationController _lockController;
  late AnimationController _textController;
  late AnimationController _messageController;
  late AnimationController _counterController;
  late AnimationController _pulseController;
  late AnimationController _shakeController;
  
  late Animation<double> _lockAnimation;
  late Animation<double> _textAnimation;
  late Animation<double> _messageAnimation;
  late Animation<double> _counterAnimation;
  
  int _displayedCount = 0;
  int _targetCount = 523;
  bool _ready = false;
  bool _lockClosed = false;

  @override
  void initState() {
    super.initState();
    
    // Lock closing animation (starts open, closes)
    _lockController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _lockAnimation = CurvedAnimation(
      parent: _lockController,
      curve: Curves.easeInOutBack,
    );
    
    // Shake effect when lock closes
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    
    // App name fade in
    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _textAnimation = CurvedAnimation(
      parent: _textController,
      curve: Curves.easeOut,
    );
    
    // "Once locked" message fade in
    _messageController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _messageAnimation = CurvedAnimation(
      parent: _messageController,
      curve: Curves.easeOut,
    );
    
    // Counter animation
    _counterController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
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
    
    // Subtle pulse for glow
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
    
    _startSequence();
  }

  Future<void> _startSequence() async {
    // Initialize services in background
    _initializeServices();
    
    await Future.delayed(const Duration(milliseconds: 600));
    
    // Show app name first
    _textController.forward();
    await Future.delayed(const Duration(milliseconds: 1000));
    
    // Close the lock with dramatic effect
    _lockController.forward();
    await Future.delayed(const Duration(milliseconds: 400));
    setState(() => _lockClosed = true);
    _shakeController.forward();
    
    await Future.delayed(const Duration(milliseconds: 600));
    
    // Fade in the "once locked" message
    _messageController.forward();
    await Future.delayed(const Duration(milliseconds: 800));
    
    // Count up (social proof)
    _counterController.forward();
    
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
    _lockController.dispose();
    _textController.dispose();
    _messageController.dispose();
    _counterController.dispose();
    _pulseController.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.void_,
      body: Stack(
        children: [
          // Elegant gradient background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.void_,
                  AppColors.voidDeep,
                  AppColors.void_,
                ],
              ),
            ),
          ),
          
          // Pulsing center glow
          AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              return Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.center,
                    radius: 0.8,
                    colors: [
                      (_lockClosed ? AppColors.sacred : AppColors.textMuted)
                          .withOpacity(0.08 + (_pulseController.value * 0.04)),
                      Colors.transparent,
                    ],
                  ),
                ),
              );
            },
          ),
          
          // Main content
          SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(flex: 2),
                  
                  // Animated Lock Icon
                  AnimatedBuilder(
                    animation: Listenable.merge([_lockAnimation, _shakeController]),
                    builder: (context, child) {
                      final shakeOffset = _shakeController.isAnimating
                          ? math.sin(_shakeController.value * math.pi * 4) * 3
                          : 0.0;
                      
                      return Transform.translate(
                        offset: Offset(shakeOffset, 0),
                        child: Container(
                          width: 140,
                          height: 140,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.frost.withOpacity(0.05),
                            border: Border.all(
                              color: _lockClosed 
                                  ? AppColors.sacred.withOpacity(0.8)
                                  : AppColors.textMuted.withOpacity(0.3),
                              width: _lockClosed ? 3 : 2,
                            ),
                            boxShadow: _lockClosed 
                                ? AppShadows.glow(AppColors.sacred, intensity: 0.5)
                                : null,
                          ),
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            child: Icon(
                              _lockClosed ? Icons.lock_rounded : Icons.lock_open_rounded,
                              key: ValueKey(_lockClosed),
                              color: _lockClosed ? AppColors.sacred : AppColors.textMuted,
                              size: 56,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  
                  const SizedBox(height: 48),
                  
                  // App name with elegant typography
                  FadeTransition(
                    opacity: _textAnimation,
                    child: Column(
                      children: [
                        Text(
                          'LIMITED',
                          style: AppTypography.displayLarge.copyWith(
                            color: AppColors.textPrimary,
                            letterSpacing: 20,
                            fontWeight: FontWeight.w200,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          width: 60,
                          height: 1,
                          color: AppColors.sacred.withOpacity(0.5),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // "Once locked, it's closed" message - fades in after lock closes
                  FadeTransition(
                    opacity: _messageAnimation,
                    child: Text(
                      'ONCE LOCKED, IT\'S CLOSED.',
                      style: AppTypography.labelMedium.copyWith(
                        color: AppColors.sacred,
                        letterSpacing: 6,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  FadeTransition(
                    opacity: _messageAnimation,
                    child: Text(
                      'No edits. No deletes. Forever.',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textMuted,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                  
                  const Spacer(flex: 1),
                  
                  // Counter - Social proof
                  FadeTransition(
                    opacity: _messageAnimation,
                    child: Column(
                      children: [
                        Text(
                          _formatNumber(_displayedCount),
                          style: AppTypography.counter.copyWith(
                            fontSize: 48,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'TRUTHS SEALED FOREVER',
                          style: AppTypography.counterLabel.copyWith(
                            letterSpacing: 3,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const Spacer(flex: 2),
                ],
              ),
            ),
          ),
          
          // Enter button at bottom
          Positioned(
            bottom: 50,
            left: 32,
            right: 32,
            child: AnimatedOpacity(
              opacity: _ready ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 800),
              child: AnimatedSlide(
                offset: _ready ? Offset.zero : const Offset(0, 0.5),
                duration: const Duration(milliseconds: 800),
                curve: Curves.easeOutCubic,
                child: GestureDetector(
                  onTap: _ready ? _enter : null,
                  child: AnimatedBuilder(
                    animation: _pulseController,
                    builder: (context, child) {
                      return Container(
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.sacred.withOpacity(0.2),
                              AppColors.sacred.withOpacity(0.1),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(50),
                          border: Border.all(
                            color: AppColors.sacred.withOpacity(0.6 + (_pulseController.value * 0.2)),
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.sacred.withOpacity(0.3 + (_pulseController.value * 0.1)),
                              blurRadius: 20,
                              spreadRadius: 0,
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'BEGIN YOUR TRUTH',
                              style: AppTypography.labelLarge.copyWith(
                                color: AppColors.sacred,
                                letterSpacing: 4,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Icon(
                              Icons.arrow_forward_rounded,
                              color: AppColors.sacred,
                              size: 20,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
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
