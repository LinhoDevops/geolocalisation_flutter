import 'package:flutter/material.dart';

// Fonction de traduction des conditions météo
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

// Fonction pour obtenir une icône personnalisée en fonction de la région et de la température
String getCustomIconForRegion(String cityName, double temperature) {
  // Icônes personnalisées pour différentes régions
  if (cityName.toLowerCase().contains('saint-louis')) {
    // Saint-Louis: plus frais et côtier
    if (temperature < 20) return '01d'; // ciel dégagé
    if (temperature < 25) return '02d'; // quelques nuages
    if (temperature < 30) return '03d'; // nuages épars
    return '04d'; // ciel couvert
  }
  else if (cityName.toLowerCase().contains('dakar')) {
    // Dakar: côtier mais plus chaud
    if (temperature < 22) return '01d'; // ciel dégagé
    if (temperature < 27) return '02d'; // quelques nuages
    if (temperature < 32) return '09d'; // averses légères
    return '10d'; // pluie
  }
  else if (cityName.toLowerCase().contains('matam') || cityName.toLowerCase().contains('tambacounda')) {
    // Régions intérieures chaudes
    if (temperature < 25) return '01d'; // ciel dégagé
    if (temperature < 30) return '01d'; // ciel dégagé (encore)
    if (temperature < 35) return '50d'; // brume (dust)
    return '11d'; // orage
  }
  else if (cityName.toLowerCase().contains('ziguinchor') || cityName.toLowerCase().contains('kolda')) {
    // Régions sud plus humides
    if (temperature < 23) return '02d'; // quelques nuages
    if (temperature < 28) return '03d'; // nuages épars
    if (temperature < 33) return '09d'; // averses
    return '10d'; // pluie
  }

  // Icône par défaut basée sur la température pour les autres régions
  if (temperature < 20) return '01d'; // ciel dégagé
  if (temperature < 25) return '02d'; // quelques nuages
  if (temperature < 30) return '03d'; // nuages épars
  if (temperature < 35) return '04d'; // ciel couvert
  return '11d'; // orage
}

// Sélecteur de couleur personnalisé pour les icônes météo
Color getCustomIconColor(String cityName, double temperature) {
  // Couleurs personnalisées pour différentes régions
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

  // Couleur par défaut basée sur la température pour les autres régions
  if (temperature < 20) return Colors.blue;
  if (temperature < 25) return Colors.teal;
  if (temperature < 30) return Colors.orange;
  if (temperature < 35) return Colors.deepOrange;
  return Colors.red;
}