import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

class PremiumButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;
  final IconData? icon;
  final bool isLoading;
  final bool isSecondary;
  final bool isDestructive;

  const PremiumButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.isSecondary = false,
    this.isDestructive = false,
  });

  @override
  State<PremiumButton> createState() => _PremiumButtonState();
}

class _PremiumButtonState extends State<PremiumButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _glowController;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.isDestructive
        ? AppColors.pulse
        : widget.isSecondary
            ? AppColors.textSecondary
            : AppColors.sacred;

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.isLoading ? null : widget.onPressed,
      child: AnimatedBuilder(
        animation: _glowController,
        builder: (context, child) {
          final glowIntensity = widget.isSecondary ? 0.0 : 0.2 + (_glowController.value * 0.15);
          
          return AnimatedContainer(
            duration: AppAnimations.fast,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xl,
              vertical: AppSpacing.md + 4,
            ),
            transform: _isPressed 
                ? (Matrix4.identity()..scale(0.98))
                : Matrix4.identity(),
            decoration: BoxDecoration(
              color: widget.isSecondary 
                  ? Colors.transparent 
                  : color.withOpacity(_isPressed ? 0.25 : 0.15),
              borderRadius: BorderRadius.circular(AppRadius.full),
              border: Border.all(
                color: color.withOpacity(widget.isSecondary ? 0.3 : 0.8),
                width: widget.isSecondary ? 1 : 2,
              ),
              boxShadow: widget.isSecondary ? null : [
                BoxShadow(
                  color: color.withOpacity(glowIntensity),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (widget.isLoading)
                  SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: color,
                    ),
                  )
                else ...[
                  if (widget.icon != null) ...[
                    Icon(widget.icon, color: color, size: 18),
                    const SizedBox(width: AppSpacing.sm),
                  ],
                  Text(
                    widget.text,
                    style: AppTypography.labelLarge.copyWith(
                      color: color,
                      letterSpacing: 3,
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

class GhostButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final IconData? icon;

  const GhostButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, color: AppColors.textMuted, size: 16),
              const SizedBox(width: AppSpacing.xs),
            ],
            Text(
              text,
              style: AppTypography.labelMedium.copyWith(
                color: AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class IconOnlyButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final double size;
  final Color? color;

  const IconOnlyButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.size = 44,
    this.color,
  });

  @override
  State<IconOnlyButton> createState() => _IconOnlyButtonState();
}

class _IconOnlyButtonState extends State<IconOnlyButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onPressed,
      child: AnimatedContainer(
        duration: AppAnimations.fast,
        width: widget.size,
        height: widget.size,
        transform: _isPressed 
            ? (Matrix4.identity()..scale(0.95))
            : Matrix4.identity(),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.frost,
          border: Border.all(
            color: _isPressed 
                ? (widget.color ?? AppColors.sacred).withOpacity(0.5)
                : AppColors.frostBorder,
          ),
        ),
        child: Icon(
          widget.icon,
          color: widget.color ?? AppColors.textSecondary,
          size: widget.size * 0.45,
        ),
      ),
    );
  }
}
