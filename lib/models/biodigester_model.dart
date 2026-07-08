import 'package:flutter/material.dart';

/// Biodigester system data model with realistic mock data
/// for a smart monitoring system in Burkina Faso.
class BiodigesterModel {
  final String name;
  final String location;
  final double capacity; // m³
  final double currentLevel; // %
  final double todayProduction; // m³/day
  final double weeklyProduction; // m³
  final double monthlyProduction; // m³
  final double yearlyProduction; // m³
  final double efficiency; // %
  final double energyGenerated; // kWh
  final double co2Reduction; // kg

  const BiodigesterModel({
    required this.name,
    required this.location,
    required this.capacity,
    required this.currentLevel,
    required this.todayProduction,
    required this.weeklyProduction,
    required this.monthlyProduction,
    required this.yearlyProduction,
    required this.efficiency,
    required this.energyGenerated,
    required this.co2Reduction,
  });

  static const BiodigesterModel mockBiodigester = BiodigesterModel(
    name: 'BioDigester Unit 01',
    location: 'Ferme BioDigit, Plateau Central',
    capacity: 20.0,
    currentLevel: 85.0,
    todayProduction: 12.5,
    weeklyProduction: 87.5,
    monthlyProduction: 375.0,
    yearlyProduction: 4562.5,
    efficiency: 78.5,
    energyGenerated: 42.8,
    co2Reduction: 1250.0,
  );
}

/// ESP8266 Controller status model.
class ESP8266Status {
  final String status;
  final String wifiStrength;
  final String lastSync;
  final String firmwareVersion;
  final int batteryLevel;
  final String ipAddress;
  final String uptime;
  final double cpuTemp;

  const ESP8266Status({
    required this.status,
    required this.wifiStrength,
    required this.lastSync,
    required this.firmwareVersion,
    required this.batteryLevel,
    required this.ipAddress,
    required this.uptime,
    required this.cpuTemp,
  });

  static const ESP8266Status mockStatus = ESP8266Status(
    status: 'Connected',
    wifiStrength: 'Excellent (-42 dBm)',
    lastSync: '15 seconds ago',
    firmwareVersion: 'v2.4.1-bf',
    batteryLevel: 92,
    ipAddress: '192.168.1.100',
    uptime: '14d 6h 32m',
    cpuTemp: 45.2,
  );
}

/// Supabase connection status model.
class SupabaseStatus {
  final String connectionStatus;
  final String cloudSync;
  final String lastUpload;
  final String dataIntegrity;
  final int recordsToday;
  final double databaseSize;

  const SupabaseStatus({
    required this.connectionStatus,
    required this.cloudSync,
    required this.lastUpload,
    required this.dataIntegrity,
    required this.recordsToday,
    required this.databaseSize,
  });

  static const SupabaseStatus mockStatus = SupabaseStatus(
    connectionStatus: 'Connected',
    cloudSync: 'Active',
    lastUpload: '30 seconds ago',
    dataIntegrity: '100% Verified',
    recordsToday: 2847,
    databaseSize: 1.24,
  );
}

/// Threshold configuration for alert system.
class ThresholdConfig {
  final String label;
  final IconData icon;
  final Color color;
  final double minValue;
  final double maxValue;
  final String unit;
  final double currentValue;

  const ThresholdConfig({
    required this.label,
    required this.icon,
    required this.color,
    required this.minValue,
    required this.maxValue,
    required this.unit,
    required this.currentValue,
  });

  static List<ThresholdConfig> mockThresholds = [
    ThresholdConfig(
      label: 'Temperature',
      icon: Icons.thermostat,
      color: const Color(0xFF00450D),
      minValue: 25.0,
      maxValue: 40.0,
      unit: '°C',
      currentValue: 38.5,
    ),
    ThresholdConfig(
      label: 'Pressure',
      icon: Icons.speed,
      color: const Color(0xFF262F89),
      minValue: 0.8,
      maxValue: 1.5,
      unit: 'bar',
      currentValue: 1.05,
    ),
    ThresholdConfig(
      label: 'Methane',
      icon: Icons.gas_meter,
      color: const Color(0xFF7A5649),
      minValue: 150.0,
      maxValue: 500.0,
      unit: 'ppm',
      currentValue: 320.0,
    ),
    ThresholdConfig(
      label: 'Slurry Level',
      icon: Icons.height,
      color: const Color(0xFFBA1A1A),
      minValue: 20.0,
      maxValue: 90.0,
      unit: '%',
      currentValue: 85.0,
    ),
  ];
}

/// Predictive maintenance item.
class MaintenanceItem {
  final String title;
  final String description;
  final String priority; // high, medium, low
  final String dueDate;
  final IconData icon;
  final Color color;

  const MaintenanceItem({
    required this.title,
    required this.description,
    required this.priority,
    required this.dueDate,
    required this.icon,
    required this.color,
  });

