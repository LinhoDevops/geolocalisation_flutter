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

// Route de transition personnalisée
class FadeScaleRoute extends PageRouteBuilder {
  final Widget page;

  FadeScaleRoute({required this.page})
      : super(
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      var curve = Curves.easeOutCubic;
      var curveTween = CurveTween(curve: curve);

      var fadeTween = Tween<double>(begin: 0.0, end: 1.0);
      var fadeAnimation = fadeTween.animate(
        animation.drive(curveTween),
      );

      var scaleTween = Tween<double>(begin: 0.92, end: 1.0);
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
    transitionDuration: const Duration(milliseconds: 700),
  );
}

class _LoadingScreenState extends State<LoadingScreen> with SingleTickerProviderStateMixin {
  final WeatherService _weatherService = WeatherService();

  // Liste modifiée pour utiliser les régions du Sénégal
  final List<String> _cities = ['Dakar', 'Saint-Louis', 'Thies', 'Diourbel', 'Ziguinchor'];

  final List<String> _loadingMessages = [
    'Nous téléchargeons les données...',
    'C\'est presque fini...',
    'Plus que quelques secondes avant d\'avoir le résultat...',
    // 'Analyse des conditions météorologiques...',
    // 'Préparation de votre expérience météo...',
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

  // Pour suivre l'état de chargement de chaque ville
  Map<String, int> _cityLoadingStatus = {}; // 0: pas commencé, 1: en cours, 2: terminé

  // Délai de validation pour les villes
  final Duration _validationDelay = const Duration(milliseconds: 1500);

  @override
  void initState() {
    super.initState();
    _isDarkMode = false; // Définir en fonction du thème actuel
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    // Initialiser le statut de chargement de toutes les villes
    for (var city in _cities) {
      _cityLoadingStatus[city] = 0;
    }

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
        // Calculer le progrès en fonction du nombre de villes chargées
        int citiesLoaded = _weatherData.length;
        double targetProgress = citiesLoaded / _cities.length;

        // Accélération douce, puis ralentissement vers la fin
        if (_progress < targetProgress) {
          increment = 0.005 + (tickCount * 0.0001);
          // Limiter la progression pour qu'elle ne dépasse pas la cible
          if (_progress + increment > targetProgress && citiesLoaded < _cities.length) {
            increment = (targetProgress - _progress) / 10; // progression graduelle vers la cible
          }
        } else if (_progress < 1.0 && citiesLoaded == _cities.length) {
          // Terminer rapidement une fois toutes les villes chargées
          increment = 0.01;
        } else {
          increment = 0; // Attendre le chargement de plus de villes
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
    for (int i = 0; i < _cities.length; i++) {
      if (_hasError) break;

      final city = _cities[i];
      setState(() {
        _currentCity = city;
        _cityLoadingStatus[city] = 1; // En cours de chargement
      });

      try {
        // Simuler un délai de chargement pour cette ville
        await Future.delayed(const Duration(milliseconds: 1800));

        final weather = await _weatherService.getWeatherByCity(city);

        // Ajouter les données météo
        setState(() {
          _weatherData.add(weather);
          _cityLoadingStatus[city] = 2; // Chargement terminé
        });

        // Afficher la notification de réussite
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.green),
                  const SizedBox(width: 10),
                  Text('Données pour $city chargées avec succès'),
                ],
              ),
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

        // Attendre explicitement que l'utilisateur voie le statut "chargé" avant de passer à la suivante
        await Future.delayed(_validationDelay);

      } catch (e) {
        _handleError('Erreur lors du chargement de $city: $e');
        return;
      }
    }

