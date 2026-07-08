import 'package:flutter/material.dart';

class AlertModel {
  final String id;
  final String title;
  final String description;
  final String severity; // critical, warning, info
  final String timeAgo;
  final String location;
  final String sensorId;
  final IconData icon;

  const AlertModel({
    required this.id,
    required this.title,
    required this.description,
    required this.severity,
    required this.timeAgo,
    required this.location,
    required this.sensorId,
    required this.icon,
  });

  Color get severityColor {
    switch (severity) {
      case 'critical':
        return const Color(0xFFBA1A1A);
      case 'warning':
        return const Color(0xFF7A5649);
      default:
        return const Color(0xFF717A6D);
    }
  }

  Color get severityContainerColor {
    switch (severity) {
      case 'critical':
        return const Color(0xFFFFDAD6);
      case 'warning':
        return const Color(0xFFFDCDBC);
      default:
        return const Color(0xFFE2E2E2);
    }
  }

  static List<AlertModel> mockAlerts = [
    AlertModel(
      id: '1',
      title: 'Methane Leak Risk - Tank A',
      description:
          'Pressure sensor detected anomalous drop in Tank A. Immediate inspection of the primary valve is required to prevent gas loss.',
      severity: 'critical',
      timeAgo: '2m ago',
      location: 'North Sector, Grid 4',
      sensorId: 'PR-992-A',
      icon: Icons.warning,
    ),
    AlertModel(
      id: '2',
      title: 'High Temperature detected',
      description:
          'Slurry core temperature is approaching 42°C. Optimization of cooling systems or agitation speed may be necessary.',
      severity: 'warning',
      timeAgo: '15m ago',
      location: 'East Sector, Digester 2',
      sensorId: 'TH-441-B',
      icon: Icons.thermostat,
    ),
    AlertModel(
      id: '3',
      title: 'Sensor Disconnected - HC-SR04',
      description:
          'Ultrasonic slurry level sensor has lost connectivity. Check wiring and power supply to the sensor module.',
      severity: 'critical',
      timeAgo: '28m ago',
      location: 'Digester Unit 01',
      sensorId: 'HCSR04-01',
      icon: Icons.sensors_off,
    ),
    AlertModel(
      id: '4',
      title: 'Pressure Threshold Exceeded',
      description:
          'Internal biodigester pressure has exceeded 1.5 bar maximum threshold. Gas release valve activated automatically.',
      severity: 'warning',
      timeAgo: '45m ago',
      location: 'Main Digester',
      sensorId: 'BMP280-01',
      icon: Icons.speed,
    ),
    AlertModel(
      id: '5',
      title: 'Methane Anomaly Detected',
      description:
          'MQ-4 sensor detected unusual methane concentration pattern. AI model flags potential gas composition anomaly.',
      severity: 'warning',
      timeAgo: '1h ago',
      location: 'Gas Storage Dome',
      sensorId: 'MQ4-01',
      icon: Icons.gas_meter,
    ),
    AlertModel(
      id: '6',
      title: 'Network Interruption Resolved',
      description:
          'ESP8266 Wi-Fi connection was interrupted for 3 minutes. Connection restored and data sync completed.',
      severity: 'info',
      timeAgo: '1h ago',
      location: 'ESP8266 Controller',
      sensorId: 'ESP8266-01',
      icon: Icons.wifi_off,
    ),
    AlertModel(
      id: '7',
      title: 'Grid Export Optimized',
      description:
          'Energy production peak reached. Smart grid switch has prioritized external battery charging.',
      severity: 'info',
      timeAgo: '2h ago',
      location: 'Main Grid',
      sensorId: 'GRD-001',
      icon: Icons.bolt,
    ),
  ];
}
