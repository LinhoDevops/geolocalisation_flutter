import 'package:flutter/material.dart';
import 'package:weather_app/screens/splash_screen.dart';
import 'package:weather_app/utils/theme_manager.dart';
import 'package:weather_app/utils/google_maps_config.dart';
import 'package:google_maps_flutter_web/google_maps_flutter_web.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.light;

  void toggleTheme() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weather App',
      debugShowCheckedModeBanner: false,
      theme: ThemeManager.lightTheme,
      darkTheme: ThemeManager.darkTheme,
      themeMode: _themeMode,
      home: SplashScreen(toggleTheme: toggleTheme),
    );
  }
}