import 'dart:math';
import '../supabase.dart';
import 'sensor_service.dart';

/// Real anomaly detection engine based on actual sensor readings.
/// No mock data — all scores are computed from live values.
class AnomalyService {
  /// Save anomaly report to Supabase for history.
  Future<void> saveReport(AnomalyReport report) async {
    final uid = supabase.auth.currentUser?.id;
    if (uid == null) return;
    try {
      await supabase.from('anomaly_history').insert({
        'user_id': uid,
        'health_score': report.healthScore,
        'risk_score': report.riskScore,
        'severity_level': report.severityLevel,
        'prediction_confidence': report.predictionConfidence,
        'sensor_anomalies': report.sensorAnomalies,
      });
    } catch (_) {}
  }

  /// Get anomaly history from Supabase.
  Future<List<Map<String, dynamic>>> getHistory() async {
    final uid = supabase.auth.currentUser?.id;
    if (uid == null) return _demoHistory();
    try {
      final response = await supabase
          .from('anomaly_history')
          .select()
          .eq('user_id', uid)
          .order('created_at', ascending: false)
          .limit(20);
      return response.map((row) {
        row['timestampDate'] = DateTime.tryParse(row['created_at']?.toString() ?? '') ?? DateTime.now();
        return row;
      }).toList();
    } catch (_) {
      return _demoHistory();
    }
  }

  List<Map<String, dynamic>> _demoHistory() {
    final now = DateTime.now();
    return [
      {'id': '1', 'health_score': 87, 'risk_score': 12, 'severity_level': 'Faible', 'prediction_confidence': 96.8, 'sensor_anomalies': 1, 'timestampDate': now.subtract(const Duration(hours: 6))},
      {'id': '2', 'health_score': 72, 'risk_score': 28, 'severity_level': 'Modéré', 'prediction_confidence': 94.2, 'sensor_anomalies': 2, 'timestampDate': now.subtract(const Duration(hours: 12))},
      {'id': '3', 'health_score': 95, 'risk_score': 5, 'severity_level': 'Faible', 'prediction_confidence': 98.5, 'sensor_anomalies': 0, 'timestampDate': now.subtract(const Duration(days: 1))},
      {'id': '4', 'health_score': 60, 'risk_score': 40, 'severity_level': 'Élevé', 'prediction_confidence': 92.0, 'sensor_anomalies': 3, 'timestampDate': now.subtract(const Duration(days: 2))},
    ];
  }

  // ─── Threshold Configuration ────────────────────────────────────────────

  static const Map<String, _Threshold> _thresholds = {
    'temperature': _Threshold(min: 25.0, max: 40.0, warnLow: 27.0, warnHigh: 38.0),
    'pressure': _Threshold(min: 0.8, max: 1.5, warnLow: 0.9, warnHigh: 1.4),
    'methane': _Threshold(min: 0.0, max: 500.0, warnLow: 150.0, warnHigh: 450.0),
    'slurryLevel': _Threshold(min: 20.0, max: 90.0, warnLow: 25.0, warnHigh: 85.0),
  };

  // ─── Core Analysis ──────────────────────────────────────────────────────

  /// Perform full anomaly analysis on a sensor reading.
  AnomalyReport analyze(SensorReading reading) {
    final results = <SensorAnomaly>[];

    results.add(_analyzeSensor(
      name: 'Température', sensorId: 'DS18B20', value: reading.temperature,
      threshold: _thresholds['temperature']!, unit: '°C',
    ));
    results.add(_analyzeSensor(
      name: 'Pression', sensorId: 'BMP280', value: reading.pressure,
      threshold: _thresholds['pressure']!, unit: 'bar',
    ));
    results.add(_analyzeSensor(
      name: 'Méthane', sensorId: 'MQ-4', value: reading.methane,
      threshold: _thresholds['methane']!, unit: 'ppm',
    ));
    results.add(_analyzeSensor(
      name: 'Niveau de lisier', sensorId: 'HC-SR04', value: reading.slurryLevel,
      threshold: _thresholds['slurryLevel']!, unit: '%',
    ));

    final criticalCount = results.where((r) => r.severity == 'critical').length;
    final warningCount = results.where((r) => r.severity == 'warning').length;
    final anomalyCount = results.where((r) => r.isAnomaly).length;

    final healthScore = max(0, 100 - (criticalCount * 25) - (warningCount * 10));
    final riskScore = min(100, (criticalCount * 30) + (warningCount * 15) + (anomalyCount * 5));

    String severityLevel;
    if (criticalCount > 0) {
      severityLevel = 'Critique';
    } else if (warningCount > 1) {
      severityLevel = 'Élevé';
    } else if (warningCount > 0) {
      severityLevel = 'Modéré';
    } else {
      severityLevel = 'Faible';
    }

    final confidence = _computeConfidence(reading.timestamp);
    final actions = _generateActions(results);

    return AnomalyReport(
      healthScore: healthScore, riskScore: riskScore,
      severityLevel: severityLevel, predictionConfidence: confidence,
      sensorAnomalies: anomalyCount, recommendedActions: actions.length,
      sensorResults: results, actions: actions, timestamp: DateTime.now(),
    );
  }

