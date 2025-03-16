import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:weather_app/models/weather_model.dart';

class WeatherService {

  static const String _baseUrl = 'https://api.openweathermap.org/data/2.5';
  static const String _apiKey = '682c95399df447353f753eaffc0ea754';

  Future<WeatherModel> getWeatherByCity(String city) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/weather?q=$city&units=metric&appid=$_apiKey'),
      );

      if (response.statusCode == 200) {
        return WeatherModel.fromJson(json.decode(response.body));
      } else {
        throw Exception('Échec du chargement des données météo pour $city');
      }
    } catch (e) {
      throw Exception('Erreur réseau: $e');
    }
  }

  Future<List<WeatherModel>> getWeatherForCities(List<String> cities) async {
    List<WeatherModel> weatherList = [];

    for (String city in cities) {
      try {
        await Future.delayed(const Duration(milliseconds: 1200));

        WeatherModel weather = await getWeatherByCity(city);
        weatherList.add(weather);
        await Future.delayed(const Duration(milliseconds: 300));
      } catch (e) {
        print('Erreur pour $city: $e');
      }
    }

    return weatherList;
  }

}