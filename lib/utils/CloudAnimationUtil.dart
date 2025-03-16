import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:math' as math;

/// Classe utilitaire pour créer l'animation de nuages
/// Peut être utilisée à partir de n'importe quel écran
class CloudAnimationUtil {

  /// Crée une animation de nuages pour l'arrière-plan
  static Widget buildAnimatedCloudsBackground(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      alignment: Alignment.center,
      children: [
        // Fond avec gradient dynamique
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: isDarkMode
                  ? [
                Color(0xFF0D253F),
                Color(0xFF142E4C),
              ]
                  : [
                Color(0xFFE3F2FD),
                Color(0xFFBBDEFB),
              ],
            ),
          ),
        ),

        // Première couche de nuages
        Opacity(
          opacity: 0.7,
          child: _buildCloudShape(
            context: context,
            size: 100,
            opacity: isDarkMode ? 0.4 : 0.7,
            animationDuration: 15,
            topOffset: 0,
          ),
        ),

        // Deuxième couche de nuages
        Positioned(
          top: 30,
          left: 20,
          child: Opacity(
            opacity: 0.5,
            child: _buildCloudShape(
              context: context,
              size: 60,
              opacity: isDarkMode ? 0.3 : 0.6,
              animationDuration: 20,
              topOffset: 30,
            ),
          ),
        ),

        // Troisième couche de nuages (en direction opposée)
        Positioned(
          bottom: 20,
          right: 0,
          child: Opacity(
            opacity: 0.6,
            child: _buildCloudShape(
              context: context,
              size: 80,
              opacity: isDarkMode ? 0.35 : 0.65,
              animationDuration: 25,
              isReversed: true,
              topOffset: 60,
            ),
          ),
        ),
      ],
    );
  }

  /// Construit une forme de nuage plus complexe plutôt qu'une simple icône
  static Widget _buildCloudShape({
    required BuildContext context,
    required double size,
    required double opacity,
    required int animationDuration,
    bool isReversed = false,
    double topOffset = 0,
  }) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final cloudColor = isDarkMode ? Colors.grey[700]! : Colors.white;

    return Stack(
      alignment: Alignment.center,
      children: [
        // Base du nuage (forme principale)
        ClipPath(
          clipper: CloudClipper(),
          child: Container(
            width: size,
            height: size * 0.6,
            decoration: BoxDecoration(
              color: cloudColor.withOpacity(opacity),
              borderRadius: BorderRadius.circular(size * 0.2),
            ),
          ),
        ),
      ],
    )
        .animate(onPlay: (controller) => controller.repeat())
        .moveX(
      begin: isReversed ? MediaQuery.of(context).size.width + (size / 2) : -(size),
      end: isReversed ? -(size) : MediaQuery.of(context).size.width + (size / 2),
      duration: Duration(seconds: animationDuration),
      curve: Curves.linear,
    );
  }
}

// Clipper personnalisé pour créer une forme de nuage
class CloudClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    final random = math.Random(42); // Seed fixe pour cohérence

    // Point de départ en bas à gauche
    path.moveTo(size.width * 0.1, size.height * 0.8);

    // Générer des points aléatoires pour le haut du nuage
    for (int i = 1; i < 8; i++) {
      final xFactor = 0.1 + (i * 0.1);
      final yOffset = random.nextDouble() * 0.4;
      path.quadraticBezierTo(
        size.width * (xFactor - 0.05),
        size.height * (0.3 + yOffset),
        size.width * xFactor,
        size.height * (0.5 + yOffset * 0.5),
      );
    }

    // Fermer le chemin
    path.lineTo(size.width * 0.9, size.height * 0.8);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}