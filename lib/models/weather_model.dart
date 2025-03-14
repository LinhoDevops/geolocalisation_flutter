class WeatherModel {
  final String cityName;
  final double temperature;
  final String description;
  final double humidity;
  final double windSpeed;
  final String icon;
  final double latitude;
  final double longitude;

  WeatherModel({
    required this.cityName,
    required this.temperature,
    required this.description,
    required this.humidity,
    required this.windSpeed,
    required this.icon,
    required this.latitude,
    required this.longitude,
  });

  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    return WeatherModel(
      cityName: json['name'] ?? '',
      temperature: (json['main']['temp'] as num?)?.toDouble() ?? 0.0,
      description: json['weather'][0]['description'] ?? '',
      humidity: (json['main']['humidity'] as num?)?.toDouble() ?? 0.0,
      windSpeed: (json['wind']['speed'] as num?)?.toDouble() ?? 0.0,
      icon: json['weather'][0]['icon'] ?? '01d',
      latitude: (json['coord']['lat'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['coord']['lon'] as num?)?.toDouble() ?? 0.0,
    );
  }
}