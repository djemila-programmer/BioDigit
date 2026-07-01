import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../utils/severity_style.dart' as severity_style;
import 'firebase_service_mixin.dart';

/// Firestore-based alert service for smart alert management.
class AlertService with FirebaseServiceMixin {
  FirebaseFirestore? get _fs => firestoreOrNull;

  /// Stream of active alerts (real-time), ordered by timestamp descending.
  ///
  /// When Firebase is not configured, returns an empty stream (no mock data).
  Stream<List<SmartAlert>> alertsStream() {
    if (_fs == null) {
      return Stream.value(const <SmartAlert>[]);
    }
    return _fs!
        .collection('alerts')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => SmartAlert.fromFirestore(doc))
              .toList(),
        );
  }

  /// Get all active alerts (one-shot).
  ///
  /// When Firebase is not configured, returns an empty list (no mock data).
  Future<List<SmartAlert>> getAlerts({int limit = 50}) async {
    if (_fs == null) return const <SmartAlert>[];
    final snapshot = await _fs!
        .collection('alerts')
        .orderBy('timestamp', descending: true)
        .limit(limit)
        .get();
    return snapshot.docs.map((doc) => SmartAlert.fromFirestore(doc)).toList();
  }

  /// Get alerts by severity.
  ///
  /// When Firebase is not configured, returns an empty list (no mock data).
  Future<List<SmartAlert>> getAlertsBySeverity(String severity) async {
    if (_fs == null) return const <SmartAlert>[];
    final snapshot = await _fs!
        .collection('alerts')
        .where('severity', isEqualTo: severity)
        .orderBy('timestamp', descending: true)
        .get();
    return snapshot.docs.map((doc) => SmartAlert.fromFirestore(doc)).toList();
  }

  Future<String> createAlert({
    required String title,
    required String description,
    required String severity,
    required String sensorId,
    required String location,
  }) async {
    if (_fs == null) {
      throw StateError('Firebase non configuré');
    }

    final docRef = await _fs!.collection('alerts').add({
      'title': title,
      'description': description,
      'severity': severity,
      'sensorId': sensorId,
      'location': location,
      'timestamp': FieldValue.serverTimestamp(),
      'acknowledged': false,
      'resolved': false,
    });
    return docRef.id;
  }

  Future<void> acknowledgeAlert(String alertId) async {
    if (_fs == null) return;
    await _fs!.collection('alerts').doc(alertId).update({
      'acknowledged': true,
      'acknowledgedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> resolveAlert(String alertId) async {
    if (_fs == null) return;
    await _fs!.collection('alerts').doc(alertId).update({
      'resolved': true,
      'resolvedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<Map<String, int>> getAlertCounts() async {
    if (_fs == null) return {'critical': 0, 'warning': 0, 'info': 0};

    final snapshot = await _fs!
        .collection('alerts')
        .where('resolved', isEqualTo: false)
        .get();
    int critical = 0, warning = 0, info = 0;
    for (final doc in snapshot.docs) {
      final severity = doc['severity'] as String?;
      if (severity == 'critical') {
        critical++;
      } else if (severity == 'warning') {
        warning++;
      } else {
        info++;
      }
    }
    return {'critical': critical, 'warning': warning, 'info': info};
  }

  Future<void> generateAlertsFromReading({
    required double temperature,
    required double pressure,
    required double methane,
    required double slurryLevel,
  }) async {
    if (_fs == null) {
      // no Firebase: do not generate mock alerts
      return;
    }

    if (temperature > 40) {
      await createAlert(
        title: 'Température critique: ${temperature.toStringAsFixed(1)}°C',
        description: 'La température a dépassé le seuil maximum de 40°C.',
        severity: 'critical',
        sensorId: 'DS18B20',
        location: 'Chambre principale',
      );
    } else if (temperature < 25) {
      await createAlert(
        title: 'Température basse: ${temperature.toStringAsFixed(1)}°C',
        description: 'La température est en dessous du seuil minimum de 25°C.',
        severity: 'warning',
        sensorId: 'DS18B20',
        location: 'Chambre principale',
      );
    }
    if (pressure > 1.5) {
      await createAlert(
        title: 'Pression critique: ${pressure.toStringAsFixed(2)} bar',
        description:
            'La pression a dépassé 1.5 bar. Soupape de sécurité activée.',
        severity: 'critical',
        sensorId: 'BMP280',
        location: 'Biodigesteur principal',
      );
    } else if (pressure < 0.8) {
      await createAlert(
        title: 'Pression basse: ${pressure.toStringAsFixed(2)} bar',
        description: 'La pression est en dessous de 0.8 bar.',
        severity: 'warning',
        sensorId: 'BMP280',
        location: 'Biodigesteur principal',
      );
    }
    if (methane > 500) {
      await createAlert(
        title: 'Méthane élevé: ${methane.toStringAsFixed(0)} ppm',
        description:
            'Concentration de méthane au-dessus de 500 ppm. Risque de fuite.',
        severity: 'critical',
        sensorId: 'MQ-4',
        location: 'Dôme de gaz',
      );
    } else if (methane < 150) {
      await createAlert(
        title: 'Méthane bas: ${methane.toStringAsFixed(0)} ppm',
        description: 'Production de méthane insuffisante.',
        severity: 'warning',
        sensorId: 'MQ-4',
        location: 'Dôme de gaz',
      );
    }
    if (slurryLevel > 90) {
      await createAlert(
        title: 'Niveau de lisier critique: ${slurryLevel.toStringAsFixed(1)}%',
        description: 'Le niveau de lisier dépasse 90%. Vidange nécessaire.',
        severity: 'critical',
        sensorId: 'HC-SR04',
        location: 'Sortie de lisier',
      );
    } else if (slurryLevel < 20) {
      await createAlert(
        title: 'Niveau de lisier bas: ${slurryLevel.toStringAsFixed(1)}%',
        description: 'Le niveau de lisier est en dessous de 20%.',
        severity: 'warning',
        sensorId: 'HC-SR04',
        location: 'Sortie de lisier',
      );
    }
  }
}

/// Firestore-backed smart alert model.
class SmartAlert {
  final String id;
  final String title;
  final String description;
  final String severity; // critical, warning, info
  final String sensorId;
  final String location;
  final DateTime? timestamp;
  final bool acknowledged;
  final bool resolved;

  const SmartAlert({
    required this.id,
    required this.title,
    required this.description,
    required this.severity,
    required this.sensorId,
    required this.location,
    this.timestamp,
    this.acknowledged = false,
    this.resolved = false,
  });

  factory SmartAlert.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    DateTime? ts;
    final rawTs = data['timestamp'];
    if (rawTs is Timestamp) {
      ts = rawTs.toDate();
    } else if (rawTs is String) {
      ts = DateTime.tryParse(rawTs);
    }

    return SmartAlert(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      severity: data['severity'] ?? 'info',
      sensorId: data['sensorId'] ?? '',
      location: data['location'] ?? '',
      timestamp: ts,
      acknowledged: data['acknowledged'] == true,
      resolved: data['resolved'] == true,
    );
  }

  Color get severityColor => severity_style.severityColor(severity);

  IconData get icon => severity_style.severityIcon(severity);

  String get timeAgo {
    if (timestamp == null) return '';
    final diff = DateTime.now().difference(timestamp!);
    if (diff.inMinutes < 1) return 'Maintenant';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    return '${diff.inDays}j';
  }
}