    // Une fois toutes les villes chargées, attendre un peu avant de continuer
    if (_weatherData.isNotEmpty && _weatherData.length == _cities.length) {
      await Future.delayed(const Duration(milliseconds: 1000));
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
      _weatherData = [];

      // Réinitialiser le statut de chargement
      for (var city in _cities) {
        _cityLoadingStatus[city] = 0;
      }
    });
    _startLoading();
  }

  void _navigateToResults() {
    Future.delayed(const Duration(milliseconds: 500), () {
      Navigator.pushReplacement(
        context,
        FadeScaleRoute(
          page: ResultsScreen(
            weatherData: _weatherData,
            toggleTheme: widget.toggleTheme,
          ),
        ),
      );
    });
  }

  Widget _buildCityLoadingItem(String city) {
    bool isCurrent = city == _currentCity;
    bool isLoaded = _cityLoadingStatus[city] == 2;
    bool isLoading = _cityLoadingStatus[city] == 1;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface.withOpacity(0.7), // Semi-transparent
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            if (isLoading || isLoaded)
              BoxShadow(
                color: isLoaded
                    ? Colors.green.withOpacity(0.3)
                    : Theme.of(context).colorScheme.primary.withOpacity(0.3),
                blurRadius: 8,
                spreadRadius: 1,
              ),
          ],
          border: Border.all(
            color: isLoaded
                ? Colors.green
                : isLoading
                ? Theme.of(context).colorScheme.primary
                : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: isLoaded
                    ? Colors.green
                    : isLoading
                    ? Theme.of(context).colorScheme.primary
                    : Colors.grey.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: isLoaded
                    ? const Icon(Icons.check, color: Colors.white, size: 16)
                    : isLoading
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
                    : const SizedBox.shrink(),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                city,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: isLoading || isLoaded ? FontWeight.bold : FontWeight.normal,
                  color: isLoaded
                      ? Colors.green
                      : isLoading
                      ? Theme.of(context).colorScheme.primary
                      : null,
                ),
              ),
            ),
            if (isLoaded)
              const Icon(
                Icons.verified,
                color: Colors.green,
                size: 18,
              ).animate().scale(
                duration: const Duration(milliseconds: 300),
                curve: Curves.elasticOut,
              ),
            if (isLoading && !isLoaded)
              const CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
              ).animate()
                  .fadeIn(duration: 300.ms)
                  .shimmer(
                duration: 1200.ms,
                color: Colors.white24,
              ),
          ],
        ),
      ).animate().fadeIn(
        duration: const Duration(milliseconds: 400),
        delay: Duration(milliseconds: 100 * _cities.indexOf(city)),
      ).slideX(
        begin: 0.1,
        end: 0,
        duration: const Duration(milliseconds: 400),
        delay: Duration(milliseconds: 100 * _cities.indexOf(city)),
        curve: Curves.easeOutCubic,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Chargement en cours'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDarkMode
                  ? [
                Color(0xFF1A237E).withOpacity(0.8),
                Color(0xFF0D47A1).withOpacity(0.8),
              ]
                  : [
                Color(0xFF42A5F5).withOpacity(0.8),
                Color(0xFF1976D2).withOpacity(0.8),
              ],
            ),
          ),
        ),
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
        child: Stack(
          children: [
            // Animation de nuages en arrière-plan
            Positioned.fill(
              child: CloudAnimationUtil.buildAnimatedCloudsBackground(context),
            ),

            // Contenu principal avec scroll si nécessaire
            SafeArea(
              child: SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: MediaQuery.of(context).size.height -
                        MediaQuery.of(context).padding.top -
                        MediaQuery.of(context).padding.bottom,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (_isLoading) ...[
                          Text(
                            _currentMessage,
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: isDarkMode ? Colors.white : Colors.black87,
                            ),
                            textAlign: TextAlign.center,
                          )
                              .animate(onPlay: (controller) => controller.repeat())
                              .fadeIn(duration: 600.ms)
                              .then(delay: 2400.ms)
                              .fadeOut(duration: 600.ms),

                          const SizedBox(height: 30),

                          ProgressBar(progress: _progress),

                          const SizedBox(height: 30),

                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surface.withOpacity(0.8),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                              border: Border.all(
                                color: isDarkMode
                                    ? Colors.white.withOpacity(0.1)
                                    : Colors.black.withOpacity(0.05),
                                width: 1,
                              ),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Chargement des données météo',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: isDarkMode ? Colors.white : Colors.black87,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 12),

                                // État de chargement actuel
                                const SizedBox(height: 8),
                                if (_currentCity.isNotEmpty)
                                  Text(
                                    'Chargement de $_currentCity en cours...',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Theme.of(context).colorScheme.primary,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                const SizedBox(height: 16),

                                // Liste des villes
                                ..._cities.map((city) => _buildCityLoadingItem(city)),
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
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              color: isDarkMode ? Colors.white : Colors.black87,
                            ),
                            textAlign: TextAlign.center,
                          )
                              .animate()
                              .fadeIn(duration: 400.ms, delay: 200.ms)
                              .slideY(begin: 0.2, end: 0, duration: 400.ms, delay: 200.ms),

                          const SizedBox(height: 10),

                          Text(
                            _errorMessage,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: isDarkMode ? Colors.white70 : Colors.black87,
                            ),
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
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}