import 'package:flutter/material.dart';
import 'package:weather_app/models/weather_model.dart';
import 'package:weather_app/widgets/map_view.dart';
import 'package:weather_app/widgets/weather_detail_card.dart';

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
    return Scaffold(
      appBar: AppBar(
        title: Text(weather.cityName),
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
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Détails météo pour ${weather.cityName}',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 20),
                  WeatherDetailCard(
                    icon: 'https://openweathermap.org/img/wn/${weather.icon}@2x.png',
                    temperature: weather.temperature,
                    description: weather.description,
                    humidity: weather.humidity,
                    windSpeed: weather.windSpeed,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Localisation',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Latitude: ${weather.latitude}, Longitude: ${weather.longitude}',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Carte',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            MapView(
              latitude: weather.latitude,
              longitude: weather.longitude,
              cityName: weather.cityName,
            ),
          ],
        ),
      ),
    );
  }
}