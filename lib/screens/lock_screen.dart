import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../services/audio_service.dart';
import '../services/ads_service.dart';
import '../services/haptic_service.dart';

class LockScreen extends StatefulWidget {
  const LockScreen({super.key});

  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen>
    with TickerProviderStateMixin {
  late AnimationController _phaseController;
  late AnimationController _lockController;
  late AnimationController _pulseController;
  late AnimationController _glowController;
  
  int _phase = 0;
  final List<String> _phases = [
    'PROCESSING',
    'ENCRYPTING',
    'SEALING',
    'LOCKED FOREVER',
  ];

  @override
  void initState() {
    super.initState();
    
    _phaseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    
    _lockController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);
    
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _startRitual();
  }

  Future<void> _startRitual() async {
    AudioService.instance.playWhisper();
    
    // Phase 0: Processing
    HapticService.instance.lightImpact();
    await Future.delayed(const Duration(milliseconds: 1500));
    if (!mounted) return;
    
    // Phase 1: Encrypting
    setState(() => _phase = 1);
    HapticService.instance.mediumImpact();
    await Future.delayed(const Duration(milliseconds: 1500));
    if (!mounted) return;
    
    // Phase 2: Sealing
    setState(() => _phase = 2);
    HapticService.instance.mediumImpact();
    _lockController.forward();
    await Future.delayed(const Duration(milliseconds: 2000));
    if (!mounted) return;
    
    // Phase 3: Locked Forever
    setState(() => _phase = 3);
    HapticService.instance.heavyImpact();
    _glowController.forward();
    _pulseController.stop();
    
    await Future.delayed(const Duration(milliseconds: 1500));
    if (!mounted) return;
    
    AdsService.instance.markFirstRunComplete();
    await AdsService.instance.showInterstitialAd();
    
    Navigator.pushReplacementNamed(context, '/sealed');
  }

  @override
  void dispose() {
    _phaseController.dispose();
    _lockController.dispose();
    _pulseController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isComplete = _phase == 3;
    
    return Scaffold(
      backgroundColor: AppColors.void_,
      body: Stack(
        children: [
          // Background glow
          AnimatedBuilder(
            animation: _glowController,
            builder: (context, child) {
              return Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.center,
                    radius: 1.0 + (_glowController.value * 0.5),
                    colors: [
                      (isComplete ? AppColors.sacred : AppColors.pulse)
                          .withOpacity(0.1 * _glowController.value),
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
                // Lock icon with animation
                AnimatedBuilder(
                  animation: Listenable.merge([_lockController, _pulseController, _glowController]),
                  builder: (context, child) {
                    final scale = isComplete 
                        ? 1.0 + (_glowController.value * 0.1)
                        : 1.0 + (_pulseController.value * 0.05);
                    final color = isComplete ? AppColors.sacred : AppColors.pulse;
                    
                    return Transform.scale(
                      scale: scale,
                      child: Container(
                        width: 140,
                        height: 140,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: color.withOpacity(0.6 + (_lockController.value * 0.4)),
                            width: 3,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: color.withOpacity(0.3 + (_lockController.value * 0.4)),
                              blurRadius: 30 + (_lockController.value * 30),
                              spreadRadius: 5 + (_lockController.value * 10),
                            ),
                          ],
                        ),
                        child: Icon(
                          _phase < 2 
                              ? Icons.hourglass_top_rounded
                              : _phase < 3 
                                  ? Icons.lock_open_rounded 
                                  : Icons.lock_rounded,
                          color: color,
                          size: 56,
                        ),
                      ),
                    );
                  },
                ),
                
                const SizedBox(height: AppSpacing.xxl),
                
                // Phase text
                AnimatedSwitcher(
                  duration: AppAnimations.normal,
                  child: Text(
                    _phases[_phase],
                    key: ValueKey(_phase),
                    style: AppTypography.headlineLarge.copyWith(
                      color: isComplete ? AppColors.sacred : AppColors.textPrimary,
                      letterSpacing: 6,
                    ),
                  ),
                ),
                
                const SizedBox(height: AppSpacing.lg),
                
                // Progress dots
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(4, (index) {
                    final isActive = index <= _phase;
                    final isCurrent = index == _phase;
                    return AnimatedContainer(
                      duration: AppAnimations.fast,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: isCurrent ? 24 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        color: isActive 
                            ? (isComplete ? AppColors.sacred : AppColors.pulse)
                            : AppColors.frostBorder,
                      ),
                    );
                  }),
                ),
                
                const SizedBox(height: AppSpacing.huge),
                
                // Warning text
                if (!isComplete)
                  AnimatedBuilder(
                    animation: _pulseController,
                    builder: (context, child) {
                      return Text(
                        'DO NOT CLOSE THIS SCREEN',
                        style: AppTypography.warning.copyWith(
                          color: AppColors.pulse.withOpacity(0.4 + (_pulseController.value * 0.4)),
                        ),
                      );
                    },
                  ),
                
                if (isComplete)
                  Text(
                    'YOUR TRUTH IS NOW ETERNAL',
                    style: AppTypography.labelMedium.copyWith(
                      color: AppColors.sacred.withOpacity(0.7),
                      letterSpacing: 3,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
