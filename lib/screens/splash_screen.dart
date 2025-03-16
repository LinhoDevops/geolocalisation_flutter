import 'package:flutter/material.dart';
import 'package:weather_app/screens/loading_screen.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:math' as math;
import 'dart:async';

class SplashScreen extends StatefulWidget {
  final Function toggleTheme;

  const SplashScreen({Key? key, required this.toggleTheme}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController cloudController;
  late AnimationController reflectionController;
  late AnimationController fogController;
  late AnimationController mountainController;
  late AnimationController buttonPulseController;
  late AnimationController particleController;

  double textOpacity = 0.0;
  bool showEffects = false;

  final List<Particle> particles = [];

  @override
  void initState() {
    super.initState();

    cloudController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 60),
    )..repeat(reverse: false);

    reflectionController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    fogController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    )..repeat(reverse: true);

    mountainController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat(reverse: true);

    buttonPulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    generateParticles();

    startSequentialAnimation();
  }

  void generateParticles() {
    for (int i = 0; i < 80; i++) {
      particles.add(Particle.random());
    }
  }

  void startSequentialAnimation() {
    Future.delayed(const Duration(milliseconds: 300), () {
      setState(() {
        showEffects = true;
      });
    });

    Future.delayed(const Duration(milliseconds: 800), () {
      setState(() {
        textOpacity = 1.0;
      });
    });
  }

  @override
  void dispose() {
    cloudController.dispose();
    reflectionController.dispose();
    fogController.dispose();
    mountainController.dispose();
    buttonPulseController.dispose();
    particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Weather Explorer',
          style: TextStyle(
            color: isDarkMode ? Colors.white : Colors.black87,
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(
                offset: const Offset(1, 1),
                blurRadius: 3,
                color: isDarkMode
                    ? Colors.black.withOpacity(0.5)
                    : Colors.white.withOpacity(0.7),
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              isDarkMode ? Icons.light_mode : Icons.dark_mode,
              color: isDarkMode ? Colors.amber : Colors.black87,
            )
                .animate(onPlay: (controller) => controller.repeat(reverse: true))
                .rotate(
              begin: -0.05,
              end: 0.05,
              duration: const Duration(seconds: 2),
              curve: Curves.easeInOut,
            )
                .scale(
              begin: const Offset(1.0, 1.0),
              end: const Offset(1.1, 1.1),
              duration: const Duration(seconds: 2),
              curve: Curves.easeInOut,
            ),
            onPressed: () => widget.toggleTheme(),
          ),
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          AnimatedBuilder(
            animation: mountainController,
            builder: (context, child) {
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isDarkMode
                        ? [
                      Color(0xFF0D253F),
                      Color(0xFF142E4C),
                      Color(0xFF1D3A5C),
                    ]
                        : [
                      Color(0xFF48AAE4),
                      Color(0xFF4298D8),
                      Color(0xFF2E77C3),
                    ],
                    stops: [
                      0.0,
                      0.5 + (mountainController.value * 0.1),
                      1.0
                    ],
                  ),
                ),
              );
            },
          ),

          if (showEffects)
            Positioned.fill(
              child: AnimatedBuilder(
                animation: mountainController,
                builder: (context, child) {
                  return Container(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        center: Alignment(0.0, -0.2),
                        radius: 0.8,
                        colors: [
                          isDarkMode
                              ? Colors.indigo.withOpacity(0.1 + (mountainController.value * 0.08))
                              : Colors.white.withOpacity(0.1 + (mountainController.value * 0.05)),
                          Colors.transparent,
                        ],
                        stops: const [0.0, 1.0],
                      ),
                    ),
                  );
                },
              ),
            ),

          if (showEffects)
            AnimatedBuilder(
              animation: particleController,
              builder: (context, child) {
                return CustomPaint(
                  painter: ParticlePainter(
                    particles: particles,
                    animation: particleController,
                    isDarkMode: isDarkMode,
                  ),
                  child: Container(),
                );
              },
            ),

          AnimatedBuilder(
            animation: fogController,
            builder: (context, child) {
              return Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                height: MediaQuery.of(context).size.height * 0.4,
                child: ShaderMask(
                  shaderCallback: (rect) {
                    return LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.white.withOpacity(0.1 + (fogController.value * 0.05)),
                        Colors.white.withOpacity(0.1),
                        Colors.transparent,
                      ],
                      stops: [0.0, 0.3, 0.7, 1.0],
                    ).createShader(rect);
                  },
                  blendMode: BlendMode.srcOver,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          Colors.white.withOpacity(0.3),
                          Colors.white.withOpacity(0.1),
                          Colors.white.withOpacity(0.3),
                        ],
                        stops: [
                          0.0,
                          0.5 + (math.sin(fogController.value * math.pi) * 0.5),
                          1.0,
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),

          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: AnimatedBuilder(
              animation: reflectionController,
              builder: (context, child) {
                return CustomPaint(
                  painter: WavePainter(
                    animation: reflectionController,
                    isDarkMode: isDarkMode,
                  ),
                  child: Container(height: 120),
                );
              },
            ),
          ),

          Container(
            color: isDarkMode
                ? Colors.black.withOpacity(0.1)
                : Colors.black.withOpacity(0.05),
          ),

          AnimatedOpacity(
            opacity: textOpacity,
            duration: const Duration(seconds: 1),
            curve: Curves.easeInOut,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              width: double.infinity,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  buildAnimatedLogo(isDarkMode),

                  const SizedBox(height: 25),

                  Text(
                    'Bienvenue dans Weather Explorer!',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white : Colors.black87,
                      shadows: [
                        Shadow(
                          blurRadius: isDarkMode ? 10 : 3,
                          color: isDarkMode
                              ? Colors.black.withOpacity(0.5)
                              : Colors.white.withOpacity(0.8),
                          offset: const Offset(2, 2),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  )
                      .animate()
                      .fadeIn(duration: const Duration(milliseconds: 800))
                      .slideY(begin: 0.2, end: 0, duration: const Duration(milliseconds: 800)),

                  const SizedBox(height: 20),

                  Text(
                    'Découvrez les conditions météorologiques en temps réel pour les régions du Sénégal.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      color: isDarkMode ? Colors.white : Colors.black87,
                      height: 1.4,
                      shadows: [
                        Shadow(
                          blurRadius: isDarkMode ? 4 : 2,
                          color: isDarkMode
                              ? Colors.black.withOpacity(0.5)
                              : Colors.white.withOpacity(0.8),
                          offset: const Offset(1, 1),
                        ),
                      ],
                    ),
                  )
                      .animate()
                      .fadeIn(delay: const Duration(milliseconds: 400), duration: const Duration(milliseconds: 800))
                      .slideY(begin: 0.2, end: 0, delay: const Duration(milliseconds: 400), duration: const Duration(milliseconds: 600)),

                  const SizedBox(height: 50),

                  buildButton(
                    text: 'Commencer l\'exploration',
                    icon: Icons.explore,
                    controller: buttonPulseController,
                    isDarkMode: isDarkMode,
                    onPressed: () => navigateWithAnimation(context),
                  )
                      .animate()
                      .fadeIn(delay: const Duration(milliseconds: 800), duration: const Duration(milliseconds: 600))
                      .slideY(begin: 0.2, end: 0, delay: const Duration(milliseconds: 800), duration: const Duration(milliseconds: 600))
                      .then(delay: const Duration(milliseconds: 200))
                      .shimmer(duration: const Duration(milliseconds: 1200), color: Colors.white.withOpacity(0.3)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildAnimatedLogo(bool isDarkMode) {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: isDarkMode
              ? [Color(0xFF1A3A6B), Color(0xFF0D253F)]
              : [Color(0xFF64B5F6), Color(0xFF1976D2)],
          center: Alignment(0.1, -0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: isDarkMode
                ? Colors.blue.withOpacity(0.2)
                : Colors.blue.withOpacity(0.4),
            blurRadius: 15,
            spreadRadius: 1,
          )
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedBuilder(
            animation: buttonPulseController,
            builder: (context, child) {
              return Container(
                width: 80 + (buttonPulseController.value * 15),
                height: 80 + (buttonPulseController.value * 15),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      isDarkMode
                          ? Colors.blueAccent.withOpacity(0.7 - (buttonPulseController.value * 0.3))
                          : Colors.white.withOpacity(0.8 - (buttonPulseController.value * 0.3)),
                      Colors.transparent,
                    ],
                    stops: const [0.2, 1.0],
                  ),
                ),
              );
            },
          ),

          Icon(
            Icons.wb_sunny,
            size: 36,
            color: isDarkMode ? Colors.amber : Colors.orange,
          )
              .animate(onPlay: (controller) => controller.repeat(reverse: true))
              .rotate(
            begin: 0,
            end: 0.1,
            duration: const Duration(seconds: 3),
          )
              .moveY(
            begin: 0,
            end: -5,
            duration: const Duration(seconds: 3),
          ),

          Positioned(
            bottom: 28,
            right: 25,
            child: Icon(
              Icons.cloud,
              size: 30,
              color: isDarkMode ? Colors.grey[300] : Colors.white,
            )
                .animate(onPlay: (controller) => controller.repeat(reverse: true))
                .moveX(
              begin: 0,
              end: 5,
              duration: const Duration(seconds: 4),
            )
                .scale(
              begin: const Offset(1, 1),
              end: const Offset(1.1, 1.1),
              duration: const Duration(seconds: 4),
            ),
          ),

          Positioned(
            bottom: 40,
            left: 25,
            child: Icon(
              Icons.water_drop,
              size: 18,
              color: isDarkMode ? Colors.lightBlue[100] : Colors.lightBlue[300],
            )
                .animate(onPlay: (controller) => controller.repeat())
                .moveY(
              begin: -10,
              end: 10,
              duration: const Duration(seconds: 1, milliseconds: 300),
              curve: Curves.easeIn,
            )
                .fadeIn(duration: const Duration(milliseconds: 300))
                .fadeOut(delay: const Duration(seconds: 1), duration: const Duration(milliseconds: 300)),
          ),
        ],
      ),
    ).animate()
        .scale(
      begin: const Offset(0.5, 0.5),
      end: const Offset(1, 1),
      duration: const Duration(milliseconds: 800),
      curve: Curves.elasticOut,
    );
  }

  Widget buildButton({
    required String text,
    required IconData icon,
    required VoidCallback onPressed,
    required AnimationController controller,
    required bool isDarkMode,
  }) {
    final buttonColor = isDarkMode
        ? const Color(0xFF1E3C64).withOpacity(0.8)
        : Colors.blueAccent.withOpacity(0.8);

    final borderColor = isDarkMode
        ? Colors.lightBlue.withOpacity(0.6)
        : Colors.white.withOpacity(0.6);

    final textColor = Colors.white;

    final shadowColor = isDarkMode
        ? Colors.blue.withOpacity(0.4)
        : Colors.black.withOpacity(0.3);

    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: shadowColor,
                blurRadius: 10,
                spreadRadius: 1 + (controller.value * 2),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onPressed,
              borderRadius: BorderRadius.circular(30),
              splashColor: Colors.white.withOpacity(0.1),
              highlightColor: Colors.white.withOpacity(0.2),
              child: Ink(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isDarkMode
                        ? [Color(0xFF1A237E), Color(0xFF0D47A1)]
                        : [Color(0xFF42A5F5), Color(0xFF1976D2)],
                  ),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: borderColor.withOpacity(0.5 + (0.3 * controller.value)),
                    width: 1.5,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 16),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        icon,
                        color: textColor,
                        size: 26 + (controller.value * 2),
                      ),
                      const SizedBox(width: 15),
                      Text(
                        text,
                        style: TextStyle(
                          color: textColor,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5 + (controller.value * 0.3),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void navigateWithAnimation(BuildContext context) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            LoadingScreen(toggleTheme: widget.toggleTheme),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          var curve = Curves.easeInOutCubic;
          var curveTween = CurveTween(curve: curve);
          var fadeTween = Tween<double>(begin: 0.0, end: 1.0);
          var fadeAnimation = fadeTween.animate(
            animation.drive(curveTween),
          );
          var scaleTween = Tween<double>(begin: 1.1, end: 1.0);
          var scaleAnimation = scaleTween.animate(
            animation.drive(curveTween),
          );

          return FadeTransition(
            opacity: fadeAnimation,
            child: ScaleTransition(
              scale: scaleAnimation,
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 800),
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

  factory Particle.random() {
    return Particle(
      x: math.Random().nextDouble(),
      y: math.Random().nextDouble(),
      size: 1 + math.Random().nextDouble() * 3,
      speed: 0.001 + math.Random().nextDouble() * 0.003,
      opacity: 0.3 + math.Random().nextDouble() * 0.7,
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
    for (var particle in particles) {
      double yPos = (particle.y + (animation.value * particle.speed)) % 1.0;

      final paint = Paint()
        ..color = isDarkMode
            ? Colors.white.withOpacity(particle.opacity * 0.7)
            : Colors.white.withOpacity(particle.opacity);

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

class WavePainter extends CustomPainter {
  final Animation<double> animation;
  final bool isDarkMode;

  WavePainter({
    required this.animation,
    required this.isDarkMode,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = isDarkMode
          ? Color(0xFF142850).withOpacity(0.4)
          : Colors.white.withOpacity(0.3)
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, size.height);
    double amplitude = size.height * 0.1;
    double wavePhase = animation.value * math.pi * 2;

    for (int i = 0; i <= size.width.toInt(); i++) {
      double dx = i.toDouble();
      double dy = size.height -
          amplitude * math.sin((dx / size.width * 4 * math.pi) + wavePhase) -
          (size.height * 0.2);
      path.lineTo(dx, dy);
    }

    path.lineTo(size.width, size.height);
    path.close();

    canvas.drawPath(path, paint);

    final paint2 = Paint()
      ..color = isDarkMode
          ? Color(0xFF0D253F).withOpacity(0.6)
          : Colors.white.withOpacity(0.2)
      ..style = PaintingStyle.fill;

    final path2 = Path();
    path2.moveTo(0, size.height);

    amplitude = size.height * 0.08;
    wavePhase = -animation.value * math.pi * 2;

    for (int i = 0; i <= size.width.toInt(); i++) {
      double dx = i.toDouble();
      double dy = size.height -
          amplitude * math.sin((dx / size.width * 3 * math.pi) + wavePhase) -
          (size.height * 0.1);
      path2.lineTo(dx, dy);
    }

    path2.lineTo(size.width, size.height);
    path2.close();

    canvas.drawPath(path2, paint2);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}