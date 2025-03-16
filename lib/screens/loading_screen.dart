import 'dart:async';
import 'package:flutter/material.dart';
import 'package:weather_app/models/weather_model.dart';
import 'package:weather_app/screens/results_screen.dart';
import 'package:weather_app/services/weather_service.dart';
import 'package:weather_app/utils/Cloud_animation_util.dart';
import 'package:weather_app/widgets/progress_bar.dart';
import 'package:flutter_animate/flutter_animate.dart';

class LoadingScreen extends StatefulWidget {
  final Function toggleTheme;

  const LoadingScreen({Key? key, required this.toggleTheme}) : super(key: key);

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class FadeScaleRoute extends PageRouteBuilder {
  final Widget page;

  FadeScaleRoute({required this.page})
      : super(
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      var curve = Curves.easeOutCubic;
      var curveTween = CurveTween(curve: curve);
      var fadeTween = Tween<double>(begin: 0.0, end: 1.0);
      var fadeAnimation = fadeTween.animate(animation.drive(curveTween),);
      var scaleTween = Tween<double>(begin: 0.92, end: 1.0);
      var scaleAnimation = scaleTween.animate(animation.drive(curveTween),);

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
  final WeatherService weatherService = WeatherService();

  final List<String> cities = ['Dakar', 'Saint-Louis', 'Thies', 'Diourbel', 'Ziguinchor'];

  final List<String> loadingMessages = [
    'Nous téléchargeons les données...',
    'C\'est presque fini...',
    'Plus que quelques secondes avant d\'avoir le résultat...',
  ];

  List<WeatherModel> weatherData = [];
  double progress = 0.0;
  String currentMessage = 'Nous téléchargeons les données...';
  int messageIndex = 0;
  bool isLoading = true;
  bool hasError = false;
  String errorMessage = '';
  String currentCity = '';
  late AnimationController pulseController;
  bool isDarkMode = false;

  Map<String, int> cityLoadingStatus = {};

  final Duration validationDelay = const Duration(milliseconds: 1500);

  @override
  void initState() {
    super.initState();
    isDarkMode = false;
    pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    for (var city in cities) {
      cityLoadingStatus[city] = 0;
    }

    startLoading();
  }

  @override
  void dispose() {
    pulseController.dispose();
    super.dispose();
  }

  void startLoading() {
    int tickCount = 0;
    Timer.periodic(const Duration(milliseconds: 100), (progressTimer) {
      tickCount++;
      if (progress >= 1.0) {
        progressTimer.cancel();
        if (weatherData.isNotEmpty) {
          setState(() {
            isLoading = false;
          });
          navigateToResults();
        }
      } else {
        double increment;
        int citiesLoaded = weatherData.length;
        double targetProgress = citiesLoaded / cities.length;

        if (progress < targetProgress) {
          increment = 0.005 + (tickCount * 0.0001);
          if (progress + increment > targetProgress && citiesLoaded < cities.length) {
            increment = (targetProgress - progress) / 10;
          }
        } else if (progress < 1.0 && citiesLoaded == cities.length) {
          increment = 0.01;
        } else {
          increment = 0;
        }

        setState(() {
          progress += increment;
        });
      }
    });

    Timer.periodic(const Duration(seconds: 3), (messageTimer) {
      if (progress >= 1.0) {
        messageTimer.cancel();
      } else {
        setState(() {
          messageIndex = (messageIndex + 1) % loadingMessages.length;
          currentMessage = loadingMessages[messageIndex];
        });
      }
    });

    loadCitiesSequentially();
  }

  Future<void> loadCitiesSequentially() async {
    for (int i = 0; i < cities.length; i++) {
      if (hasError) break;

      final city = cities[i];
      setState(() {
        currentCity = city;
        cityLoadingStatus[city] = 1;
      });

      try {
        await Future.delayed(const Duration(milliseconds: 1800));

        final weather = await weatherService.getWeatherByCity(city);

        setState(() {
          weatherData.add(weather);
          cityLoadingStatus[city] = 2;
        });

        await Future.delayed(validationDelay);

      } catch (e) {
        handleError('Erreur lors du chargement de $city: $e');
        return;
      }
    }

    if (weatherData.isNotEmpty && weatherData.length == cities.length) {
      await Future.delayed(const Duration(milliseconds: 1000));
    }
  }

  void handleError(String message) {
    setState(() {
      hasError = true;
      errorMessage = message;
      isLoading = false;
    });
  }

  void retry() {
    setState(() {
      progress = 0.0;
      isLoading = true;
      hasError = false;
      errorMessage = '';
      messageIndex = 0;
      currentMessage =loadingMessages[0];
      currentCity = '';
      weatherData = [];

      for (var city in cities) {
        cityLoadingStatus[city] = 0;
      }
    });
    startLoading();
  }

  void navigateToResults() {
    Future.delayed(const Duration(milliseconds: 500), () {
      Navigator.pushReplacement(
        context,
        FadeScaleRoute(
          page: ResultsScreen(
            weatherData: weatherData,
            toggleTheme: widget.toggleTheme,
          ),
        ),
      );
    });
  }

  Widget buildCityLoadingItem(String city) {
    bool isCurrent = city == currentCity;
    bool isLoaded = cityLoadingStatus[city] == 2;
    bool isLoading = cityLoadingStatus[city] == 1;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface.withOpacity(0.7),
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
                  animation: pulseController,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: 0.5 + (pulseController.value * 0.5),
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
        delay: Duration(milliseconds: 100 * cities.indexOf(city)),
      ).slideX(
        begin: 0.1,
        end: 0,
        duration: const Duration(milliseconds: 400),
        delay: Duration(milliseconds: 100 * cities.indexOf(city)),
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
            Positioned.fill(
              child: CloudAnimationUtil.buildAnimatedCloudsBackground(context),
            ),
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
                        if (isLoading) ...[
                          Text(
                            currentMessage,
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

                          ProgressBar(progress: progress),

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

                                const SizedBox(height: 8),
                                if (currentCity.isNotEmpty)
                                  Text(
                                    'Chargement de $currentCity en cours...',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Theme.of(context).colorScheme.primary,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                const SizedBox(height: 16),

                                ...cities.map((city) => buildCityLoadingItem(city)),
                              ],
                            ),
                          )
                              .animate()
                              .fadeIn(duration: 600.ms, delay: 300.ms)
                              .slideY(begin: 0.2, end: 0, duration: 600.ms, delay: 300.ms),
                        ] else if (hasError) ...[
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
                            errorMessage,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: isDarkMode ? Colors.white70 : Colors.black87,
                            ),
                          )
                              .animate()
                              .fadeIn(duration: 400.ms, delay: 400.ms),

                          const SizedBox(height: 30),

                          ElevatedButton.icon(
                            onPressed: retry,
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