import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Classe utilitaire pour créer l'animation de nuages
/// Peut être utilisée à partir de n'importe quel écran
class CloudAnimationUtil {

  /// Crée une animation de nuages pour l'arrière-plan
  static Widget buildAnimatedCloudsBackground(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Opacity(
          opacity: 0.7,
          child: Icon(
            Icons.cloud,
            size: 100,
            color: Theme.of(context).brightness == Brightness.light
                ? Colors.grey[300]
                : Colors.grey[700],
          )
              .animate(onPlay: (controller) => controller.repeat())
              .moveX(
            begin: -50,
            end: MediaQuery.of(context).size.width + 50,
            duration: const Duration(seconds: 15),
            curve: Curves.linear,
          ),
        ),
        Positioned(
          top: 30,
          left: 20,
          child: Opacity(
            opacity: 0.5,
            child: Icon(
              Icons.cloud,
              size: 60,
              color: Theme.of(context).brightness == Brightness.light
                  ? Colors.grey[300]
                  : Colors.grey[700],
            )
                .animate(onPlay: (controller) => controller.repeat())
                .moveX(
              begin: -30,
              end: MediaQuery.of(context).size.width + 30,
              duration: const Duration(seconds: 20),
              curve: Curves.linear,
            ),
          ),
        ),
        Positioned(
          bottom: 20,
          right: 0,
          child: Opacity(
            opacity: 0.6,
            child: Icon(
              Icons.cloud,
              size: 80,
              color: Theme.of(context).brightness == Brightness.light
                  ? Colors.grey[300]
                  : Colors.grey[700],
            )
                .animate(onPlay: (controller) => controller.repeat())
                .moveX(
              begin: MediaQuery.of(context).size.width + 40,
              end: -80,
              duration: const Duration(seconds: 25),
              curve: Curves.linear,
            ),
          ),
        ),
      ],
    );
  }
}