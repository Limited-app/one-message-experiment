import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../constants/app_constants.dart';
import '../services/storage_service.dart';
import '../services/haptic_service.dart';
import '../services/premium_service.dart';
import '../widgets/animated_background.dart';

class FinalTruthScreen extends StatefulWidget {
  const FinalTruthScreen({super.key});

  @override
  State<FinalTruthScreen> createState() => _FinalTruthScreenState();
}

class _FinalTruthScreenState extends State<FinalTruthScreen> with TickerProviderStateMixin {
  final _controller = TextEditingController();
  late AnimationController _pulseController;
  int _step = 0;
  int _charCount = 0;
  bool _showFinal = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500))..repeat(reverse: true);
    _controller.addListener(() => setState(() => _charCount = _controller.text.length));
  }

  @override
  void dispose() {
    _controller.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _next() {
    HapticService.instance.mediumImpact();
    if (_step < 2) {
      setState(() => _step++);
    } else if (!_showFinal && _charCount >= 10) {
      setState(() => _showFinal = true);
    } else if (_showFinal) {
      _seal();
    }
  }

  Future<void> _seal() async {
    HapticService.instance.heavyImpact();
    final storage = await StorageService.getInstance();
    await storage.saveMessage('Final Truth', _controller.text);
    await storage.setSubmitted('Final Truth', true);
    
    // Show goodbye then exit
    if (mounted) {
      setState(() => _step = 3);
      await Future.delayed(const Duration(seconds: 3));
      // In real app: uninstall or lock permanently
      Navigator.pushNamedAndRemoveUntil(context, '/category', (r) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.void_,
      body: AnimatedBackground(
        showParticles: true,
        showAura: true,
        auraColor: _step < 3 ? AppColors.pulse : AppColors.sacred,
        auraIntensity: 0.3,
        child: SafeArea(
          child: _step == 0 ? _buildIntro() : _step == 1 ? _buildConfirm() : _step == 2 ? _buildWrite() : _buildGoodbye(),
        ),
      ),
    );
  }

  Widget _buildIntro() {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.frost, border: Border.all(color: AppColors.frostBorder)),
                  child: const Icon(Icons.close, color: AppColors.textSecondary, size: 20),
                ),
              ),
            ],
          ),
          const Spacer(),
          AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              return Container(
                width: 100, height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.pulse, width: 3),
                  boxShadow: AppShadows.pulseGlow(_pulseController.value),
                ),
                child: const Icon(Icons.warning_rounded, color: AppColors.pulse, size: 44),
              );
            },
          ),
          const SizedBox(height: AppSpacing.xxl),
          Text('FINAL TRUTH', style: AppTypography.displayMedium.copyWith(color: AppColors.pulse, letterSpacing: 8)),
          const SizedBox(height: AppSpacing.lg),
          Text('This is your last message.\nAfter this, LIMITED self-destructs.', textAlign: TextAlign.center, style: AppTypography.bodyLarge),
          const Spacer(),
          GestureDetector(
            onTap: _next,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.md + 4),
              decoration: BoxDecoration(
                color: AppColors.pulse.withOpacity(0.15),
                borderRadius: BorderRadius.circular(AppRadius.full),
                border: Border.all(color: AppColors.pulse, width: 2),
              ),
              child: Text('I UNDERSTAND', textAlign: TextAlign.center, style: AppTypography.labelLarge.copyWith(color: AppColors.pulse, letterSpacing: 3)),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }

  Widget _buildConfirm() {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        children: [
          const Spacer(),
          const Icon(Icons.delete_forever_rounded, color: AppColors.pulse, size: 80),
          const SizedBox(height: AppSpacing.xxl),
          Text('ARE YOU SURE?', style: AppTypography.displayMedium.copyWith(color: AppColors.pulse, letterSpacing: 6)),
          const SizedBox(height: AppSpacing.lg),
          Text('This action cannot be undone.\nThe app will permanently lock after this message.', textAlign: TextAlign.center, style: AppTypography.bodyLarge),
          const Spacer(),
          GestureDetector(
            onTap: _next,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.md + 4),
              decoration: BoxDecoration(
                color: AppColors.pulse.withOpacity(0.15),
                borderRadius: BorderRadius.circular(AppRadius.full),
                border: Border.all(color: AppColors.pulse, width: 2),
              ),
              child: Text('YES, CONTINUE', textAlign: TextAlign.center, style: AppTypography.labelLarge.copyWith(color: AppColors.pulse, letterSpacing: 3)),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Text('Go back', style: AppTypography.bodyMedium.copyWith(color: AppColors.textMuted)),
          ),
          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }

  Widget _buildWrite() {
    final canSeal = _charCount >= 10;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => setState(() => _step = 1),
                child: Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.frost, border: Border.all(color: AppColors.frostBorder)),
                  child: const Icon(Icons.arrow_back, color: AppColors.textSecondary, size: 20),
                ),
              ),
              const Spacer(),
              Text('$_charCount', style: AppTypography.labelMedium.copyWith(color: canSeal ? AppColors.sacred : AppColors.textMuted)),
            ],
          ),
        ),
        AnimatedBuilder(
          animation: _pulseController,
          builder: (context, child) {
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppColors.pulse.withOpacity(0.05),
                borderRadius: BorderRadius.circular(AppRadius.sm),
                border: Border.all(color: AppColors.pulse.withOpacity(0.1 + (_pulseController.value * 0.1))),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.warning_amber_rounded, color: AppColors.pulse.withOpacity(0.5 + (_pulseController.value * 0.3)), size: 14),
                  const SizedBox(width: 8),
                  Text('THIS IS YOUR FINAL MESSAGE', style: AppTypography.caption.copyWith(color: AppColors.pulse.withOpacity(0.5 + (_pulseController.value * 0.3)), letterSpacing: 2)),
                ],
              ),
            );
          },
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.frost.withOpacity(0.3),
                borderRadius: BorderRadius.circular(AppRadius.lg),
                border: Border.all(color: AppColors.frostBorder),
              ),
              child: TextField(
                controller: _controller,
                maxLines: null,
                expands: true,
                style: AppTypography.bodyLarge.copyWith(color: AppColors.textPrimary, height: 1.8),
                decoration: InputDecoration(
                  hintText: 'What do you want to leave behind?',
                  hintStyle: AppTypography.bodyLarge.copyWith(color: AppColors.textMuted, fontStyle: FontStyle.italic),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(AppSpacing.lg),
                ),
              ),
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(color: AppColors.voidDeep, border: Border(top: BorderSide(color: AppColors.frostBorder))),
          child: GestureDetector(
            onTap: canSeal ? _next : null,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.md + 4),
              decoration: BoxDecoration(
                color: canSeal ? AppColors.pulse.withOpacity(0.15) : AppColors.frost,
                borderRadius: BorderRadius.circular(AppRadius.full),
                border: Border.all(color: canSeal ? AppColors.pulse : AppColors.frostBorder, width: canSeal ? 2 : 1),
              ),
              child: Text(
                'SEAL & DELETE APP',
                textAlign: TextAlign.center,
                style: AppTypography.labelLarge.copyWith(color: canSeal ? AppColors.pulse : AppColors.textMuted, letterSpacing: 3),
              ),
            ),
          ),
        ),
        if (_showFinal) _buildFinalOverlay(),
      ],
    );
  }

  Widget _buildFinalOverlay() {
    return Positioned.fill(
      child: Container(
        color: AppColors.void_.withOpacity(0.95),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, child) {
                    return Container(
                      width: 100, height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.pulse, width: 3),
                        boxShadow: AppShadows.pulseGlow(_pulseController.value),
                      ),
                      child: const Icon(Icons.warning_rounded, color: AppColors.pulse, size: 48),
                    );
                  },
                ),
                const SizedBox(height: AppSpacing.xxl),
                Text('LAST CHANCE', style: AppTypography.displayMedium.copyWith(color: AppColors.pulse, letterSpacing: 6)),
                const SizedBox(height: AppSpacing.lg),
                Text('After this, the app self-destructs.\nYour message will exist forever.', textAlign: TextAlign.center, style: AppTypography.bodyLarge),
                const SizedBox(height: AppSpacing.xxl),
                GestureDetector(
                  onTap: _seal,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.md + 4),
                    decoration: BoxDecoration(
                      color: AppColors.pulse.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(AppRadius.full),
                      border: Border.all(color: AppColors.pulse, width: 2),
                    ),
                    child: Text('SEAL IT. GOODBYE.', textAlign: TextAlign.center, style: AppTypography.labelLarge.copyWith(color: AppColors.pulse, letterSpacing: 3)),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                GestureDetector(
                  onTap: () => setState(() => _showFinal = false),
                  child: Text('Go back', style: AppTypography.bodyMedium.copyWith(color: AppColors.textMuted)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGoodbye() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 120, height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.sacred, width: 3),
              boxShadow: AppShadows.glow(AppColors.sacred, intensity: 0.5),
            ),
            child: const Icon(Icons.check_rounded, color: AppColors.sacred, size: 56),
          ),
          const SizedBox(height: AppSpacing.xxl),
          Text('GOODBYE', style: AppTypography.displayLarge.copyWith(color: AppColors.sacred, letterSpacing: 12)),
          const SizedBox(height: AppSpacing.lg),
          Text('Your truth lives forever.', style: AppTypography.bodyLarge),
        ],
      ),
    );
  }
}
