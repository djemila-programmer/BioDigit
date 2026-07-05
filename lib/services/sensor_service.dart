import 'dart:async';
import '../supabase.dart';

/// Real-time sensor data service.
/// Reads live sensor data pushed by ESP32 to Supabase Realtime.
class SensorService {
  // ─── Real-Time Sensor Stream from Supabase Realtime ─────────────────────

  /// Live stream of all sensor readings from ESP32.
  Stream<SensorReading> sensorDataStream() {
    return supabase
        .from('sensor_readings')
        .stream(primaryKey: ['id'])
        .map((rows) {
          if (rows.isEmpty) return SensorReading.empty();
          final latest = rows.last;
          return SensorReading.fromSupabase(latest);
        });
  }

  /// Live stream for a single sensor type.
  Stream<double> singleSensorStream(String sensorKey) {
    return supabase
        .from('sensor_readings')
        .stream(primaryKey: ['id'])
        .map((rows) {
          if (rows.isEmpty) return 0.0;
          final latest = rows.last;
          return (latest[sensorKey] as num?)?.toDouble() ?? 0.0;
        });
  }

  /// ESP32 controller status stream from Supabase Realtime.
  Stream<Esp32StatusData> esp32StatusStream() {
    return supabase
        .from('esp32_status')
        .stream(primaryKey: ['id'])
        .map((rows) {
          if (rows.isEmpty) return Esp32StatusData.disconnected();
          final latest = rows.last;
          return Esp32StatusData.fromSupabase(latest);
        });
  }

  /// One-shot read of all current sensor values.
  Future<SensorReading> getCurrentReadings() async {
    try {
      final response = await supabase
          .from('sensor_readings')
          .select()
          .order('created_at', ascending: false)
          .limit(1)
          .maybeSingle();
      if (response == null) return SensorReading.empty();
      return SensorReading.fromSupabase(response);
    } catch (e) {
      return SensorReading.empty();
    }
  }

  /// One-shot read of ESP32 status.
  Future<Esp32StatusData> getEsp32Status() async {
    try {
      final response = await supabase
          .from('esp32_status')
          .select()
          .order('created_at', ascending: false)
          .limit(1)
          .maybeSingle();
      if (response == null) return Esp32StatusData.disconnected();
      return Esp32StatusData.fromSupabase(response);
    } catch (e) {
      return Esp32StatusData.disconnected();
    }
  }

  // ─── Threshold Configuration (Supabase) ──────────────────────────────────

  Future<Map<String, dynamic>> getThresholdConfig() async {
    try {
      final response = await supabase
          .from('config')
          .select()
          .eq('key', 'thresholds')
          .maybeSingle();
      if (response != null) {
        return response['value'] as Map<String, dynamic>;
      }
    } catch (_) {}
    return {
      'temperature': {'min': 25.0, 'max': 40.0, 'unit': '°C'},
      'pressure': {'min': 0.8, 'max': 1.5, 'unit': 'bar'},
      'methane': {'min': 150.0, 'max': 500.0, 'unit': 'ppm'},
      'slurryLevel': {'min': 20.0, 'max': 90.0, 'unit': '%'},
    };
  }

  Future<void> saveThresholdConfig(Map<String, dynamic> config) async {
    await supabase.from('config').upsert({
      'key': 'thresholds',
      'value': config,
    });
  }

  // ─── Sensor Health (Supabase) ────────────────────────────────────────────

