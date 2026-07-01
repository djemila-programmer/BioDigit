import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_service_mixin.dart';

/// Real-time sensor data service.
/// Reads live sensor data pushed by ESP32 to Firebase Realtime Database.
class SensorService with FirebaseServiceMixin {
  DatabaseReference? _rtDb;

  DatabaseReference? get _dbRef {
    if (firestoreOrNull == null) return null;
    _rtDb ??= FirebaseDatabase.instance.ref();
    return _rtDb;
  }

  FirebaseFirestore? get _fs => firestoreOrNull;

  // ─── Real-Time Sensor Stream from Firebase RTDB ─────────────────────────

  /// Live stream of all sensor readings from ESP32.
  Stream<SensorReading> sensorDataStream() {
    if (_dbRef == null) {
      // Demo mode: emit realistic mock data every 3 seconds
      return Stream.periodic(const Duration(seconds: 3), (i) {
        return SensorReading(
          temperature: 35.5 + (i % 5) * 0.4,
          pressure: 1.05 + (i % 3) * 0.02,
          methane: 310 + (i % 7) * 12.0,
          slurryLevel: 72 + (i % 4) * 2.0,
          timestamp: DateTime.now(),
          temperatureTrend: i % 2 == 0 ? 'up' : 'stable',
          pressureTrend: 'stable',
          methaneTrend: i % 3 == 0 ? 'up' : 'down',
          slurryTrend: 'stable',
        );
      });
    }
    return _dbRef!.child('sensors').onValue.map((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data == null) return SensorReading.empty();
      return SensorReading.fromFirebase(data);
    });
  }

  /// Live stream for a single sensor type.
  Stream<double> singleSensorStream(String sensorKey) {
    if (_dbRef == null) {
      return Stream.periodic(const Duration(seconds: 3), (i) => 35.0 + i % 5);
    }
    return _dbRef!.child('sensors/$sensorKey/value').onValue.map((event) {
      final val = event.snapshot.value;
      if (val == null) return 0.0;
      return (val as num).toDouble();
    });
  }

  /// ESP32 controller status stream from RTDB.
  Stream<Esp32StatusData> esp32StatusStream() {
    if (_dbRef == null) {
      return Stream.periodic(const Duration(seconds: 5), (_) {
        return Esp32StatusData(
          connected: true, wifiSignal: -42, firmwareVersion: 'v2.4.1-bf',
          batteryLevel: 87, ipAddress: '192.168.1.105',
          lastSync: DateTime.now(), cpuTemp: 45.2, uptime: '3d 14h',
        );
      });
    }
    return _dbRef!.child('esp32').onValue.map((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data == null) return Esp32StatusData.disconnected();
      return Esp32StatusData.fromFirebase(data);
    });
  }

  /// One-shot read of all current sensor values.
  Future<SensorReading> getCurrentReadings() async {
    if (_dbRef == null) {
      return SensorReading(
        temperature: 36.8, pressure: 1.08, methane: 325,
        slurryLevel: 75, timestamp: DateTime.now(),
      );
    }
    final snapshot = await _dbRef!.child('sensors').get();
    final data = snapshot.value as Map<dynamic, dynamic>?;
    if (data == null) return SensorReading.empty();
    return SensorReading.fromFirebase(data);
  }

  /// One-shot read of ESP32 status.
  Future<Esp32StatusData> getEsp32Status() async {
    if (_dbRef == null) {
      return Esp32StatusData(
        connected: true, wifiSignal: -42, firmwareVersion: 'v2.4.1-bf',
        batteryLevel: 87, ipAddress: '192.168.1.105',
        lastSync: DateTime.now(), cpuTemp: 45.2, uptime: '3d 14h',
      );
    }
    final snapshot = await _dbRef!.child('esp32').get();
    final data = snapshot.value as Map<dynamic, dynamic>?;
    if (data == null) return Esp32StatusData.disconnected();
    return Esp32StatusData.fromFirebase(data);
  }

  // ─── Threshold Configuration (Firestore) ────────────────────────────────

  Future<Map<String, dynamic>> getThresholdConfig() async {
    try {
      if (_fs != null) {
        final doc = await _fs!.collection('config').doc('thresholds').get();
        if (doc.exists) return doc.data()!;
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
    if (_fs == null) return;
    await _fs!.collection('config').doc('thresholds').set(config);
  }

  // ─── Sensor Health (Firestore) ──────────────────────────────────────────

  Future<List<SensorHealthRecord>> getSensorHealthRecords() async {
    if (_fs == null) return [];
    final snapshot = await _fs!.collection('sensorHealth').get();
    return snapshot.docs.map((doc) => SensorHealthRecord.fromFirestore(doc)).toList();
  }

  Future<void> updateSensorHealth(String sensorId, Map<String, dynamic> data) async {
    if (_fs == null) return;
    await _fs!.collection('sensorHealth').doc(sensorId).set(data, SetOptions(merge: true));
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
    temperature: 0, pressure: 0, methane: 0, slurryLevel: 0,
    timestamp: DateTime.now(),
  );

  factory SensorReading.fromFirebase(Map<dynamic, dynamic> data) {
    return SensorReading(
      temperature: _extractValue(data, 'temperature'),
      pressure: _extractValue(data, 'pressure'),
      methane: _extractValue(data, 'methane'),
      slurryLevel: _extractValue(data, 'slurryLevel'),
      timestamp: data['timestamp'] != null
          ? DateTime.tryParse(data['timestamp'].toString()) ?? DateTime.now()
          : DateTime.now(),
      temperatureTrend: data['temperatureTrend']?.toString(),
      pressureTrend: data['pressureTrend']?.toString(),
      methaneTrend: data['methaneTrend']?.toString(),
      slurryTrend: data['slurryTrend']?.toString(),
    );
  }

  static double _extractValue(Map<dynamic, dynamic> data, String key) {
    final raw = data[key];
    if (raw == null) return 0.0;
    if (raw is Map) {
      return (raw['value'] as num?)?.toDouble() ?? 0.0;
    }
    return (raw as num?)?.toDouble() ?? 0.0;
  }

  Map<String, dynamic> toJson() => {
    'temperature': temperature,
    'pressure': pressure,
    'methane': methane,
    'slurryLevel': slurryLevel,
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
    connected: false, wifiSignal: 0, firmwareVersion: 'N/A',
    batteryLevel: 0, ipAddress: 'N/A', cpuTemp: 0, uptime: '0',
  );

  factory Esp32StatusData.fromFirebase(Map<dynamic, dynamic> data) {
    return Esp32StatusData(
      connected: data['connected'] == true,
      wifiSignal: (data['wifiSignal'] as num?)?.toInt() ?? 0,
      firmwareVersion: data['firmwareVersion']?.toString() ?? 'N/A',
      batteryLevel: (data['batteryLevel'] as num?)?.toInt() ?? 0,
      ipAddress: data['ipAddress']?.toString() ?? 'N/A',
      lastSync: data['lastSync'] != null
          ? DateTime.tryParse(data['lastSync'].toString())
          : null,
      cpuTemp: (data['cpuTemp'] as num?)?.toDouble() ?? 0,
      uptime: data['uptime']?.toString() ?? '0',
    );
  }
}

/// Sensor health record stored in Firestore.
class SensorHealthRecord {
  final String sensorId;
  final String sensorModel;
  final String status; // active, warning, critical, offline
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

  factory SensorHealthRecord.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return SensorHealthRecord(
      sensorId: doc.id,
      sensorModel: data['sensorModel'] ?? '',
      status: data['status'] ?? 'unknown',
      lastCalibration: data['lastCalibration'] != null
          ? DateTime.tryParse(data['lastCalibration'])
          : null,
      nextMaintenance: data['nextMaintenance'] != null
          ? DateTime.tryParse(data['nextMaintenance'])
          : null,
      batteryLevel: (data['batteryLevel'] as num?)?.toInt() ?? 0,
      signalQuality: data['signalQuality'] ?? 'Unknown',
    );
  }
}
