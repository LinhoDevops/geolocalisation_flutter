import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:weather_app/screens/splash_screen.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:weather_app/utils/theme_manager.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(const WeatherApp());
}

class WeatherApp extends StatefulWidget {
  const WeatherApp({Key? key}) : super(key: key);

  @override
  State<WeatherApp> createState() => _WeatherAppState();
}

class _WeatherAppState extends State<WeatherApp> with SingleTickerProviderStateMixin {
  bool isDarkMode = false;
  late AnimationController themeAnimationController;
  late Animation<double> themeAnimation;

  @override
  void initState() {
    super.initState();
    themeAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    themeAnimation = CurvedAnimation(
      parent: themeAnimationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    themeAnimationController.dispose();
    super.dispose();
  }

  void _toggleTheme() {
    setState(() {
      isDarkMode = !isDarkMode;
      if (isDarkMode) {
        themeAnimationController.forward();
      } else {
        themeAnimationController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: themeAnimation,
      builder: (context, child) {
        return MaterialApp(
          title: 'Weather Explorer',
          theme: ThemeManager.lightTheme,
          darkTheme: ThemeManager.darkTheme,
          themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
          debugShowCheckedModeBanner: false,
          home: SplashScreen(toggleTheme: _toggleTheme),
        );
      },
    );
  }
}