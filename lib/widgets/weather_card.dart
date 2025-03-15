import 'package:flutter/material.dart';
import 'package:weather_app/models/weather_model.dart';
import 'package:flutter_animate/flutter_animate.dart';

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
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;
    final secondaryColor = Theme.of(context).colorScheme.secondary;

    // Météo conditions et couleurs correspondantes
    final String condition = widget.weather.description.toLowerCase();
    Color cardColor = Theme.of(context).cardTheme.color ?? Colors.white;

    // Personnaliser la couleur en fonction des conditions météo
    if (condition.contains('pluie') || condition.contains('rain')) {
      cardColor = isDarkMode
          ? const Color(0xFF1A3347)
          : const Color(0xFFE1F5FE);
    } else if (condition.contains('neige') || condition.contains('snow')) {
      cardColor = isDarkMode
          ? const Color(0xFF29323C)
          : const Color(0xFFE8EAF6);
    } else if (condition.contains('soleil') || condition.contains('sun') || condition.contains('clear')) {
      cardColor = isDarkMode
          ? const Color(0xFF2E3F50)
          : const Color(0xFFFFFDE7);
    } else if (condition.contains('nuage') || condition.contains('cloud')) {
      cardColor = isDarkMode
          ? const Color(0xFF27333E)
          : const Color(0xFFECEFF1);
    }

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
              color: cardColor,
              margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              elevation: _isHovered ? 8 : 4,
              shadowColor: _isHovered
                  ? Theme.of(context).colorScheme.primary.withOpacity(0.4)
                  : Colors.black26,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: _isHovered
                    ? BorderSide(color: primaryColor.withOpacity(0.5), width: 1.5)
                    : BorderSide.none,
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
                          'https://openweathermap.org/img/wn/${widget.weather.icon}@2x.png',
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
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.weather.description,
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.8),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(
                                  Icons.thermostat,
                                  color: isDarkMode ? Colors.lightBlue : Colors.blue,
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
                                  color: isDarkMode ? Colors.lightBlue : Colors.blue,
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
                              ? primaryColor
                              : Colors.transparent,
                          shape: BoxShape.circle,
                        ),
                        padding: EdgeInsets.all(_isHovered ? 8.0 : 0),
                        child: Icon(
                          Icons.arrow_forward_ios,
                          color: _isHovered
                              ? Colors.white
                              : Theme.of(context).colorScheme.secondary,
                          size: 18,
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
}