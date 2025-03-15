import 'package:flutter/material.dart';
import 'package:weather_app/screens/loading_screen.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:math' as math;

class SplashScreen extends StatefulWidget {
  final Function toggleTheme;

  const SplashScreen({Key? key, required this.toggleTheme}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _cloudController;
  late AnimationController _reflectionController;
  late AnimationController _fogController;
  late AnimationController _mountainController;
  late AnimationController _buttonPulseController;

  double _textOpacity = 0.0;
  bool _showMountainGlow = false;

  @override
  void initState() {
    super.initState();

    // Controllers pour diverses animations
    _cloudController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 60),
    )..repeat(reverse: false);

    _reflectionController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    _fogController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    )..repeat(reverse: true);

    _mountainController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat(reverse: true);

    _buttonPulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    // Animation séquentielle pour les différents éléments
    _startSequentialAnimation();
  }

  void _startSequentialAnimation() {
    // Fade in du texte
    Future.delayed(const Duration(milliseconds: 800), () {
      setState(() {
        _textOpacity = 1.0;
      });
    });

    // Effet de lueur sur les montagnes
    Future.delayed(const Duration(milliseconds: 2500), () {
      setState(() {
        _showMountainGlow = true;
      });
    });
  }

  @override
  void dispose() {
    _cloudController.dispose();
    _reflectionController.dispose();
    _fogController.dispose();
    _mountainController.dispose();
    _buttonPulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Déterminer si le thème actuel est sombre
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
          // Image de fond avec animation subtile
          AnimatedBuilder(
            animation: _mountainController,
            builder: (context, child) {
              return Transform.scale(
                scale: 1.0 + (_mountainController.value * 0.03), // Légère animation de zoom
                child: ColorFiltered(
                  // Assombrir davantage l'image de nuit si nécessaire
                  colorFilter: isDarkMode
                      ? const ColorFilter.mode(
                      Colors.black38,
                      BlendMode.darken
                  )
                      : const ColorFilter.mode(
                      Colors.transparent,
                      BlendMode.srcOver
                  ),
                  child: Image.asset(
                    isDarkMode ? 'assets/images/night.png' : 'assets/images/day.png',
                    fit: BoxFit.cover,
                    filterQuality: FilterQuality.high,
                  ),
                ),
              );
            },
          ),

          // Effet de lueur sur les montagnes (activé avec délai)
          if (_showMountainGlow)
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _mountainController,
                builder: (context, child) {
                  return Container(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        center: Alignment(0.0, -0.2),
                        radius: 0.8,
                        colors: [
                          isDarkMode
                              ? Colors.indigo.withOpacity(0.05 + (_mountainController.value * 0.08))
                              : Colors.orangeAccent.withOpacity(0.05 + (_mountainController.value * 0.05)),
                          Colors.transparent,
                        ],
                        stops: const [0.0, 1.0],
                      ),
                    ),
                  );
                },
              ),
            ),

          // Brume animée
          AnimatedBuilder(
            animation: _fogController,
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
                        Colors.white.withOpacity(0.1 + (_fogController.value * 0.05)),
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
                          0.5 + (math.sin(_fogController.value * math.pi) * 0.5),
                          1.0,
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),

          // Nuages animés
          Positioned(
            top: 70,
            left: -100 + (_cloudController.value * (MediaQuery.of(context).size.width + 200)),
            child: Opacity(
              opacity: 0.8,
              child: Icon(
                Icons.cloud,
                size: 80,
                color: isDarkMode ? Colors.white.withOpacity(0.7) : Colors.black54,
              ),
            ),
          ),

          Positioned(
            top: 120,
            right: -80 + (_cloudController.value * 0.7 * (MediaQuery.of(context).size.width + 160)),
            child: Opacity(
              opacity: 0.7,
              child: Icon(
                Icons.cloud,
                size: 100,
                color: isDarkMode ? Colors.white.withOpacity(0.6) : Colors.black45,
              ),
            ),
          ),

          Positioned(
            top: 50,
            left: MediaQuery.of(context).size.width * 0.3 - (_cloudController.value * 0.4 * MediaQuery.of(context).size.width),
            child: Opacity(
              opacity: 0.6,
              child: Icon(
                Icons.cloud,
                size: 60,
                color: isDarkMode ? Colors.white.withOpacity(0.5) : Colors.black38,
              ),
            ),
          ),

          // Effet de reflet sur l'eau - animation subtile
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height * 0.3,
            child: AnimatedBuilder(
              animation: _reflectionController,
              builder: (context, child) {
                return ShaderMask(
                  shaderCallback: (rect) {
                    return LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.white.withOpacity(0.1 + (_reflectionController.value * 0.05)),
                        Colors.white.withOpacity(0.05),
                      ],
                      stops: [0.0, 0.2 + (_reflectionController.value * 0.1), 1.0],
                    ).createShader(rect);
                  },
                  blendMode: BlendMode.modulate,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment(
                          -1.0 + (math.sin(_reflectionController.value * math.pi) * 0.1),
                          0,
                        ),
                        end: Alignment(
                          1.0 + (math.sin(_reflectionController.value * math.pi) * 0.1),
                          0,
                        ),
                        colors: [
                          Colors.white.withOpacity(0.1),
                          Colors.white.withOpacity(0.2),
                          Colors.white.withOpacity(0.1),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Overlay très léger pour assurer la lisibilité - beaucoup plus subtil maintenant
          Container(
            color: isDarkMode
                ? Colors.black.withOpacity(0.1)
                : Colors.black.withOpacity(0.05),
          ),

          // Contenu directement sur l'image sans cadre
          AnimatedOpacity(
            opacity: _textOpacity,
            duration: const Duration(seconds: 1),
            curve: Curves.easeInOut,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              width: double.infinity,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildAnimatedLogo(isDarkMode),

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
                    'Découvrez les conditions météorologiques en temps réel pour vos villes préférées.',
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

                  _buildButton(
                    text: 'Commencer l\'exploration',
                    icon: Icons.explore,
                    controller: _buttonPulseController,
                    isDarkMode: isDarkMode,
                    onPressed: () => _navigateWithAnimation(context),
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

  // Logo animé avec effets météo
  Widget _buildAnimatedLogo(bool isDarkMode) {
    return SizedBox(
      height: 110,
      width: 110,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Cercle lumineux derrière
          AnimatedBuilder(
            animation: _buttonPulseController,
            builder: (context, child) {
              return Container(
                width: 100 + (_buttonPulseController.value * 15),
                height: 100 + (_buttonPulseController.value * 15),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      isDarkMode
                          ? Colors.blueAccent.withOpacity(0.7 - (_buttonPulseController.value * 0.3))
                          : Colors.black.withOpacity(0.4 - (_buttonPulseController.value * 0.1)),
                      Colors.transparent,
                    ],
                    stops: const [0.2, 1.0],
                  ),
                ),
              );
            },
          ),

          // Icône nuage animée
          Icon(
            Icons.cloud,
            size: 70,
            color: isDarkMode ? Colors.lightBlue[100] : Colors.black87,
          )
              .animate(onPlay: (controller) => controller.repeat(reverse: true))
              .scale(
            begin: const Offset(1.0, 1.0),
            end: const Offset(1.15, 1.15),
            duration: const Duration(seconds: 2),
            curve: Curves.easeInOut,
          ),

          // Petits nuages animés autour
          Positioned(
            top: 15,
            right: 5,
            child: Icon(
              Icons.cloud,
              size: 20,
              color: isDarkMode ? Colors.lightBlue[100]!.withOpacity(0.7) : Colors.black54,
            )
                .animate(onPlay: (controller) => controller.repeat(reverse: true))
                .moveY(
              begin: 0,
              end: -5,
              duration: const Duration(seconds: 3),
              curve: Curves.easeInOut,
            )
                .fadeIn(duration: const Duration(seconds: 1))
                .fadeOut(delay: const Duration(seconds: 3), duration: const Duration(seconds: 1)),
          ),

          Positioned(
            bottom: 15,
            left: 10,
            child: Icon(
              Icons.cloud,
              size: 15,
              color: isDarkMode ? Colors.lightBlue[100]!.withOpacity(0.7) : Colors.black54,
            )
                .animate(onPlay: (controller) => controller.repeat(reverse: true))
                .moveX(
              begin: 0,
              end: 5,
              duration: const Duration(seconds: 2, milliseconds: 500),
              curve: Curves.easeInOut,
            )
                .fadeIn(duration: const Duration(seconds: 1))
                .fadeOut(delay: const Duration(seconds: 2), duration: const Duration(seconds: 1)),
          ),

          // Effet de goutte de pluie
          Positioned(
            bottom: 10,
            right: 25,
            child: Icon(
              Icons.water_drop,
              size: 10,
              color: isDarkMode ? Colors.lightBlue[100] : Colors.black87,
            )
                .animate(onPlay: (controller) => controller.repeat())
                .moveY(
              begin: -15,
              end: 15,
              duration: const Duration(seconds: 1, milliseconds: 500),
              curve: Curves.easeIn,
            )
                .fadeIn(duration: const Duration(milliseconds: 300))
                .fadeOut(delay: const Duration(seconds: 1), duration: const Duration(milliseconds: 300)),
          ),
        ],
      ),
    );
  }

  // Bouton adapté au thème
  Widget _buildButton({
    required String text,
    required IconData icon,
    required VoidCallback onPressed,
    required AnimationController controller,
    required bool isDarkMode,
  }) {
    final buttonColor = isDarkMode
        ? const Color(0xFF1E3C64).withOpacity(0.7) // Bleu foncé pour le thème sombre
        : Colors.black.withOpacity(0.5);          // Noir semi-transparent pour le thème clair

    final borderColor = isDarkMode
        ? Colors.lightBlue.withOpacity(0.6)
        : Colors.black.withOpacity(0.4);

    final textColor = isDarkMode
        ? Colors.lightBlue[100]
        : Colors.white;

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
                  color: buttonColor,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: borderColor.withOpacity(0.5 + (0.3 * controller.value)),
                    width: 2,
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

  // Animation de transition vers l'écran suivant
  void _navigateWithAnimation(BuildContext context) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            LoadingScreen(toggleTheme: widget.toggleTheme),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          var curve = Curves.easeInOutCubic;
          var curveTween = CurveTween(curve: curve);

          // Animation de fondu
          var fadeTween = Tween<double>(begin: 0.0, end: 1.0);
          var fadeAnimation = fadeTween.animate(
            animation.drive(curveTween),
          );

          // Animation de zoom
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