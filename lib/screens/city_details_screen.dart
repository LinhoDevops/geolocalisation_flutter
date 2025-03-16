import 'package:flutter/material.dart';
import 'package:weather_app/models/weather_model.dart';
import 'package:weather_app/widgets/map_view.dart';
import 'package:weather_app/widgets/weather_detail_card.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:weather_app/utils/weather_translations.dart'; // Importez la nouvelle classe d'utilitaires

class CityDetailsScreen extends StatelessWidget {
  final WeatherModel weather;
  final Function toggleTheme;

  const CityDetailsScreen({
    Key? key,
    required this.weather,
    required this.toggleTheme,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Traduire la description météo
    final translatedDescription = translateWeatherCondition(weather.description);

    // Obtenir une icône personnalisée basée sur la région et la température
    final customIconCode = getCustomIconForRegion(weather.cityName, weather.temperature);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(weather.cityName),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              Theme.of(context).brightness == Brightness.light
                  ? Icons.dark_mode
                  : Icons.light_mode,
            ),
            onPressed: () => toggleTheme(),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Background avec gradient approprié pour la météo
          _buildWeatherBackground(context),

          // Contenu
          SingleChildScrollView(
            child: SafeArea(
              child: Column(
                children: [
                  const SizedBox(height: 16),

                  // Héro image et température
                  _buildWeatherHero(context, translatedDescription, customIconCode)
                      .animate()
                      .fadeIn(duration: 800.ms)
                      .scale(
                    begin: const Offset(0.9, 0.9),
                    end: const Offset(1, 1),
                    duration: 800.ms,
                    curve: Curves.easeOutCubic,
                  ),

                  // Carte météo détaillée
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Détails météo',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        )
                            .animate()
                            .fadeIn(delay: 200.ms, duration: 400.ms)
                            .moveX(begin: -20, end: 0, delay: 200.ms, duration: 400.ms),

                        const SizedBox(height: 12),

                        WeatherDetailCard(
                          icon: 'https://openweathermap.org/img/wn/${customIconCode}@2x.png',
                          temperature: weather.temperature,
                          description: translatedDescription,
                          humidity: weather.humidity,
                          windSpeed: weather.windSpeed,
                        )
                            .animate()
                            .fadeIn(delay: 400.ms, duration: 400.ms)
                            .moveY(begin: 20, end: 0, delay: 400.ms, duration: 400.ms),

                        const SizedBox(height: 24),

                        // Prévisions section (permutation avec localisation)
                        Text(
                          'Prévisions à venir',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        )
                            .animate()
                            .fadeIn(delay: 600.ms, duration: 400.ms)
                            .moveX(begin: -20, end: 0, delay: 600.ms, duration: 400.ms),

                        const SizedBox(height: 12),

                        _buildMockForecast(context)
                            .animate()
                            .fadeIn(delay: 800.ms, duration: 400.ms)
                            .moveY(begin: 20, end: 0, delay: 800.ms, duration: 400.ms),

                        const SizedBox(height: 20),

                        // Localisation après prévisions
                        Text(
                          'Localisation',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        )
                            .animate()
                            .fadeIn(delay: 1000.ms, duration: 400.ms)
                            .moveX(begin: -20, end: 0, delay: 1000.ms, duration: 400.ms),

                        const SizedBox(height: 12),

                        _buildLocationInfo(context)
                            .animate()
                            .fadeIn(delay: 1200.ms, duration: 400.ms)
                            .moveY(begin: 20, end: 0, delay: 1200.ms, duration: 400.ms),
                      ],
                    ),
                  ),

                  // Conteneur de carte
                  Container(
                    margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    height: 300,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: MapView(
                      latitude: weather.latitude,
                      longitude: weather.longitude,
                      cityName: weather.cityName,
                    ),
                  )
                      .animate()
                      .fadeIn(delay: 1400.ms, duration: 500.ms)
                      .scale(
                    begin: const Offset(0.95, 0.95),
                    end: const Offset(1, 1),
                    delay: 1400.ms,
                    duration: 500.ms,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Fond d'écran basé sur les conditions météo
  Widget _buildWeatherBackground(BuildContext context) {
    final condition = weather.description.toLowerCase();
    List<Color> gradientColors = [];

    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    if (condition.contains('pluie') || condition.contains('rain') || condition.contains('averses')) {
      gradientColors = isDarkMode
          ? [const Color(0xFF1A3347), const Color(0xFF0D253F)]
          : [const Color(0xFF4B6CB7), const Color(0xFF182848)];
    } else if (condition.contains('neige') || condition.contains('snow')) {
      gradientColors = isDarkMode
          ? [const Color(0xFF29323C), const Color(0xFF1C1C1C)]
          : [const Color(0xFFE8EAF6), const Color(0xFFC5CAE9)];
    } else if (condition.contains('soleil') || condition.contains('sun') || condition.contains('clear') || condition.contains('dégagé')) {
      gradientColors = isDarkMode
          ? [const Color(0xFF2E3F50), const Color(0xFF203A43)]
          : [const Color(0xFF56CCF2), const Color(0xFF2F80ED)];
    } else if (condition.contains('nuage') || condition.contains('cloud') || condition.contains('couvert')) {
      gradientColors = isDarkMode
          ? [const Color(0xFF27333E), const Color(0xFF17212B)]
          : [const Color(0xFF8E9EAB), const Color(0xFFEEF2F3)];
    } else {
      // Défaut
      gradientColors = isDarkMode
          ? [Theme.of(context).colorScheme.background, Theme.of(context).colorScheme.surface]
          : [Theme.of(context).colorScheme.primary.withOpacity(0.2), Theme.of(context).colorScheme.background];
    }

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: gradientColors,
        ),
      ),
    );
  }

