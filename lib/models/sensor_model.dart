import 'package:flutter/material.dart';

class SensorModel {
  final String id;
  final String name;
  final String modelNumber;
  final String unit;
  final double value;
  final String status; // active, warning, critical
  final double batteryLevel;
  final String signalQuality;
  final IconData icon;
  final Color iconColor;
  final List<double> sparklineData;
  final String trend; // rising, falling, stable
  final String lastUpdate;
  final double minValue;
  final double maxValue;
  final String lastCalibration;
  final String nextMaintenance;

  const SensorModel({
    required this.id,
    required this.name,
    required this.modelNumber,
    required this.unit,
    required this.value,
    required this.status,
    required this.batteryLevel,
    required this.signalQuality,
    required this.icon,
    required this.iconColor,
    this.sparklineData = const [],
    this.trend = 'stable',
    this.lastUpdate = '2 min ago',
    this.minValue = 0,
    this.maxValue = 100,
    this.lastCalibration = '2026-05-20',
    this.nextMaintenance = '2026-07-15',
  });

  static List<SensorModel> mockSensors = [
    SensorModel(
      id: 'DHT22',
      name: 'Temperature',
      modelNumber: 'DHT22',
      unit: '°C',
      value: 38.4,
      status: 'active',
      batteryLevel: 84,
      signalQuality: 'Excellent',
      icon: Icons.thermostat,
      iconColor: const Color(0xFF00450D),
      sparklineData: [35, 35, 25, 20, 15, 10],
      trend: 'rising',
      lastUpdate: '30s ago',
      minValue: 25,
      maxValue: 40,
      lastCalibration: '2026-05-20',
      nextMaintenance: '2026-08-20',
    ),
    SensorModel(
      id: 'MQ4',
      name: 'Methane (CH₄)',
      modelNumber: 'MQ-4',
      unit: 'PPM',
      value: 1240,
      status: 'warning',
      batteryLevel: 42,
      signalQuality: 'Stable',
      icon: Icons.gas_meter,
      iconColor: const Color(0xFF7A5649),
      sparklineData: [20, 35, 15, 25, 10, 30],
      trend: 'rising',
      lastUpdate: '45s ago',
      minValue: 150,
      maxValue: 500,
      lastCalibration: '2026-04-10',
      nextMaintenance: '2026-06-25',
    ),
    SensorModel(
      id: 'BMP280',
      name: 'Pressure',
      modelNumber: 'BMP280',
      unit: 'kPa',
      value: 101.3,
      status: 'active',
      batteryLevel: 98,
      signalQuality: 'Excellent',
      icon: Icons.speed,
      iconColor: const Color(0xFF262F89),
      sparklineData: [25, 25, 24, 25, 25, 24, 25],
      trend: 'stable',
      lastUpdate: '1 min ago',
      minValue: 80,
      maxValue: 150,
      lastCalibration: '2026-05-15',
      nextMaintenance: '2026-09-15',
    ),
    SensorModel(
      id: 'HCSR04',
      name: 'Slurry Level',
      modelNumber: 'HC-SR04',
      unit: '%',
      value: 92,
      status: 'critical',
      batteryLevel: 12,
      signalQuality: 'Weak',
      icon: Icons.height,
      iconColor: const Color(0xFFBA1A1A),
      sparklineData: [38, 35, 30, 20, 10, 5],
      trend: 'falling',
      lastUpdate: '2 min ago',
      minValue: 20,
      maxValue: 90,
      lastCalibration: '2026-03-28',
      nextMaintenance: '2026-06-20',
    ),
  ];
}

class DashboardMetric {
  final String label;
  final String value;
  final String unit;
  final IconData icon;
  final Color color;
  final String status;
  final double progress;
  final String trend;
  final String lastUpdate;
  final String sensorModel;

  const DashboardMetric({
    required this.label,
    required this.value,
    required this.unit,
    required this.icon,
    required this.color,
    required this.status,
    required this.progress,
    this.trend = 'stable',
    this.lastUpdate = '2 min ago',
    this.sensorModel = '',
  });

  static List<DashboardMetric> mockMetrics = [
    DashboardMetric(
      label: 'Temperature',
      value: '38.5',
      unit: '°C',
      icon: Icons.thermostat,
      color: const Color(0xFF00450D),
      status: 'NORMAL',
      progress: 0.75,
      trend: 'rising',
      lastUpdate: '30s ago',
      sensorModel: 'DHT22',
    ),
    DashboardMetric(
      label: 'Pressure',
      value: '1.05',
      unit: 'bar',
      icon: Icons.speed,
      color: const Color(0xFF00450D),
      status: 'NORMAL',
      progress: 0.50,
      trend: 'stable',
      lastUpdate: '1 min ago',
      sensorModel: 'BMP280',
    ),
    DashboardMetric(
      label: 'Methane',
      value: '62',
      unit: '%',
      icon: Icons.gas_meter,
      color: const Color(0xFF7A5649),
      status: 'STABLE',
      progress: 0.62,
      trend: 'rising',
      lastUpdate: '45s ago',
      sensorModel: 'MQ-4',
    ),
    DashboardMetric(
      label: 'Level',
      value: '85',
      unit: '%',
      icon: Icons.layers,
      color: const Color(0xFF262F89),
      status: 'FULL',
      progress: 0.85,
      trend: 'falling',
      lastUpdate: '2 min ago',
      sensorModel: 'HC-SR04',
    ),
  ];
}
