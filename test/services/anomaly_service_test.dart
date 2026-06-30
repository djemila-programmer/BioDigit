import 'package:biodigit_app/services/anomaly_service.dart';
import 'package:biodigit_app/services/sensor_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AnomalyService', () {
    final service = AnomalyService();

    test('analyzes a normal reading as healthy', () {
      final report = service.analyze(
        SensorReading(
          temperature: 35,
          pressure: 1.05,
          methane: 320,
          slurryLevel: 70,
          timestamp: DateTime.now(),
        ),
      );

      expect(report.healthScore, 100);
      expect(report.riskScore, 0);
      expect(report.severityLevel, 'Faible');
      expect(report.sensorAnomalies, 0);
      expect(report.predictionConfidence, 98.5);
      expect(report.sensorResults, hasLength(4));
      expect(
        report.sensorResults.every((result) => result.severity == 'normal'),
        isTrue,
      );
      expect(
        report.sensorResults.every((result) => result.isAnomaly == false),
        isTrue,
      );
      expect(report.recommendedActions, greaterThanOrEqualTo(1));
      expect(
        report.actions.any(
          (action) =>
              action.title == 'Calibration périodique des capteurs' &&
              action.priority == 'Basse',
        ),
        isTrue,
      );
    });

    test('single critical reading affects scores and actions', () {
      final report = service.analyze(
        SensorReading(
          temperature: 45,
          pressure: 1.05,
          methane: 320,
          slurryLevel: 70,
          timestamp: DateTime.now(),
        ),
      );

      final temperatureResult = report.sensorResults.firstWhere(
        (result) => result.sensorId == 'DS18B20',
      );

      expect(temperatureResult.severity, 'critical');
      expect(temperatureResult.status, 'Critique');
      expect(temperatureResult.isAnomaly, isTrue);
      expect(report.severityLevel, 'Critique');
      expect(report.healthScore, 75);
      expect(report.riskScore, 35);
      expect(
        report.actions.any(
          (action) =>
              action.priority == 'Haute' &&
              action.title.contains('température'),
        ),
        isTrue,
      );
    });

    test('single warning reading yields moderate severity', () {
      final report = service.analyze(
        SensorReading(
          temperature: 39,
          pressure: 1.05,
          methane: 320,
          slurryLevel: 70,
          timestamp: DateTime.now(),
        ),
      );

      final temperatureResult = report.sensorResults.firstWhere(
        (result) => result.sensorId == 'DS18B20',
      );

      expect(temperatureResult.severity, 'warning');
      expect(report.severityLevel, 'Modéré');
      expect(report.healthScore, 90);
      expect(
        report.actions.any((action) => action.priority == 'Moyenne'),
        isTrue,
      );
    });

    test('two warnings escalate to elevated severity', () {
      final report = service.analyze(
        SensorReading(
          temperature: 39,
          pressure: 1.05,
          methane: 460,
          slurryLevel: 70,
          timestamp: DateTime.now(),
        ),
      );

      expect(report.severityLevel, 'Élevé');
    });

    test('multiple critical readings clamp scores', () {
      final report = service.analyze(
        SensorReading(
          temperature: 50,
          pressure: 2.0,
          methane: 600,
          slurryLevel: 95,
          timestamp: DateTime.now(),
        ),
      );

      expect(report.healthScore, 0);
      expect(report.riskScore, 100);
    });

    test('prediction confidence reflects reading age', () {
      final twoMinutesAgo = service.analyze(
        SensorReading(
          temperature: 35,
          pressure: 1.05,
          methane: 320,
          slurryLevel: 70,
          timestamp: DateTime.now().subtract(const Duration(minutes: 2)),
        ),
      );

      final tenMinutesAgo = service.analyze(
        SensorReading(
          temperature: 35,
          pressure: 1.05,
          methane: 320,
          slurryLevel: 70,
          timestamp: DateTime.now().subtract(const Duration(minutes: 10)),
        ),
      );

      expect(twoMinutesAgo.predictionConfidence, 85.0);
      expect(tenMinutesAgo.predictionConfidence, 70.0);
    });
  });
}
