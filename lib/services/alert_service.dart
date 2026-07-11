import 'package:flutter/material.dart';
import '../supabase.dart';

/// Supabase-based alert service for smart alert management.
class AlertService {
  /// Stream of active alerts (real-time), ordered by timestamp descending.
  Stream<List<SmartAlert>> alertsStream() {
    return supabase
        .from('alerts')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false)
        .map((rows) => rows.map((row) => SmartAlert.fromSupabase(row)).toList());
  }

  /// Get all active alerts (one-shot).
  Future<List<SmartAlert>> getAlerts({int limit = 50}) async {
    final response = await supabase
        .rpc('get_all_alerts')
        .order('created_at', ascending: false)
        .limit(limit);
    return response.map((row) => SmartAlert.fromSupabase(row)).toList();
  }

  /// Get alerts by severity.
  Future<List<SmartAlert>> getAlertsBySeverity(String severity) async {
    final response = await supabase
        .from('alerts')
        .select()
        .eq('severity', severity)
        .order('created_at', ascending: false);
    return response.map((row) => SmartAlert.fromSupabase(row)).toList();
  }

  Future<String> createAlert({
    required String title,
    required String message,
    required String severity,
    required String type,
  }) async {
    final uid = supabase.auth.currentUser?.id;
    final response = await supabase.from('alerts').insert({
      'user_id': uid,
      'title': title,
      'message': message,
      'type': type,
      'severity': severity,
      'acknowledged': false,
      'resolved': false,
    }).select('id').single();
    return response['id'] as String;
  }

  Future<void> acknowledgeAlert(String alertId) async {
    await supabase.from('alerts').update({
      'acknowledged': true,
    }).eq('id', alertId);
  }

  Future<void> resolveAlert(String alertId) async {
    await supabase.from('alerts').update({
      'resolved': true,
    }).eq('id', alertId);
  }

  Future<Map<String, int>> getAlertCounts() async {
    final response = await supabase
        .rpc('get_all_alerts');
    int critical = 0, warning = 0, info = 0;
    for (final row in response) {
      if (row['resolved'] == true) continue;
      final severity = row['severity'] as String?;
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
    if (temperature > 40) {
      await createAlert(
        title: 'Température critique: ${temperature.toStringAsFixed(1)}°C',
        message: 'La température a dépassé le seuil maximum de 40°C.',
        type: 'Température critique',
        severity: 'critical');
    } else if (temperature < 25) {
      await createAlert(
        title: 'Température basse: ${temperature.toStringAsFixed(1)}°C',
        message: 'La température est en dessous du seuil minimum de 25°C.',
        type: 'Température basse',
        severity: 'warning');
    }
    if (pressure > 1.5) {
      await createAlert(
        title: 'Pression critique: ${pressure.toStringAsFixed(2)} bar',
        message: 'La pression a dépassé 1.5 bar. Soupape de sécurité activée.',
        type: 'Pression critique',
        severity: 'critical');
    } else if (pressure < 0.8) {
      await createAlert(
        title: 'Pression basse: ${pressure.toStringAsFixed(2)} bar',
        message: 'La pression est en dessous de 0.8 bar.',
        type: 'Pression basse',
        severity: 'warning');
    }
    if (methane > 500) {
      await createAlert(
        title: 'Méthane élevé: ${methane.toStringAsFixed(0)} ppm',
        message: 'Concentration de méthane au-dessus de 500 ppm. Risque de fuite.',
        type: 'Méthane élevé',
        severity: 'critical');
    } else if (methane > 150) {
      await createAlert(
        title: 'Méthane en production: ${methane.toStringAsFixed(0)} ppm',
        message: 'Production de méthane détectée.',
        type: 'Méthane en production',
        severity: 'info');
    }
    if (slurryLevel > 90) {
      await createAlert(
        title: 'Niveau de lisier critique: ${slurryLevel.toStringAsFixed(1)}%',
        message: 'Le niveau de lisier dépasse 90%. Vidange nécessaire.',
        type: 'Lisier critique',
        severity: 'critical');
    } else if (slurryLevel < 20) {
      await createAlert(
        title: 'Niveau de lisier bas: ${slurryLevel.toStringAsFixed(1)}%',
        message: 'Le niveau de lisier est en dessous de 20%.',
        type: 'Lisier bas',
        severity: 'warning');
    }
  }
}

/// Supabase-backed smart alert model.
class SmartAlert {
  final String id;
  final String title;
  final String message;
  final String type;
  final String severity;
  final DateTime? timestamp;
  final bool acknowledged;
  final bool resolved;

  const SmartAlert({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.severity,
    this.timestamp,
    this.acknowledged = false,
    this.resolved = false,
  });

  factory SmartAlert.fromSupabase(Map<String, dynamic> data) {
    return SmartAlert(
      id: data['id']?.toString() ?? '',
      title: data['title']?.toString() ?? '',
      message: data['message']?.toString() ?? '',
      type: data['type']?.toString() ?? '',
      severity: data['severity']?.toString() ?? 'info',
      timestamp: data['created_at'] != null
          ? DateTime.tryParse(data['created_at'].toString())
          : null,
      acknowledged: data['acknowledged'] == true,
      resolved: data['resolved'] == true,
    );
  }

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

  IconData get icon {
    switch (severity) {
      case 'critical':
        return Icons.error;
      case 'warning':
        return Icons.warning;
      default:
        return Icons.info;
    }
  }

  String get timeAgo {
    if (timestamp == null) return '';
    final diff = DateTime.now().difference(timestamp!);
    if (diff.inMinutes < 1) return 'Maintenant';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    return '${diff.inDays}j';
  }
}
