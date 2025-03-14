import 'dart:async';
import 'package:flutter/material.dart';
import 'package:weather_app/models/weather_model.dart';
import 'package:weather_app/screens/results_screen.dart';
import 'package:weather_app/services/weather_service.dart';
import 'package:weather_app/widgets/progress_bar.dart';

class LoadingScreen extends StatefulWidget {
  final Function toggleTheme;

  const LoadingScreen({Key? key, required this.toggleTheme}) : super(key: key);

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  final WeatherService _weatherService = WeatherService();
  final List<String> _cities = ['Paris', 'New York', 'Tokyo', 'London', 'Sydney'];
  final List<String> _loadingMessages = [
    'Nous téléchargeons les données...',
    'C\'est presque fini...',
    'Plus que quelques secondes avant d\'avoir le résultat...',
  ];

  List<WeatherModel> _weatherData = [];
  double _progress = 0.0;
  String _currentMessage = 'Nous téléchargeons les données...';
  int _messageIndex = 0;
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _startLoading();
  }

  void _startLoading() {
    // Simulation de progression
    Timer.periodic(const Duration(milliseconds: 100), (progressTimer) {
      if (_progress >= 1.0) {
        progressTimer.cancel();
        if (_weatherData.isNotEmpty) {
          setState(() {
            _isLoading = false;
          });
          _navigateToResults();
        }
      } else {
        setState(() {
          _progress += 0.01;
        });
      }
    });

    // Rotation des messages
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

    // Chargement des données météo
    _loadWeatherData();
  }

  Future<void> _loadWeatherData() async {
    try {
      final weatherData = await _weatherService.getWeatherForCities(_cities);
      if (weatherData.isNotEmpty) {
        setState(() {
          _weatherData = weatherData;
          _hasError = false;
          _errorMessage = '';
        });
      } else {
        _handleError('Aucune donnée météo trouvée');
      }
    } catch (e) {
      _handleError('Erreur de connexion: $e');
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
    });
    _startLoading();
  }

  void _navigateToResults() {
    Future.delayed(const Duration(milliseconds: 500), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ResultsScreen(
            weatherData: _weatherData,
            toggleTheme: widget.toggleTheme,
          ),
        ),
      );
    });
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
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_isLoading) ...[
              Text(
                _currentMessage,
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              ProgressBar(progress: _progress),
              const SizedBox(height: 40),
              const Text(
                'Nous récupérons les informations météo pour 5 villes...',
                textAlign: TextAlign.center,
              ),
            ] else if (_hasError) ...[
              const Icon(
                Icons.error_outline,
                size: 80,
                color: Colors.red,
              ),
              const SizedBox(height: 20),
              Text(
                'Une erreur est survenue',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                _errorMessage,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                onPressed: _retry,
                icon: const Icon(Icons.refresh),
                label: const Text('Réessayer'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}