  static List<MaintenanceItem> mockMaintenance = [
    MaintenanceItem(
      title: 'MQ-4 Sensor Calibration',
      description: 'Methane sensor calibration drift detected. Recommended recalibration within 48 hours.',
      priority: 'high',
      dueDate: '2026-06-14',
      icon: Icons.gas_meter,
      color: const Color(0xFFBA1A1A),
    ),
    MaintenanceItem(
      title: 'Pressure Sensor Maintenance',
      description: 'BMP280 scheduled maintenance. Check seals and replace if noise exceeds threshold.',
      priority: 'medium',
      dueDate: '2026-06-20',
      icon: Icons.speed,
      color: const Color(0xFFF57F17),
    ),
    MaintenanceItem(
      title: 'Methane Sensor Cleaning',
      description: 'MQ-4 sensor surface requires cleaning to maintain accuracy. Dust accumulation detected.',
      priority: 'medium',
      dueDate: '2026-06-22',
      icon: Icons.cleaning_services,
      color: const Color(0xFFF57F17),
    ),
    MaintenanceItem(
      title: 'ESP8266 Diagnostics',
      description: 'Scheduled firmware update and diagnostic check. CPU temperature trending upward.',
      priority: 'low',
      dueDate: '2026-07-01',
      icon: Icons.memory,
      color: const Color(0xFF1B5E20),
    ),
    MaintenanceItem(
      title: 'Slurry Level Sensor Check',
      description: 'HC-SR04 ultrasonic sensor battery critically low. Replace battery module.',
      priority: 'high',
      dueDate: '2026-06-13',
      icon: Icons.height,
      color: const Color(0xFFBA1A1A),
    ),
  ];
}

/// Biogas production data for charts.
class ProductionData {
  final String period;
  final double production;
  final double efficiency;

  const ProductionData({
    required this.period,
    required this.production,
    required this.efficiency,
  });

  static List<ProductionData> weeklyData = [
    const ProductionData(period: 'Mon', production: 11.2, efficiency: 74),
    const ProductionData(period: 'Tue', production: 12.8, efficiency: 78),
    const ProductionData(period: 'Wed', production: 11.5, efficiency: 72),
    const ProductionData(period: 'Thu', production: 13.2, efficiency: 81),
    const ProductionData(period: 'Fri', production: 12.1, efficiency: 76),
    const ProductionData(period: 'Sat', production: 13.8, efficiency: 82),
    const ProductionData(period: 'Sun', production: 12.5, efficiency: 78),
  ];

  static List<ProductionData> monthlyData = [
    const ProductionData(period: 'W1', production: 82.0, efficiency: 75),
    const ProductionData(period: 'W2', production: 87.5, efficiency: 78),
    const ProductionData(period: 'W3', production: 91.2, efficiency: 80),
    const ProductionData(period: 'W4', production: 85.0, efficiency: 77),
  ];

  static List<ProductionData> yearlyData = [
    const ProductionData(period: 'Jan', production: 345, efficiency: 72),
    const ProductionData(period: 'Feb', production: 362, efficiency: 74),
    const ProductionData(period: 'Mar', production: 380, efficiency: 76),
    const ProductionData(period: 'Apr', production: 372, efficiency: 75),
    const ProductionData(period: 'May', production: 395, efficiency: 78),
    const ProductionData(period: 'Jun', production: 375, efficiency: 77),
    const ProductionData(period: 'Jul', production: 410, efficiency: 80),
    const ProductionData(period: 'Aug', production: 398, efficiency: 79),
    const ProductionData(period: 'Sep', production: 385, efficiency: 78),
    const ProductionData(period: 'Oct', production: 390, efficiency: 78),
    const ProductionData(period: 'Nov', production: 370, efficiency: 76),
    const ProductionData(period: 'Dec', production: 380, efficiency: 77),
  ];
}

/// Feeding schedule for the biodigester.
class FeedingSchedule {
  final String time;
  final String type;
  final double amount; // kg
  final String status;

  const FeedingSchedule({
    required this.time,
    required this.type,
    required this.amount,
    required this.status,
  });

  static List<FeedingSchedule> mockSchedule = [
    const FeedingSchedule(time: '06:00', type: 'Bouse de vache', amount: 250, status: 'completed'),
    const FeedingSchedule(time: '09:00', type: 'Déchets organiques', amount: 150, status: 'completed'),
    const FeedingSchedule(time: '12:00', type: 'Lisier de porc', amount: 200, status: 'completed'),
    const FeedingSchedule(time: '15:00', type: 'Résidus agricoles', amount: 100, status: 'in_progress'),
    const FeedingSchedule(time: '18:00', type: 'Bouse de vache', amount: 250, status: 'pending'),
  ];
}
