import 'package:flutter/material.dart';
import 'package:weather_app/models/weather_model.dart';
import 'package:weather_app/screens/city_details_screen.dart';
import 'package:weather_app/screens/loading_screen.dart';
import 'package:weather_app/widgets/weather_card.dart';
import 'package:flutter_animate/flutter_animate.dart';

class ResultsScreen extends StatelessWidget {
  final List<WeatherModel> weatherData;
  final Function toggleTheme;

  const ResultsScreen({
    Key? key,
    required this.weatherData,
    required this.toggleTheme,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Résultats météo'),
        elevation: 4,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
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
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.background,
              Theme.of(context).colorScheme.primary.withOpacity(0.1),
            ],
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 8.0),
              child: Column(
                children: [
                  Text(
                    'Météo actuelle',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Découvrez les conditions météorologiques pour ${weatherData.length} villes du Sénégal',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.7),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              )
                  .animate()
                  .fadeIn(duration: 500.ms)
                  .moveY(begin: -10, end: 0, duration: 500.ms, curve: Curves.easeOutQuad),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(8.0),
                itemCount: weatherData.length,
                itemBuilder: (context, index) {
                  final weather = weatherData[index];
                  return WeatherCard(
                    weather: weather,
                    onTap: () {
                      _navigateToCityDetails(context, weather);
                    },
                  )
                      .animate()
                      .fadeIn(
                    duration: 400.ms,
                    delay: Duration(milliseconds: 100 * index),
                  )
                      .slideX(
                    begin: 0.2,
                    end: 0,
                    duration: 400.ms,
                    delay: Duration(milliseconds: 100 * index),
                    curve: Curves.easeOutQuad,
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton.icon(
                onPressed: () => _restartLoading(context),
                icon: const Icon(Icons.refresh),
                label: const Text('Recommencer'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 4,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              )
                  .animate()
                  .fadeIn(delay: 800.ms, duration: 400.ms)
                  .scale(
                begin: const Offset(0.95, 0.95),
                end: const Offset(1, 1),
                delay: 800.ms,
                duration: 400.ms,
              ),
            ),
          ],
        ),
        
      ),

      // Ajout d'un FAB pour une action rapide
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Afficher un dialog avec un résumé ou une comparaison
          _showWeatherSummaryDialog(context);
        },
        child: const Icon(Icons.insights),
        tooltip: 'Résumé météo',
      )
          .animate()
          .scale(
        begin: const Offset(0, 0),
        end: const Offset(1, 1),
        delay: 1000.ms,
        duration: 400.ms,
        curve: Curves.elasticOut,
      ),
    );
  }

  void _navigateToCityDetails(BuildContext context, WeatherModel weather) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => CityDetailsScreen(
          weather: weather,
          toggleTheme: toggleTheme,
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          var curve = Curves.easeInOut;
          var curveTween = CurveTween(curve: curve);

          var fadeTween = Tween<double>(begin: 0.0, end: 1.0);
          var fadeAnimation = fadeTween.animate(
            animation.drive(curveTween),
          );

          var scaleTween = Tween<double>(begin: 0.9, end: 1.0);
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
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  void _restartLoading(BuildContext context) {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => LoadingScreen(
          toggleTheme: toggleTheme,
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  void _showWeatherSummaryDialog(BuildContext context) {
    // Trouver la ville la plus chaude et la plus froide
    WeatherModel warmestCity = weatherData.reduce(
          (a, b) => a.temperature > b.temperature ? a : b,
    );

    WeatherModel coldestCity = weatherData.reduce(
          (a, b) => a.temperature < b.temperature ? a : b,
    );

    // Calculer la température moyenne
    double avgTemp = weatherData.map((w) => w.temperature).reduce((a, b) => a + b)
        / weatherData.length;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Résumé météo',
          style: TextStyle(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildSummaryItem(
              context,
              Icons.whatshot,
              'Ville la plus chaude:',
              '${warmestCity.cityName} (${warmestCity.temperature.toStringAsFixed(1)}°C)',
              Colors.orange,
            ),
            const SizedBox(height: 12),
            _buildSummaryItem(
              context,
              Icons.ac_unit,
              'Ville la plus froide:',
              '${coldestCity.cityName} (${coldestCity.temperature.toStringAsFixed(1)}°C)',
              Colors.blue,
            ),
            const SizedBox(height: 12),
            _buildSummaryItem(
              context,
              Icons.device_thermostat,
              'Température moyenne:',
              '${avgTemp.toStringAsFixed(1)}°C',
              Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            Text(
              'Cliquez sur une ville pour plus de détails',
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).textTheme.bodySmall?.color,
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fermer'),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              textStyle: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 8,
      ),
    );
  }

  Widget _buildSummaryItem(
      BuildContext context,
      IconData icon,
      String label,
      String value,
      Color iconColor,
      ) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: iconColor,
            size: 24,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}