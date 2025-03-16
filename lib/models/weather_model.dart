class WeatherModel {
  final String cityName;
  final double temperature;
  final double feelsLike;
  final String description;
  final String icon;
  final double humidity;
  final double pressure;
  final double windSpeed;
  final double longitude;
  final double latitude;

  WeatherModel({
    required this.cityName,
    required this.temperature,
    required this.feelsLike,
    required this.description,
    required this.icon,
    required this.humidity,
    required this.pressure,
    required this.windSpeed,
    required this.longitude,
    required this.latitude,
  });

  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    return WeatherModel(
      cityName: json['name'],
      temperature: json['main']['temp'].toDouble(),
      feelsLike: json['main']['feels_like'].toDouble(),
      description: json['weather'][0]['description'],
      icon: json['weather'][0]['icon'],
      humidity: json['main']['humidity'].toDouble(),
      pressure: json['main']['pressure'].toDouble(),
      windSpeed: json['wind']['speed'].toDouble(),
      longitude: json['coord']['lon'].toDouble(),
      latitude: json['coord']['lat'].toDouble(),
    );
  }
}