  // Affichage héros de la température
  Widget _buildWeatherHero(BuildContext context, String translatedDescription, String customIconCode) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withOpacity(0.8),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                weather.cityName,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                translatedDescription,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).textTheme.titleMedium?.color?.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Icon(Icons.calendar_today, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    'Aujourd\'hui',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Hero(
                tag: 'weather-icon-${weather.cityName}',
                child: Image.network(
                  'https://openweathermap.org/img/wn/${customIconCode}@2x.png',
                  width: 80,
                  height: 80,
                  errorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.image_not_supported,
                    size: 80,
                  ),
                ),
              ),
              Text(
                '${weather.temperature.toStringAsFixed(0)}°',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Informations de localisation
  Widget _buildLocationInfo(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            spreadRadius: 1,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.location_on,
                color: Theme.of(context).colorScheme.primary,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Coordonnées',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Latitude: ${weather.latitude.toStringAsFixed(4)}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    Text(
                      'Longitude: ${weather.longitude.toStringAsFixed(4)}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Prévisions simulées (pour démonstration)
  Widget _buildMockForecast(BuildContext context) {
    // Données factices pour les prévisions avec traduction
    final List<Map<String, dynamic>> forecastData = [
      {'day': 'Demain', 'temp': weather.temperature - 2 + (5 * 0.1), 'icon': _getForecastIcon(weather.cityName, weather.temperature - 2 + (5 * 0.1))},
      {'day': 'Mer', 'temp': weather.temperature - 1 + (3 * 0.1), 'icon': _getForecastIcon(weather.cityName, weather.temperature - 1 + (3 * 0.1))},
      {'day': 'Jeu', 'temp': weather.temperature + 1 + (2 * 0.1), 'icon': _getForecastIcon(weather.cityName, weather.temperature + 1 + (2 * 0.1))},
      {'day': 'Ven', 'temp': weather.temperature + 2 + (1 * 0.1), 'icon': _getForecastIcon(weather.cityName, weather.temperature + 2 + (1 * 0.1))},
      {'day': 'Sam', 'temp': weather.temperature + 1, 'icon': _getForecastIcon(weather.cityName, weather.temperature + 1)},
    ];

    // Icônes correspondantes
    Map<String, IconData> weatherIcons = {
      'sunny': Icons.wb_sunny,
      'partly_cloudy': Icons.wb_cloudy,
      'cloudy': Icons.cloud,
      'rain': Icons.water_drop,
      'thunderstorm': Icons.thunderstorm,
      'snow': Icons.ac_unit,
    };

    return Container(
      height: 130,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: forecastData.length,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
        itemBuilder: (context, index) {
          final forecast = forecastData[index];
          return Container(
            width: 80,
            margin: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              border: Border.all(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                width: 1,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  forecast['day'],
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Icon(
                  weatherIcons[forecast['icon']] ?? Icons.question_mark,
                  color: _getIconColor(forecast['icon'], forecast['temp'], context),
                  size: 26,
                ),
                const SizedBox(height: 6),
                Text(
                  '${forecast['temp'].toStringAsFixed(1)}°',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // Obtenir l'icône de prévision en fonction de la région et de la température
  String _getForecastIcon(String cityName, double temperature) {
    // Logique d'attribution d'icônes adaptée à chaque région
    if (cityName.toLowerCase().contains('saint-louis')) {
      if (temperature < 25) return 'partly_cloudy';
      return 'sunny';
    }
    else if (cityName.toLowerCase().contains('dakar')) {
      if (temperature < 27) return 'partly_cloudy';
      if (temperature < 30) return 'sunny';
      return 'rain';
    }
    else if (cityName.toLowerCase().contains('matam') || cityName.toLowerCase().contains('tambacounda')) {
      if (temperature < 30) return 'sunny';
      if (temperature < 35) return 'partly_cloudy';
      return 'thunderstorm';
    }
    else if (cityName.toLowerCase().contains('ziguinchor') || cityName.toLowerCase().contains('kolda')) {
      if (temperature < 28) return 'partly_cloudy';
      if (temperature < 33) return 'cloudy';
      return 'rain';
    }

    // Par défaut basé sur la température
    if (temperature < 25) return 'partly_cloudy';
    if (temperature < 30) return 'sunny';
    if (temperature < 35) return 'cloudy';
    return 'thunderstorm';
  }

  Color _getIconColor(String weatherType, double temperature, BuildContext context) {
    // Couleurs personnalisées en fonction du type de temps et de la température
    switch (weatherType) {
      case 'sunny':
        return temperature > 32 ? Colors.deepOrange : Colors.orange;
      case 'partly_cloudy':
        return temperature > 30 ? Colors.amber : Colors.amber.shade300;
      case 'cloudy':
        return Colors.grey;
      case 'rain':
        return temperature > 28 ? Colors.indigo : Colors.blue;
      case 'thunderstorm':
        return Colors.purple;
      case 'snow':
        return Colors.lightBlue;
      default:
        return getCustomIconColor(weather.cityName, temperature);
    }
  }
}