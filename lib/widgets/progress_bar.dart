import 'package:flutter/material.dart';

class ProgressBar extends StatelessWidget {
  final double progress;

  const ProgressBar({Key? key, required this.progress}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 25,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.6),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Base de la barre
          Container(
            width: double.infinity,
            height: 25,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
            ),
          ),

          // Partie remplie de la barre
          AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOutCubic,
            width: MediaQuery.of(context).size.width * progress,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.secondary,
                  Theme.of(context).colorScheme.tertiary,
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
          ),

          // Petites bulles d'animation sur la barre
          AnimatedPositioned(
            duration: const Duration(milliseconds: 800),
            left: (MediaQuery.of(context).size.width * progress) - 30,
            child: Opacity(
              opacity: progress < 0.1 ? 0.0 : 1.0,
              child: Container(
                width: 12,
                height: 12,
                margin: const EdgeInsets.only(top: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.4),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),

          // Texte de pourcentage
          Center(
            child: Text(
              '${(progress * 100).toInt()}%',
              style: TextStyle(
                color: progress > 0.5
                    ? Colors.white
                    : Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.bold,
                fontSize: 14,
                letterSpacing: 0.5,
                shadows: progress > 0.5
                    ? [
                  const Shadow(
                    offset: Offset(0, 1),
                    blurRadius: 2,
                    color: Colors.black26,
                  )
                ]
                    : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}