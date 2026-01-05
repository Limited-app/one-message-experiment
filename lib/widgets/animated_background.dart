import 'dart:math';
import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

class AnimatedBackground extends StatefulWidget {
  final Widget child;
  final bool showParticles;
  final bool showAura;
  final Color? auraColor;
  final double auraIntensity;

  const AnimatedBackground({
    super.key,
    required this.child,
    this.showParticles = false,
    this.showAura = false,
    this.auraColor,
    this.auraIntensity = 0.3,
  });

  @override
  State<AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<Particle> _particles = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
    
    if (widget.showParticles) {
      _generateParticles();
    }
  }

  void _generateParticles() {
    for (int i = 0; i < 30; i++) {
      _particles.add(Particle(
        x: _random.nextDouble(),
        y: _random.nextDouble(),
        size: 1 + _random.nextDouble() * 2,
        speed: 0.1 + _random.nextDouble() * 0.3,
        opacity: 0.1 + _random.nextDouble() * 0.3,
      ));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auraColor = widget.auraColor ?? AppColors.sacred;
    
    return Container(
      decoration: const BoxDecoration(
        gradient: AppColors.voidGradient,
      ),
      child: Stack(
        children: [
          // Particles
          if (widget.showParticles)
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return CustomPaint(
                  size: Size.infinite,
                  painter: ParticlePainter(
                    particles: _particles,
                    progress: _controller.value,
                  ),
                );
              },
            ),
          
          // Aura glow
          if (widget.showAura)
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                final pulse = 0.5 + (sin(_controller.value * 2 * pi) * 0.5);
                return Container(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: Alignment.center,
                      radius: 1.2,
                      colors: [
                        auraColor.withOpacity(widget.auraIntensity * pulse * 0.5),
                        auraColor.withOpacity(widget.auraIntensity * pulse * 0.2),
                        Colors.transparent,
                      ],
                      stops: const [0.0, 0.4, 1.0],
                    ),
                  ),
                );
              },
            ),
          
          // Vignette
          Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 1.2,
                colors: [
                  Colors.transparent,
                  AppColors.void_.withOpacity(0.8),
                ],
                stops: const [0.5, 1.0],
              ),
            ),
          ),
          
          // Child content
          widget.child,
        ],
      ),
    );
  }
}

class Particle {
  double x;
  double y;
  double size;
  double speed;
  double opacity;

  Particle({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.opacity,
  });
}

class ParticlePainter extends CustomPainter {
  final List<Particle> particles;
  final double progress;

  ParticlePainter({required this.particles, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    for (final particle in particles) {
      final y = (particle.y + progress * particle.speed) % 1.0;
      final paint = Paint()
        ..color = AppColors.textMuted.withOpacity(particle.opacity)
        ..style = PaintingStyle.fill;
      
      canvas.drawCircle(
        Offset(particle.x * size.width, y * size.height),
        particle.size,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant ParticlePainter oldDelegate) => true;
}
