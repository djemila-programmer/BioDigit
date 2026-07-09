import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class WeatherService {
  // API key gratuite OpenWeatherMap
  // Inscrivez-vous sur https://openweathermap.org/api pour obtenir une clé
  static const String _apiKey = 'bd5e378503939ddaee76f12ad7a97608'; // Clé de démo
  static const String _baseUrl = 'https://api.openweathermap.org/data/2.5/weather';

  // Coordonnées de Ouagadougou
  static const double _lat = 12.3714;
  static const double _lon = -1.5197;

  static Future<WeatherData?> getOuagaWeather() async {
    try {
      final uri = Uri.parse(
        '$_baseUrl?lat=$_lat&lon=$_lon&appid=$_apiKey&units=metric&lang=fr',
      );
      final response = await http.get(uri).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return WeatherData.fromJson(data);
      }
    } catch (_) {}
    return null;
  }
}

class WeatherData {
  final double temperature;
  final String description;
  final String iconCode;
  final int humidity;
  final double windSpeed;

  WeatherData({
    required this.temperature,
    required this.description,
    required this.iconCode,
    required this.humidity,
    required this.windSpeed,
  });

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    final main = json['main'] as Map<String, dynamic>;
    final weather = (json['weather'] as List).first as Map<String, dynamic>;
    final wind = json['wind'] as Map<String, dynamic>;

    return WeatherData(
      temperature: (main['temp'] as num).toDouble(),
      description: weather['description'] ?? '',
      iconCode: weather['icon'] ?? '01d',
      humidity: main['humidity'] ?? 0,
      windSpeed: (wind['speed'] as num?)?.toDouble() ?? 0,
    );
  }

  IconData get weatherIcon {
    // Icônes selon le code météo OpenWeatherMap
    if (iconCode.startsWith('01')) return Icons.wb_sunny;
    if (iconCode.startsWith('02')) return Icons.cloud;
    if (iconCode.startsWith('03') || iconCode.startsWith('04')) return Icons.cloud;
    if (iconCode.startsWith('09') || iconCode.startsWith('10')) return Icons.cloud;
    if (iconCode.startsWith('11')) return Icons.flash_on;
    if (iconCode.startsWith('13')) return Icons.ac_unit;
    if (iconCode.startsWith('50')) return Icons.foggy;
    return Icons.wb_sunny;
  }

  Color get weatherColor {
    if (temperature > 35) return const Color(0xFFE53935); // Très chaud - rouge
    if (temperature > 28) return const Color(0xFFFB8C00); // Chaud - orange
    if (temperature > 20) return const Color(0xFF43A047); // Agréable - vert
    return const Color(0xFF1E88E5); // Frais - bleu
  }
}
