import 'dart:math';

import 'package:flutter/material.dart';

class ParticleOverlay extends StatefulWidget {

  final bool isDarkMode;

  const ParticleOverlay({Key? key, required this.isDarkMode}) : super(key: key);

  @override
  State<ParticleOverlay> createState() => _ParticleOverlayState();
}

class _ParticleOverlayState extends State<ParticleOverlay> with TickerProviderStateMixin {
  late AnimationController _controller;
  List<Particle> particles = [];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    // Créer des particules aléatoires
    for (int i = 0; i < 50; i++) {
      particles.add(Particle.random());
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: ParticlePainter(
            particles: particles,
            animation: _controller,
            isDarkMode: widget.isDarkMode,
          ),
          child: Container(),
        );
      },
    );
  }
}

class Particle {
  double x;
  double y;
  double size;
  double speed;

  Particle({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
  });

  factory Particle.random() {
    return Particle(
      x: Random().nextDouble(),
      y: Random().nextDouble(),
      size: 1 + Random().nextDouble() * 3,
      speed: 0.001 + Random().nextDouble() * 0.003,
    );
  }
}

class ParticlePainter extends CustomPainter {
  final List<Particle> particles;
  final Animation<double> animation;
  final bool isDarkMode;

  ParticlePainter({
    required this.particles,
    required this.animation,
    required this.isDarkMode,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = isDarkMode
          ? Colors.white.withOpacity(0.5)
          : Colors.white.withOpacity(0.8);

    for (var particle in particles) {
      // Calculer la position actuelle de la particule
      double yPos = (particle.y + (animation.value * particle.speed)) % 1.0;

      canvas.drawCircle(
        Offset(particle.x * size.width, yPos * size.height),
        particle.size,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}