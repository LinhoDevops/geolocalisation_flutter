import 'dart:async';
import 'package:flutter/material.dart';
import 'package:weather_app/models/weather_model.dart';
import 'package:weather_app/screens/results_screen.dart';
import 'package:weather_app/services/weather_service.dart';
import 'package:weather_app/utils/CloudAnimationUtil.dart';
import 'package:weather_app/widgets/progress_bar.dart';
import 'package:flutter_animate/flutter_animate.dart';

class LoadingScreen extends StatefulWidget {
  final Function toggleTheme;

  const LoadingScreen({Key? key, required this.toggleTheme}) : super(key: key);

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> with SingleTickerProviderStateMixin {
  final WeatherService _weatherService = WeatherService();
  final List<String> _cities = ['Paris', 'New York', 'Tokyo', 'London', 'Sydney'];
  final List<String> _loadingMessages = [
    'Nous téléchargeons les données...',
    'C\'est presque fini...',
    'Plus que quelques secondes avant d\'avoir le résultat...',
    'Analyse des conditions météorologiques...',
    'Préparation de votre expérience météo...',
  ];

  List<WeatherModel> _weatherData = [];
  double _progress = 0.0;
  String _currentMessage = 'Nous téléchargeons les données...';
  int _messageIndex = 0;
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';
  String _currentCity = '';
  late AnimationController _pulseController;
  bool _isDarkMode = false;

  @override
  void initState() {
    super.initState();
    _isDarkMode = false; // Définir en fonction du thème actuel
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _startLoading();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _startLoading() {
    // Simulation de progression plus réaliste avec accélération
    int tickCount = 0;
    Timer.periodic(const Duration(milliseconds: 100), (progressTimer) {
      tickCount++;
      if (_progress >= 1.0) {
        progressTimer.cancel();
        if (_weatherData.isNotEmpty) {
          setState(() {
            _isLoading = false;
          });
          _navigateToResults();
        }
      } else {
        double increment;
        // Acceleration douce, puis ralentissement vers la fin
        if (_progress < 0.7) {
          increment = 0.005 + (tickCount * 0.0001);
        } else {
          increment = 0.005 - ((_progress - 0.7) * 0.015);
        }

        setState(() {
          _progress += increment;
        });
      }
    });

    // Rotation des messages avec animation
    Timer.periodic(const Duration(seconds: 3), (messageTimer) {
      if (_progress >= 1.0) {
        messageTimer.cancel();
      } else {
        setState(() {
          _messageIndex = (_messageIndex + 1) % _loadingMessages.length;
          _currentMessage = _loadingMessages[_messageIndex];
        });
      }
    });

    // Simulation du chargement des données pour chaque ville
    _loadCitiesSequentially();
  }

  Future<void> _loadCitiesSequentially() async {
    List<WeatherModel> weatherData = [];

    for (int i = 0; i < _cities.length; i++) {
      if (_hasError) break;

      setState(() {
        _currentCity = _cities[i];
      });

      try {
        // Simuler un délai de chargement pour chaque ville
        await Future.delayed(const Duration(milliseconds: 800));

        final weather = await _weatherService.getWeatherByCity(_cities[i]);
        weatherData.add(weather);

        // Montrer un feedback pour chaque ville chargée
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Données pour ${_cities[i]} chargées avec succès'),
              duration: const Duration(seconds: 1),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              margin: EdgeInsets.only(
                bottom: MediaQuery.of(context).size.height - 150,
                left: 10,
                right: 10,
              ),
            ),
          );
        }
      } catch (e) {
        _handleError('Erreur lors du chargement de ${_cities[i]}: $e');
        return;
      }
    }

