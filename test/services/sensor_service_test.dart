import 'package:biodigit_app/services/sensor_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SensorReading', () {
    test('fromFirebase maps flat values and trends', () {
      final reading = SensorReading.fromFirebase(<dynamic, dynamic>{
        'temperature': 36.5,
        'pressure': 1.1,
        'methane': 315,
        'slurryLevel': 74,
        'timestamp': '2024-06-01T12:34:56.000Z',
        'temperatureTrend': 'up',
        'pressureTrend': 'stable',
        'methaneTrend': 'down',
        'slurryTrend': 'up',
      });

      expect(reading.temperature, 36.5);
      expect(reading.pressure, 1.1);
      expect(reading.methane, 315.0);
      expect(reading.slurryLevel, 74.0);
      expect(reading.timestamp, DateTime.parse('2024-06-01T12:34:56.000Z'));
      expect(reading.temperatureTrend, 'up');
      expect(reading.pressureTrend, 'stable');
      expect(reading.methaneTrend, 'down');
      expect(reading.slurryTrend, 'up');
    });

    test('fromFirebase extracts nested values and defaults missing values', () {
      final reading = SensorReading.fromFirebase(<dynamic, dynamic>{
        'temperature': <dynamic, dynamic>{'value': 38.4},
      });

      expect(reading.temperature, 38.4);
      expect(reading.pressure, 0.0);
      expect(reading.methane, 0.0);
      expect(reading.slurryLevel, 0.0);
      expect(reading.temperatureTrend, isNull);
      expect(reading.pressureTrend, isNull);
      expect(reading.methaneTrend, isNull);
      expect(reading.slurryTrend, isNull);
      expect(reading.timestamp, isA<DateTime>());
    });

    test('fromFirebase falls back on invalid or absent timestamps', () {
      final invalidTimestampReading = SensorReading.fromFirebase(
        <dynamic, dynamic>{
          'timestamp': 'not-a-date',
        },
      );
      final absentTimestampReading = SensorReading.fromFirebase(
        <dynamic, dynamic>{},
      );

      expect(invalidTimestampReading.timestamp, isA<DateTime>());
      expect(absentTimestampReading.timestamp, isA<DateTime>());
    });

    test('empty returns zeros for all readings', () {
      final reading = SensorReading.empty();

      expect(reading.temperature, 0.0);
      expect(reading.pressure, 0.0);
      expect(reading.methane, 0.0);
      expect(reading.slurryLevel, 0.0);
    });

    test('toJson includes all sensor keys and ISO timestamp', () {
      final timestamp = DateTime.parse('2024-06-01T12:34:56.000Z');
      final reading = SensorReading(
        temperature: 36.5,
        pressure: 1.1,
        methane: 315,
        slurryLevel: 74,
        timestamp: timestamp,
      );

      final json = reading.toJson();

      expect(json, containsPair('temperature', 36.5));
      expect(json, containsPair('pressure', 1.1));
      expect(json, containsPair('methane', 315.0));
      expect(json, containsPair('slurryLevel', 74.0));
      expect(json, containsPair('timestamp', timestamp.toIso8601String()));
    });
  });

  group('Esp32StatusData', () {
    test('fromFirebase applies defaults and parses lastSync', () {
      final status = Esp32StatusData.fromFirebase(<dynamic, dynamic>{
        'connected': true,
        'wifiSignal': -55,
        'firmwareVersion': 'v1.2.3',
        'batteryLevel': 92,
        'ipAddress': '192.168.1.10',
        'lastSync': '2024-06-01T12:34:56.000Z',
        'cpuTemp': 47.8,
        'uptime': '3d 4h',
      });

      expect(status.connected, isTrue);
      expect(status.wifiSignal, -55);
      expect(status.firmwareVersion, 'v1.2.3');
      expect(status.batteryLevel, 92);
      expect(status.ipAddress, '192.168.1.10');
      expect(status.lastSync, DateTime.parse('2024-06-01T12:34:56.000Z'));
      expect(status.cpuTemp, 47.8);
      expect(status.uptime, '3d 4h');
    });

    test('fromFirebase treats connected as true only for boolean true', () {
      final status = Esp32StatusData.fromFirebase(<dynamic, dynamic>{
        'connected': 'true',
      });

      expect(status.connected, isFalse);
      expect(status.wifiSignal, 0);
      expect(status.firmwareVersion, 'N/A');
      expect(status.batteryLevel, 0);
      expect(status.ipAddress, 'N/A');
      expect(status.uptime, '0');
      expect(status.cpuTemp, 0.0);
      expect(status.lastSync, isNull);
    });

    test('disconnected returns default offline values', () {
      final status = Esp32StatusData.disconnected();

      expect(status.connected, isFalse);
      expect(status.firmwareVersion, 'N/A');
      expect(status.ipAddress, 'N/A');
      expect(status.wifiSignal, 0);
      expect(status.batteryLevel, 0);
      expect(status.uptime, '0');
      expect(status.cpuTemp, 0.0);
      expect(status.lastSync, isNull);
    });
  });
}
