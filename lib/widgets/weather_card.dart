import 'package:flutter/material.dart';
import 'package:weather_app/models/weather_model.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:weather_app/utils/weather_translations.dart'; // Importez la nouvelle classe d'utilitaires

class WeatherCard extends StatefulWidget {
  final WeatherModel weather;
  final VoidCallback onTap;

  const WeatherCard({
    Key? key,
    required this.weather,
    required this.onTap,
  }) : super(key: key);

  @override
  State<WeatherCard> createState() => _WeatherCardState();
}

class _WeatherCardState extends State<WeatherCard> with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.03).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Traduire la description météo
    final translatedDescription = translateWeatherCondition(widget.weather.description);

    // Obtenir une icône personnalisée basée sur la région
    final customIconCode = getCustomIconForRegion(widget.weather.cityName, widget.weather.temperature);

    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;
    final secondaryColor = Theme.of(context).colorScheme.secondary;

    // Météo conditions et couleurs correspondantes
    final String condition = translatedDescription.toLowerCase();
    Color gradientStartColor;
    Color gradientEndColor;

    // Personnaliser la couleur en fonction des conditions météo
    if (condition.contains('pluie') || condition.contains('averse')) {
      gradientStartColor = isDarkMode
          ? const Color(0xFF256997).withOpacity(0.8)
          : const Color(0xFF0C0C0C).withOpacity(0.8);
      gradientEndColor = isDarkMode
          ? const Color(0xFF95D1F6).withOpacity(0.8)
          : const Color(0xFF7FC0E8).withOpacity(0.8);
    } else if (condition.contains('neige')) {
      gradientStartColor = isDarkMode
          ? const Color(0xFFC0CDED).withOpacity(0.8)
          : const Color(0xFF3D86B6).withOpacity(0.8);
      gradientEndColor = isDarkMode
          ? const Color(0xFF79ACF1).withOpacity(0.8)
          : const Color(0xFF66BAF4).withOpacity(0.8);
    } else if (condition.contains('soleil') || condition.contains('dégagé') || condition.contains('clair')) {
      gradientStartColor = isDarkMode
          ? const Color(0xFF45525E).withOpacity(0.8)
          : const Color(0xFF3D86B6).withOpacity(0.8);
      gradientEndColor = isDarkMode
          ? const Color(0xFF97D0DA).withOpacity(0.8)
          : const Color(0xFF374857).withOpacity(0.8);
    } else if (condition.contains('nuage') || condition.contains('couvert')) {
      gradientStartColor = isDarkMode
          ? const Color(0xFF27333E).withOpacity(0.8)
          : const Color(0xFFAFD3DC).withOpacity(0.8);
      gradientEndColor = isDarkMode
          ? const Color(0xFF1B252E).withOpacity(0.8)
          : const Color(0xFF476670).withOpacity(0.8);
    } else {
      gradientStartColor = isDarkMode
          ? Colors.grey[800]!.withOpacity(0.8)
          : Colors.white.withOpacity(0.8);
      gradientEndColor = isDarkMode
          ? Colors.grey[900]!.withOpacity(0.8)
          : Colors.grey[100]!.withOpacity(0.8);
    }

    // Personnaliser les couleurs en fonction de la région
    Color regionColor = getCustomIconColor(widget.weather.cityName, widget.weather.temperature);

    // Ajuster légèrement les couleurs de gradient pour refléter la région
    gradientStartColor = Color.lerp(gradientStartColor, regionColor, 0.3) ?? gradientStartColor;
    gradientEndColor = Color.lerp(gradientEndColor, regionColor.withOpacity(0.7), 0.2) ?? gradientEndColor;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: MouseRegion(
            onEnter: (_) {
              setState(() {
                _isHovered = true;
                _controller.forward();
              });
            },
            onExit: (_) {
              setState(() {
                _isHovered = false;
                _controller.reverse();
              });
            },
            child: Card(
              margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              elevation: _isHovered ? 8 : 4,
              shadowColor: _isHovered
                  ? regionColor.withOpacity(0.4)  // Utiliser la couleur de région pour l'ombre
                  : Colors.black26,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: _isHovered
                    ? BorderSide(color: regionColor.withOpacity(0.5), width: 1.5)  // Utiliser la couleur de région pour la bordure
                    : BorderSide.none,
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      gradientStartColor,
                      gradientEndColor,
                    ],
                  ),
                ),
                child: InkWell(
                  onTap: widget.onTap,
                  borderRadius: BorderRadius.circular(16),
                  splashColor: secondaryColor.withOpacity(0.1),
                  highlightColor: secondaryColor.withOpacity(0.05),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Hero(
                          tag: 'weather-icon-${widget.weather.cityName}',
                          child: Image.network(
                            'https://openweathermap.org/img/wn/${customIconCode}@2x.png',  // Utiliser l'icône personnalisée
                            width: 70,
                            height: 70,
                            errorBuilder: (context, error, stackTrace) => const Icon(
                              Icons.image_not_supported,
                              size: 70,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.weather.cityName,
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: isDarkMode ? Colors.white : Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                translatedDescription,  // Utiliser la description traduite
                                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  color: (isDarkMode ? Colors.white : Colors.black87).withOpacity(0.8),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(
                                    Icons.thermostat,
                                    color: regionColor,  // Utiliser la couleur de région pour l'icône
                                    size: 20,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${widget.weather.temperature.toStringAsFixed(1)}°C',
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Icon(
                                    Icons.water_drop,
                                    color: regionColor,  // Utiliser la couleur de région pour l'icône
                                    size: 20,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${widget.weather.humidity.toStringAsFixed(0)}%',
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          decoration: BoxDecoration(
                            color: _isHovered
                                ? regionColor  // Utiliser la couleur de région pour le bouton
                                : Colors.transparent,
                            shape: BoxShape.circle,
                          ),
                          padding: EdgeInsets.all(_isHovered ? 8.0 : 0),
                          child: Icon(
                            Icons.arrow_forward_ios,
                            color: _isHovered
                                ? Colors.white
                                : regionColor.withOpacity(0.7),  // Utiliser la couleur de région pour l'icône
                            size: 18,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    ).animate().fadeIn(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOut,
    ).moveY(
      begin: 20,
      end: 0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutQuad,
    );
  }
}