  Future<List<SensorHealthRecord>> getSensorHealthRecords() async {
    try {
      final response = await supabase.from('sensor_health').select();
      return response.map((row) => SensorHealthRecord.fromSupabase(row)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> updateSensorHealth(String sensorId, Map<String, dynamic> data) async {
    await supabase.from('sensor_health').upsert({
      'id': sensorId,
      ...data,
    });
  }
}

// ─── Data Classes ──────────────────────────────────────────────────────────

/// Represents a complete set of sensor readings from the ESP32.
class SensorReading {
  final double temperature;
  final double pressure;
  final double methane;
  final double slurryLevel;
  final DateTime timestamp;
  final String? temperatureTrend;
  final String? pressureTrend;
  final String? methaneTrend;
  final String? slurryTrend;

  const SensorReading({
    required this.temperature,
    required this.pressure,
    required this.methane,
    required this.slurryLevel,
    required this.timestamp,
    this.temperatureTrend,
    this.pressureTrend,
    this.methaneTrend,
    this.slurryTrend,
  });

  factory SensorReading.empty() => SensorReading(
        temperature: 0,
        pressure: 0,
        methane: 0,
        slurryLevel: 0,
        timestamp: DateTime.now(),
      );

  factory SensorReading.fromSupabase(Map<String, dynamic> data) {
    return SensorReading(
      temperature: (data['temperature'] as num?)?.toDouble() ?? 0.0,
      pressure: (data['pressure'] as num?)?.toDouble() ?? 0.0,
      methane: (data['methane'] as num?)?.toDouble() ?? 0.0,
      slurryLevel: (data['slurry_level'] as num?)?.toDouble() ?? 0.0,
      timestamp: data['created_at'] != null
          ? DateTime.tryParse(data['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
      temperatureTrend: data['temperature_trend']?.toString(),
      pressureTrend: data['pressure_trend']?.toString(),
      methaneTrend: data['methane_trend']?.toString(),
      slurryTrend: data['slurry_trend']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'temperature': temperature,
        'pressure': pressure,
        'methane': methane,
        'slurry_level': slurryLevel,
        'temperature_trend': temperatureTrend,
        'pressure_trend': pressureTrend,
        'methane_trend': methaneTrend,
        'slurry_trend': slurryTrend,
        'timestamp': timestamp.toIso8601String(),
      };
}

/// ESP32 controller status data.
class Esp32StatusData {
  final bool connected;
  final int wifiSignal;
  final String firmwareVersion;
  final int batteryLevel;
  final String ipAddress;
  final DateTime? lastSync;
  final double cpuTemp;
  final String uptime;

  const Esp32StatusData({
    required this.connected,
    required this.wifiSignal,
    required this.firmwareVersion,
    required this.batteryLevel,
    required this.ipAddress,
    this.lastSync,
    required this.cpuTemp,
    required this.uptime,
  });

  factory Esp32StatusData.disconnected() => Esp32StatusData(
        connected: false,
        wifiSignal: 0,
        firmwareVersion: 'N/A',
        batteryLevel: 0,
        ipAddress: 'N/A',
        cpuTemp: 0,
        uptime: '0',
      );

  factory Esp32StatusData.fromSupabase(Map<String, dynamic> data) {
    return Esp32StatusData(
      connected: data['connected'] == true,
      wifiSignal: (data['wifi_signal'] as num?)?.toInt() ?? 0,
      firmwareVersion: data['firmware_version']?.toString() ?? 'N/A',
      batteryLevel: (data['battery_level'] as num?)?.toInt() ?? 0,
      ipAddress: data['ip_address']?.toString() ?? 'N/A',
      lastSync: data['last_sync'] != null
          ? DateTime.tryParse(data['last_sync'].toString())
          : null,
      cpuTemp: (data['cpu_temp'] as num?)?.toDouble() ?? 0,
      uptime: data['uptime']?.toString() ?? '0',
    );
  }
}

/// Sensor health record stored in Supabase.
class SensorHealthRecord {
  final String sensorId;
  final String sensorModel;
  final String status;
  final DateTime? lastCalibration;
  final DateTime? nextMaintenance;
  final int batteryLevel;
  final String signalQuality;

  const SensorHealthRecord({
    required this.sensorId,
    required this.sensorModel,
    required this.status,
    this.lastCalibration,
    this.nextMaintenance,
    required this.batteryLevel,
    required this.signalQuality,
  });

  factory SensorHealthRecord.fromSupabase(Map<String, dynamic> data) {
    return SensorHealthRecord(
      sensorId: data['id']?.toString() ?? '',
      sensorModel: data['sensor_model']?.toString() ?? '',
      status: data['status']?.toString() ?? 'unknown',
      lastCalibration: data['last_calibration'] != null
          ? DateTime.tryParse(data['last_calibration'].toString())
          : null,
      nextMaintenance: data['next_maintenance'] != null
          ? DateTime.tryParse(data['next_maintenance'].toString())
          : null,
      batteryLevel: (data['battery_level'] as num?)?.toInt() ?? 0,
      signalQuality: data['signal_quality']?.toString() ?? 'Unknown',
    );
  }
}
