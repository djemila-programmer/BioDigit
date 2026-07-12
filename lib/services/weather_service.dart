import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import '../core/app_env.dart';

class WeatherService {
  static String get _apiKey => AppEnv.openWeatherApiKey;
  static const String _baseUrl = 'https://api.openweathermap.org/data/2.5/weather';

  // Fallback: Ouagadougou
  static const double _fallbackLat = 12.3714;
  static const double _fallbackLon = -1.5197;
  static const String _fallbackCity = 'Ouagadougou, BF';

  /// Get weather using device geolocation, fallback to Ouagadougou.
  static Future<WeatherResult> getWeather() async {
    if (_apiKey.isEmpty) {
      return WeatherResult(city: _fallbackCity, data: null);
    }

    double lat = _fallbackLat;
    double lon = _fallbackLon;
    String city = _fallbackCity;

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return WeatherResult(city: city, data: await _fetchWeather(lat, lon));
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return WeatherResult(city: city, data: await _fetchWeather(lat, lon));
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return WeatherResult(city: city, data: await _fetchWeather(lat, lon));
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.low,
          timeLimit: Duration(seconds: 8),
        ),
      );
      lat = position.latitude;
      lon = position.longitude;
      city = '${position.latitude.toStringAsFixed(2)}, ${position.longitude.toStringAsFixed(2)}';
    } catch (_) {
      // Use fallback coordinates
    }

    final data = await _fetchWeather(lat, lon);
    return WeatherResult(city: city, data: data);
  }

  static Future<WeatherData?> _fetchWeather(double lat, double lon) async {
    try {
      final uri = Uri.parse(
        '$_baseUrl?lat=$lat&lon=$lon&appid=$_apiKey&units=metric&lang=fr',
      );
      final response = await http.get(uri).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return WeatherData.fromJson(data);
      }
    } catch (_) {}
    // Fallback: typical Ouagadougou temperature
    return WeatherData(
      temperature: 32,
      description: 'Ensoleillé',
      iconCode: '01d',
      humidity: 45,
      windSpeed: 3.5,
    );
  }

  /// Legacy method kept for compatibility.
  static Future<WeatherData?> getOuagaWeather() async {
    final result = await getWeather();
    return result.data;
  }
}

class WeatherResult {
  final String city;
  final WeatherData? data;
  const WeatherResult({required this.city, required this.data});
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