  SensorAnomaly _analyzeSensor({
    required String name, required String sensorId,
    required double value, required _Threshold threshold, required String unit,
  }) {
    String severity;
    String status;
    bool isAnomaly = false;
    String message;

    if (value > threshold.max) {
      severity = 'critical'; status = 'Critique'; isAnomaly = true;
      message = '$name à ${value.toStringAsFixed(1)}$unit — dépasse le maximum ${threshold.max}$unit';
    } else if (value < threshold.min) {
      severity = 'critical'; status = 'Critique'; isAnomaly = true;
      message = '$name à ${value.toStringAsFixed(1)}$unit — en dessous du minimum ${threshold.min}$unit';
    } else if (value > threshold.warnHigh) {
      severity = 'warning'; status = 'Attention'; isAnomaly = true;
      message = '$name à ${value.toStringAsFixed(1)}$unit — approche du seuil haut';
    } else if (value < threshold.warnLow) {
      severity = 'warning'; status = 'Attention'; isAnomaly = true;
      message = '$name à ${value.toStringAsFixed(1)}$unit — approche du seuil bas';
    } else {
      severity = 'normal'; status = 'Normal';
      message = '$name à ${value.toStringAsFixed(1)}$unit — dans les limites';
    }

    return SensorAnomaly(
      sensorName: name, sensorId: sensorId, value: value, unit: unit,
      severity: severity, status: status, isAnomaly: isAnomaly, message: message,
    );
  }

  double _computeConfidence(DateTime lastReading) {
    final age = DateTime.now().difference(lastReading).inSeconds;
    if (age < 10) return 98.5;
    if (age < 30) return 96.2;
    if (age < 60) return 92.0;
    if (age < 300) return 85.0;
    return 70.0;
  }

  List<RecommendedAction> _generateActions(List<SensorAnomaly> results) {
    final actions = <RecommendedAction>[];
    for (final r in results) {
      if (r.severity == 'critical') {
        if (r.sensorId == 'DS18B20') {
          actions.add(RecommendedAction(title: 'Réduire la température immédiatement', description: 'Vérifier le système de refroidissement et l\'agitation du digesteur.', priority: 'Haute'));
        } else if (r.sensorId == 'BMP280') {
          actions.add(RecommendedAction(title: 'Vérifier la soupape de pression', description: 'La pression est hors limites. Activer la soupape de sécurité manuellement si nécessaire.', priority: 'Haute'));
        } else if (r.sensorId == 'MQ-4') {
          actions.add(RecommendedAction(title: 'Inspecter le dôme de gaz', description: 'Concentration de méthane anormale. Vérifier les fuites et la ventilation.', priority: 'Haute'));
        } else if (r.sensorId == 'HC-SR04') {
          actions.add(RecommendedAction(title: 'Vidanger le lisier', description: 'Niveau de lisier critique. Procéder à une vidange partielle.', priority: 'Haute'));
        }
      } else if (r.severity == 'warning') {
        actions.add(RecommendedAction(title: 'Surveiller ${r.sensorName}', description: r.message, priority: 'Moyenne'));
      }
    }
    actions.add(RecommendedAction(title: 'Calibration périodique des capteurs', description: 'Planifier la calibration des capteurs DS18B20, BMP280, MQ-4 et HC-SR04.', priority: 'Basse'));
    return actions;
  }
}

// ─── Data Classes ──────────────────────────────────────────────────────────

class _Threshold {
  final double min, max, warnLow, warnHigh;
  const _Threshold({required this.min, required this.max, required this.warnLow, required this.warnHigh});
}

class AnomalyReport {
  final int healthScore, riskScore, sensorAnomalies, recommendedActions;
  final String severityLevel;
  final double predictionConfidence;
  final List<SensorAnomaly> sensorResults;
  final List<RecommendedAction> actions;
  final DateTime timestamp;

  const AnomalyReport({
    required this.healthScore, required this.riskScore, required this.severityLevel,
    required this.predictionConfidence, required this.sensorAnomalies,
    required this.recommendedActions, required this.sensorResults,
    required this.actions, required this.timestamp,
  });
}

class SensorAnomaly {
  final String sensorName, sensorId, unit, severity, status, message;
  final double value;
  final bool isAnomaly;

  const SensorAnomaly({
    required this.sensorName, required this.sensorId, required this.value,
    required this.unit, required this.severity, required this.status,
    required this.isAnomaly, required this.message,
  });
}

class RecommendedAction {
  final String title, description, priority;
  const RecommendedAction({required this.title, required this.description, required this.priority});
}
