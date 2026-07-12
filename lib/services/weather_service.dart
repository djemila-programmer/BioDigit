import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';

class WeatherService {
  // Open-Meteo API - gratuit, sans clé API
  static const String _baseUrl = 'https://api.open-meteo.com/v1/forecast';

  // Fallback: Ouagadougou
  static const double _fallbackLat = 12.3714;
  static const double _fallbackLon = -1.5197;
  static const String _fallbackCity = 'Ouagadougou, BF';

  /// Get weather using device geolocation, fallback to Ouagadougou.
  static Future<WeatherResult> getWeather() async {
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
        '$_baseUrl?latitude=$lat&longitude=$lon&current=temperature_2m,relative_humidity_2m,weather_code,wind_speed_10m&timezone=auto',
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
    final current = json['current'] as Map<String, dynamic>;
    final weatherCode = current['weather_code'] ?? 0;

    return WeatherData(
      temperature: (current['temperature_2m'] as num).toDouble(),
      description: _getDescription(weatherCode),
      iconCode: _getIconCode(weatherCode),
      humidity: current['relative_humidity_2m'] ?? 0,
      windSpeed: (current['wind_speed_10m'] as num?)?.toDouble() ?? 0,
    );
  }

  static String _getDescription(int code) {
    if (code == 0) return 'Ciel dégagé';
    if (code <= 3) return 'Partiellement nuageux';
    if (code <= 48) return 'Brouillard';
    if (code <= 57) return 'Bruine';
    if (code <= 67) return 'Pluie';
    if (code <= 77) return 'Neige';
    if (code <= 82) return 'Averses';
    if (code <= 86) return 'Neige';
    if (code <= 99) return 'Orage';
    return 'Inconnu';
  }

  static String _getIconCode(int code) {
    if (code == 0) return '01d';
    if (code <= 3) return '02d';
    if (code <= 48) return '50d';
    if (code <= 67) return '09d';
    if (code <= 77) return '13d';
    if (code <= 82) return '09d';
    if (code <= 86) return '13d';
    if (code <= 99) return '11d';
    return '01d';
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
