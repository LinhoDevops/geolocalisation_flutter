import 'package:flutter/material.dart';

String translateWeatherCondition(String englishCondition) {
  final Map<String, String> translations = {
    'clear sky': 'ciel dégagé',
    'few clouds': 'quelques nuages',
    'scattered clouds': 'nuages épars',
    'broken clouds': 'ciel couvert',
    'shower rain': 'averses',
    'rain': 'pluie',
    'thunderstorm': 'orage',
    'snow': 'neige',
    'mist': 'brume',
    'overcast clouds': 'couvert',
    'light rain': 'pluie légère',
    'moderate rain': 'pluie modérée',
    'heavy intensity rain': 'forte pluie',
    'very heavy rain': 'très forte pluie',
    'drizzle': 'bruine',
    'haze': 'brume sèche',
    'fog': 'brouillard',
    'sand': 'sable',
    'dust': 'poussière',
    'volcanic ash': 'cendres volcaniques',
    'squalls': 'rafales',
    'tornado': 'tornade',
    'partly cloudy': 'partiellement nuageux',
    'cloudy': 'nuageux',
    'sunny': 'ensoleillé',
    'windy': 'venteux',
    'humid': 'humide',
    'hot': 'chaud',
    'cold': 'froid',
  };

  return translations[englishCondition.toLowerCase()] ?? englishCondition;
}

String getCustomIconForRegion(String cityName, double temperature) {
  if (cityName.toLowerCase().contains('saint-louis')) {
    if (temperature < 20) return '01d';
    if (temperature < 25) return '02d';
    if (temperature < 30) return '03d';
    return '04d'; //
  }
  else if (cityName.toLowerCase().contains('dakar')) {
    if (temperature < 22) return '01d';
    if (temperature < 27) return '02d';
    if (temperature < 32) return '09d';
    return '10d';
  }
  else if (cityName.toLowerCase().contains('matam') || cityName.toLowerCase().contains('tambacounda')) {
    if (temperature < 25) return '01d';
    if (temperature < 30) return '01d';
    if (temperature < 35) return '50d';
    return '11d';
  }
  else if (cityName.toLowerCase().contains('ziguinchor') || cityName.toLowerCase().contains('kolda')) {
    if (temperature < 23) return '02d';
    if (temperature < 28) return '03d';
    if (temperature < 33) return '09d';
    return '10d';
  }

  if (temperature < 20) return '01d';
  if (temperature < 25) return '02d';
  if (temperature < 30) return '03d';
  if (temperature < 35) return '04d';
  return '11d';
}

Color getCustomIconColor(String cityName, double temperature) {
  if (cityName.toLowerCase().contains('saint-louis')) {
    return Colors.blue;
  }
  else if (cityName.toLowerCase().contains('dakar')) {
    return Colors.teal;
  }
  else if (cityName.toLowerCase().contains('matam') || cityName.toLowerCase().contains('tambacounda')) {
    return Colors.amber;
  }
  else if (cityName.toLowerCase().contains('ziguinchor') || cityName.toLowerCase().contains('kolda')) {
    return Colors.green;
  }

  if (temperature < 20) return Colors.blue;
  if (temperature < 25) return Colors.teal;
  if (temperature < 30) return Colors.orange;
  if (temperature < 35) return Colors.deepOrange;
  return Colors.red;
}