    if (weatherData.isNotEmpty) {
      setState(() {
        _weatherData = weatherData;
        _hasError = false;
        _errorMessage = '';
      });
    }
  }

  void _handleError(String message) {
    setState(() {
      _hasError = true;
      _errorMessage = message;
      _isLoading = false;
    });
  }

  void _retry() {
    setState(() {
      _progress = 0.0;
      _isLoading = true;
      _hasError = false;
      _errorMessage = '';
      _messageIndex = 0;
      _currentMessage = _loadingMessages[0];
      _currentCity = '';
    });
    _startLoading();
  }

  void _navigateToResults() {
    Future.delayed(const Duration(milliseconds: 500), () {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => ResultsScreen(
            weatherData: _weatherData,
            toggleTheme: widget.toggleTheme,
          ),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(1.0, 0.0);
            const end = Offset.zero;
            const curve = Curves.easeInOutCubic;

            var tween = Tween(begin: begin, end: end).chain(
              CurveTween(curve: curve),
            );

            return SlideTransition(
              position: animation.drive(tween),
              child: FadeTransition(
                opacity: animation,
                child: child,
              ),
            );
          },
          transitionDuration: const Duration(milliseconds: 800),
        ),
      );
    });
  }

  Widget _buildCityLoadingItem(String city, bool isLoading) {
    bool isCurrent = city == _currentCity;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: isCurrent
                  ? Theme.of(context).colorScheme.primary
                  : isLoading
                  ? Colors.grey.withOpacity(0.3)
                  : Colors.green,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: isCurrent
                  ? AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  return Transform.scale(
                    scale: 0.5 + (_pulseController.value * 0.5),
                    child: const Icon(
                      Icons.downloading,
                      color: Colors.white,
                      size: 16,
                    ),
                  );
                },
              )
                  : isLoading
                  ? const SizedBox.shrink()
                  : const Icon(
                Icons.check,
                color: Colors.white,
                size: 16,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            city,
            style: TextStyle(
              fontSize: 16,
              fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
              color: isCurrent
                  ? Theme.of(context).colorScheme.primary
                  : null,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chargement en cours'),
        actions: [
          IconButton(
            icon: Icon(
              Theme.of(context).brightness == Brightness.light
                  ? Icons.dark_mode
                  : Icons.light_mode,
            ),
            onPressed: () => widget.toggleTheme(),
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
        child: Stack(
          children: [
            // Animation de nuages en arrière-plan
            Positioned.fill(
              child: CloudAnimationUtil.buildAnimatedCloudsBackground(context),
            ),

            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_isLoading) ...[
                    Text(
                      _currentMessage,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    )
                        .animate(onPlay: (controller) => controller.repeat())
                        .fadeIn(duration: 600.ms)
                        .then(delay: 2400.ms)
                        .fadeOut(duration: 600.ms),

                    const SizedBox(height: 40),

                    ProgressBar(progress: _progress),

                    const SizedBox(height: 40),

                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Text(
                            'Chargement des données météo',
                            style: Theme.of(context).textTheme.titleMedium,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ..._cities.map((city) => _buildCityLoadingItem(
                            city,
                            !_weatherData.any((w) => w.cityName == city) && city != _currentCity,
                          )),
                        ],
                      ),
                    )
                        .animate()
                        .fadeIn(duration: 600.ms, delay: 300.ms)
                        .slideY(begin: 0.2, end: 0, duration: 600.ms, delay: 300.ms),
                  ] else if (_hasError) ...[
                    const Icon(
                      Icons.error_outline,
                      size: 80,
                      color: Colors.red,
                    )
                        .animate()
                        .scale(
                      begin: const Offset(0.5, 0.5),
                      end: const Offset(1, 1),
                      duration: 400.ms,
                      curve: Curves.elasticOut,
                    ),

                    const SizedBox(height: 20),

                    Text(
                      'Une erreur est survenue',
                      style: Theme.of(context).textTheme.headlineSmall,
                      textAlign: TextAlign.center,
                    )
                        .animate()
                        .fadeIn(duration: 400.ms, delay: 200.ms)
                        .slideY(begin: 0.2, end: 0, duration: 400.ms, delay: 200.ms),

                    const SizedBox(height: 10),

                    Text(
                      _errorMessage,
                      textAlign: TextAlign.center,
                    )
                        .animate()
                        .fadeIn(duration: 400.ms, delay: 400.ms),

                    const SizedBox(height: 30),

                    ElevatedButton.icon(
                      onPressed: _retry,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Réessayer'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    )
                        .animate()
                        .fadeIn(duration: 400.ms, delay: 600.ms)
                        .scale(
                      begin: const Offset(0.9, 0.9),
                      end: const Offset(1, 1),
                      duration: 400.ms,
                      delay: 600.ms,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}