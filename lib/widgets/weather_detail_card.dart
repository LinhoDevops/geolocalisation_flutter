import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:weather_app/utils/weather_translations.dart'; // Importez la nouvelle classe d'utilitaires

class WeatherDetailCard extends StatelessWidget {
  final String icon;
  final double temperature;
  final String description;
  final double humidity;
  final double windSpeed;
  // Ajouter le nom de la ville pour la personnalisation par région
  final String cityName;

  const WeatherDetailCard({
    Key? key,
    required this.icon,
    required this.temperature,
    required this.description,
    required this.humidity,
    required this.windSpeed,
    this.cityName = '',  // Valeur par défaut vide
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final primaryColor = Theme.of(context).colorScheme.primary;
    // Utiliser la couleur personnalisée de la région si disponible
    final regionColor = cityName.isNotEmpty
        ? getCustomIconColor(cityName, temperature)
        : primaryColor;

    // Déterminer des indices de confort basés sur les données
    final String tempFeel = _getTemperatureFeeling(temperature);
    final String humidityLevel = _getHumidityLevel(humidity);
    final String windLevel = _getWindLevel(windSpeed);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[800] : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            isDarkMode ? Color(0xFF2D3748).withOpacity(0.9) : Colors.white,
            isDarkMode ? Color(0xFF1A202C).withOpacity(0.9) : regionColor.withOpacity(0.05),
          ],
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.thermostat_outlined,
                          color: regionColor, // Utiliser la couleur de région
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Température',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${temperature.toStringAsFixed(1)}°C',
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      tempFeel,
                      style: TextStyle(
                        fontSize: 14,
                        color: _getTemperatureColor(temperature, context, regionColor),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Image.network(
                icon,
                width: 100,
                height: 100,
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.image_not_supported,
                  size: 100,
                ),
              )
                  .animate(onPlay: (controller) => controller.repeat())
                  .scale(
                begin: const Offset(1, 1),
                end: const Offset(1.05, 1.05),
                duration: const Duration(seconds: 2),
              )
                  .then()
                  .scale(
                begin: const Offset(1, 1),
                end: const Offset(0.95, 0.95),
                duration: const Duration(seconds: 2),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            decoration: BoxDecoration(
              color: isDarkMode
                  ? regionColor.withOpacity(0.1)
                  : regionColor.withOpacity(0.05),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.info_outline,
                  size: 18,
                  color: regionColor.withOpacity(0.8), // Utiliser la couleur de région
                ),
                const SizedBox(width: 8),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: isDarkMode ? Colors.white : Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildDetailColumn(
                context,
                Icons.water_drop,
                'Humidité',
                '${humidity.toStringAsFixed(0)}%',
                humidityLevel,
                _getHumidityColor(humidity, context, regionColor),
              ),
              _buildDetailColumn(
                context,
                Icons.air,
                'Vent',
                '${windSpeed.toStringAsFixed(1)} m/s',
                windLevel,
                _getWindColor(windSpeed, context, regionColor),
              ),
              _buildDetailColumn(
                context,
                Icons.wb_twilight,
                'Ressenti',
                '${(temperature - 1 + (humidity * 0.01)).toStringAsFixed(1)}°',
                'Apparent',
                regionColor,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailColumn(
      BuildContext context,
      IconData icon,
      String title,
      String value,
      String subtitle,
      Color iconColor,
      ) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(isDarkMode ? 0.2 : 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: iconColor,
            size: 28,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(context).textTheme.bodySmall?.color,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }

  // Helpers pour les indicateurs de confort météo - traductions en français
  String _getTemperatureFeeling(double temp) {
    if (temp < 0) return 'Très froid';
    if (temp < 10) return 'Froid';
    if (temp < 20) return 'Frais';
    if (temp < 25) return 'Agréable';
    if (temp < 30) return 'Chaud';
    return 'Très chaud';
  }

  String _getHumidityLevel(double humidity) {
    if (humidity < 30) return 'Très sec';
    if (humidity < 50) return 'Sec';
    if (humidity < 70) return 'Confortable';
    if (humidity < 85) return 'Humide';
    return 'Très humide';
  }

  String _getWindLevel(double windSpeed) {
    if (windSpeed < 2) return 'Calme';
    if (windSpeed < 6) return 'Brise légère';
    if (windSpeed < 12) return 'Modéré';
    if (windSpeed < 20) return 'Fort';
    return 'Très fort';
  }

  Color _getTemperatureColor(double temp, BuildContext context, Color regionColor) {
    // Si nous avons une région, tenir compte de sa couleur caractéristique
    if (cityName.isNotEmpty) {
      if (temp < 0) return Color.lerp(Colors.indigo, regionColor, 0.3) ?? Colors.indigo;
      if (temp < 10) return Color.lerp(Colors.blue, regionColor, 0.3) ?? Colors.blue;
      if (temp < 20) return regionColor;
      if (temp < 25) return Color.lerp(Colors.green, regionColor, 0.3) ?? Colors.green;
      if (temp < 30) return Color.lerp(Colors.orange, regionColor, 0.3) ?? Colors.orange;
      return Color.lerp(Colors.red, regionColor, 0.2) ?? Colors.red;
    } else {
      // Comportement par défaut
      if (temp < 0) return Colors.indigo;
      if (temp < 10) return Colors.blue;
      if (temp < 20) return Theme.of(context).colorScheme.primary;
      if (temp < 25) return Colors.green;
      if (temp < 30) return Colors.orange;
      return Colors.red;
    }
  }

  Color _getHumidityColor(double humidity, BuildContext context, Color regionColor) {
    // Incorporer légèrement la couleur de la région
    if (humidity < 30) return Color.lerp(Colors.orange, regionColor, 0.2) ?? Colors.orange;
    if (humidity < 50) return Color.lerp(Colors.green, regionColor, 0.2) ?? Colors.green;
    if (humidity < 70) return regionColor;
    if (humidity < 85) return Color.lerp(Colors.lightBlue, regionColor, 0.2) ?? Colors.lightBlue;
    return Color.lerp(Colors.blue, regionColor, 0.2) ?? Colors.blue;
  }

  Color _getWindColor(double windSpeed, BuildContext context, Color regionColor) {
    // Incorporer légèrement la couleur de la région
    if (windSpeed < 2) return Color.lerp(Colors.green, regionColor, 0.2) ?? Colors.green;
    if (windSpeed < 6) return regionColor;
    if (windSpeed < 12) return Color.lerp(Colors.orange, regionColor, 0.2) ?? Colors.orange;
    if (windSpeed < 20) return Color.lerp(Colors.deepOrange, regionColor, 0.2) ?? Colors.deepOrange;
    return Color.lerp(Colors.red, regionColor, 0.2) ?? Colors.red;
  }
}