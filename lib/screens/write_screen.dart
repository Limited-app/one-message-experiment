import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../services/storage_service.dart';
import '../services/haptic_service.dart';
import '../services/firebase_service.dart';
import '../widgets/animated_background.dart';

class WriteScreen extends StatefulWidget {
  const WriteScreen({super.key});

  @override
  State<WriteScreen> createState() => _WriteScreenState();
}

class _WriteScreenState extends State<WriteScreen>
    with TickerProviderStateMixin {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  late AnimationController _fadeController;
  late AnimationController _pulseController;
  late AnimationController _warningController;
  
  String _category = '';
  int _charCount = 0;
  bool _showFinalWarning = false;
  static const int _minChars = 10;
  static const int _maxChars = 1000;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: AppAnimations.slow,
    )..forward();
    
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    
    _warningController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    
    _controller.addListener(() {
      setState(() => _charCount = _controller.text.length);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is String) {
      _category = args;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _fadeController.dispose();
    _pulseController.dispose();
    _warningController.dispose();
    super.dispose();
  }

  void _attemptSeal() {
    if (_charCount < _minChars) {
      HapticService.instance.heavyImpact();
      return;
    }
    
    HapticService.instance.mediumImpact();
    
    if (!_showFinalWarning) {
      setState(() => _showFinalWarning = true);
      _warningController.forward();
      return;
    }
    
    _sealTruth();
  }

  Future<void> _sealTruth() async {
    HapticService.instance.heavyImpact();
    
    final storage = await StorageService.getInstance();
    await storage.saveMessage(_category, _controller.text);
    await storage.setSubmitted(_category, true);
    await storage.setMessageTimestamp(_category, DateTime.now());
    await storage.incrementTotalMessagesLocked();
    
    await FirebaseService.instance.sealTruth(
      category: _category,
      message: _controller.text,
    );
    
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/sealed');
    }
  }

  void _cancelFinalWarning() {
    HapticService.instance.lightImpact();
    _warningController.reverse();
    setState(() => _showFinalWarning = false);
  }

  Future<bool> _onWillPop() async {
    if (_charCount > 0) {
      final shouldLeave = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          backgroundColor: AppColors.voidSurface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            side: const BorderSide(color: AppColors.pulse, width: 1),
          ),
          title: Text(
            'Are you sure?',
            style: AppTypography.headlineSmall.copyWith(color: AppColors.pulse),
          ),
          content: Text(
            'Most people close this screen once before they\'re ready.\n\nIf you leave now, your words will be lost.',
            style: AppTypography.bodyMedium,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(
                'STAY',
                style: AppTypography.labelLarge.copyWith(color: AppColors.sacred),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(
                'LEAVE',
                style: AppTypography.labelMedium.copyWith(color: AppColors.textMuted),
              ),
            ),
          ],
        ),
      );
      return shouldLeave ?? false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final color = AppColors.categoryColors[_category] ?? AppColors.sacred;
    final tagline = AppCategories.taglines[_category] ?? '';

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: AppColors.void_,
        body: AnimatedBackground(
          showParticles: true,
          showAura: true,
          auraColor: color,
          auraIntensity: 0.2,
          child: SafeArea(
            child: FadeTransition(
              opacity: _fadeController,
              child: Stack(
                children: [
                  Column(
                    children: [
                      _buildHeader(color),
                      _buildWarningBar(),
                      Expanded(child: _buildTextInput(color, tagline)),
                      _buildBottomBar(color),
                    ],
                  ),
                  if (_showFinalWarning) _buildFinalWarning(color),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(Color color) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.frost,
                border: Border.all(color: AppColors.frostBorder),
              ),
              child: const Icon(Icons.close, color: AppColors.textSecondary, size: 20),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _category.toUpperCase(),
                  style: AppTypography.labelLarge.copyWith(color: color, letterSpacing: 4),
                ),
                const Text('Your one and only chance', style: AppTypography.caption),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _charCount >= _minChars ? color.withOpacity(0.1) : AppColors.frost,
              borderRadius: BorderRadius.circular(AppRadius.full),
              border: Border.all(
                color: _charCount >= _minChars ? color.withOpacity(0.3) : AppColors.frostBorder,
              ),
            ),
            child: Text(
              '$_charCount',
              style: AppTypography.labelMedium.copyWith(
                color: _charCount >= _minChars ? color : AppColors.textMuted,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWarningBar() {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: AppColors.pulse.withOpacity(0.05),
            borderRadius: BorderRadius.circular(AppRadius.sm),
            border: Border.all(
              color: AppColors.pulse.withOpacity(0.1 + (_pulseController.value * 0.1)),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: AppColors.pulse.withOpacity(0.5 + (_pulseController.value * 0.3)),
                size: 14,
              ),
              const SizedBox(width: 8),
              Text(
                AppStrings.warningForever,
                style: AppTypography.caption.copyWith(
                  color: AppColors.pulse.withOpacity(0.5 + (_pulseController.value * 0.3)),
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTextInput(Color color, String tagline) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.frost.withOpacity(0.3),
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: _focusNode.hasFocus ? color.withOpacity(0.5) : AppColors.frostBorder,
          ),
        ),
        constraints: const BoxConstraints(maxHeight: 200),
        child: TextField(
          controller: _controller,
          focusNode: _focusNode,
          maxLines: 6,
          minLines: 3,
          maxLength: _maxChars,
          style: AppTypography.bodyLarge.copyWith(color: AppColors.textPrimary, height: 1.6),
          decoration: InputDecoration(
            hintText: tagline,
            hintStyle: AppTypography.bodyLarge.copyWith(
              color: AppColors.textMuted,
              fontStyle: FontStyle.italic,
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.all(AppSpacing.lg),
            counterText: '',
          ),
        ),
      ),
    );
  }

  Widget _buildBottomBar(Color color) {
    final canSeal = _charCount >= _minChars;
    
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.voidDeep,
        border: const Border(top: BorderSide(color: AppColors.frostBorder)),
      ),
      child: Column(
        children: [
          if (_charCount > 0 && _charCount < _minChars)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: Text(
                '${_minChars - _charCount} more characters needed',
                style: AppTypography.caption.copyWith(color: AppColors.textMuted),
              ),
            ),
          GestureDetector(
            onTap: canSeal ? _attemptSeal : null,
            child: AnimatedContainer(
              duration: AppAnimations.fast,
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.md + 4),
              decoration: BoxDecoration(
                color: canSeal ? color.withOpacity(0.15) : AppColors.frost,
                borderRadius: BorderRadius.circular(AppRadius.full),
                border: Border.all(
                  color: canSeal ? color : AppColors.frostBorder,
                  width: canSeal ? 2 : 1,
                ),
                boxShadow: canSeal ? AppShadows.glow(color, intensity: 0.3) : null,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.lock, color: canSeal ? color : AppColors.textMuted, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'SEAL FOREVER',
                    style: AppTypography.labelLarge.copyWith(
                      color: canSeal ? color : AppColors.textMuted,
                      letterSpacing: 4,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFinalWarning(Color color) {
    return AnimatedBuilder(
      animation: _warningController,
      builder: (context, child) {
        return Opacity(
          opacity: _warningController.value,
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
                          width: 100,
                          height: 100,
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
                    Text(
                      'FINAL WARNING',
                      style: AppTypography.displayMedium.copyWith(color: AppColors.pulse, letterSpacing: 6),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      'Once you seal this truth, it cannot be edited, deleted, or undone.\n\nThis is permanent.',
                      textAlign: TextAlign.center,
                      style: AppTypography.bodyLarge.copyWith(color: AppColors.textSecondary, height: 1.6),
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                    GestureDetector(
                      onTap: _sealTruth,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md + 4),
                        decoration: BoxDecoration(
                          color: AppColors.pulse.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(AppRadius.full),
                          border: Border.all(color: AppColors.pulse, width: 2),
                        ),
                        child: Text(
                          'I UNDERSTAND. SEAL IT.',
                          textAlign: TextAlign.center,
                          style: AppTypography.labelLarge.copyWith(color: AppColors.pulse, letterSpacing: 3),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    TextButton(
                      onPressed: _cancelFinalWarning,
                      child: Text(
                        'Go back and edit',
                        style: AppTypography.bodyMedium.copyWith(color: AppColors.textMuted),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
