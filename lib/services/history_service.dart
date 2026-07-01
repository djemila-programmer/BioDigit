import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_service_mixin.dart';
import 'sensor_service.dart';

/// Historical data service: automatic logging and chart data retrieval.
class HistoryService with FirebaseServiceMixin {
  FirebaseFirestore? get _fs => firestoreOrNull;

  FirebaseAuth? get _authInst => authOrNull;

  String? get _uid =>
      _authInst?.currentUser?.uid ?? (authOrNull == null ? 'demo-user' : null);

  // ─── Automatic Data Logging ─────────────────────────────────────────────

  Future<void> logReading(SensorReading reading) async {
    if (_uid == null || _fs == null) return;
    await _fs!.collection('history').doc(_uid).collection('readings').add({
      'temperature': reading.temperature, 'pressure': reading.pressure,
      'methane': reading.methane, 'slurryLevel': reading.slurryLevel,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  // ─── Chart Data Retrieval ───────────────────────────────────────────────

  Future<List<HistoryPoint>> getLast24Hours() async {
    if (_fs == null) return _demoData(24, const Duration(hours: 1));
    return _getReadingsSince(DateTime.now().subtract(const Duration(hours: 24)));
  }

  Future<List<HistoryPoint>> getLast7Days() async {
    if (_fs == null) return _demoData(7, const Duration(days: 1));
    return _getReadingsSince(DateTime.now().subtract(const Duration(days: 7)));
  }

  Future<List<HistoryPoint>> getLast30Days() async {
    if (_fs == null) return _demoData(30, const Duration(days: 1));
    return _getReadingsSince(DateTime.now().subtract(const Duration(days: 30)));
  }

  Future<List<HistoryPoint>> getLast12Months() async {
    if (_fs == null) return _demoData(12, const Duration(days: 30));
    return _getReadingsSince(DateTime.now().subtract(const Duration(days: 365)));
  }

  Future<List<HistoryPoint>> _getReadingsSince(DateTime since) async {
    if (_uid == null || _fs == null) return [];
    final snapshot = await _fs!.collection('history').doc(_uid).collection('readings')
        .where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(since))
        .orderBy('timestamp').get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      DateTime ts = DateTime.now();
      final rawTs = data['timestamp'];
      if (rawTs is Timestamp) ts = rawTs.toDate();
      return HistoryPoint(
        timestamp: ts,
        temperature: (data['temperature'] as num?)?.toDouble() ?? 0,
        pressure: (data['pressure'] as num?)?.toDouble() ?? 0,
        methane: (data['methane'] as num?)?.toDouble() ?? 0,
        slurryLevel: (data['slurryLevel'] as num?)?.toDouble() ?? 0,
      );
    }).toList();
  }

  // ─── Production Aggregation ─────────────────────────────────────────────

  Future<ProductionSummary> getProductionSummary(String period) async {
    if (_fs == null || _uid == null) {
      return ProductionSummary(
        volume: 87.5, efficiency: 78.2, energyGenerated: 525.0,
        co2Reduction: 2.19, readingCount: 168, period: period,
      );
    }
    DateTime since;
    switch (period) {
      case 'daily': since = DateTime.now().subtract(const Duration(days: 1)); break;
      case 'weekly': since = DateTime.now().subtract(const Duration(days: 7)); break;
      case 'monthly': since = DateTime.now().subtract(const Duration(days: 30)); break;
      case 'annual': since = DateTime.now().subtract(const Duration(days: 365)); break;
      default: since = DateTime.now().subtract(const Duration(days: 7));
    }
    final snapshot = await _fs!.collection('history').doc(_uid).collection('readings')
        .where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(since)).get();
    if (snapshot.docs.isEmpty) return ProductionSummary.empty();
    double totalMethane = 0, avgTemp = 0;
    int count = snapshot.docs.length;
    for (final doc in snapshot.docs) {
      totalMethane += (doc['methane'] as num?)?.toDouble() ?? 0;
      avgTemp += (doc['temperature'] as num?)?.toDouble() ?? 0;
    }
    avgTemp /= count;
    final avgMethane = totalMethane / count;
    final mult = period == 'annual' ? 365 : period == 'monthly' ? 30 : period == 'weekly' ? 7 : 1;
    final estimatedProduction = (avgMethane / 100) * 2.4 * mult;
    final efficiency = (avgTemp >= 25 && avgTemp <= 40) ? 78.0 + (avgTemp - 30) * 0.8 : 50.0;
    final energy = estimatedProduction * 6.0;
    final co2 = estimatedProduction * 0.025;
    return ProductionSummary(
      volume: double.parse(estimatedProduction.toStringAsFixed(1)),
      efficiency: double.parse(efficiency.toStringAsFixed(1)),
      energyGenerated: double.parse(energy.toStringAsFixed(1)),
      co2Reduction: double.parse(co2.toStringAsFixed(2)),
      readingCount: count, period: period,
    );
  }

  List<HistoryPoint> _demoData(int count, Duration interval) {
    final now = DateTime.now();
    return List.generate(count, (i) {
      final t = now.subtract(interval * (count - i));
      return HistoryPoint(
        timestamp: t,
        temperature: 35.0 + (i % 7) * 0.8,
        pressure: 1.02 + (i % 5) * 0.015,
        methane: 290 + (i % 9) * 15.0,
        slurryLevel: 68 + (i % 6) * 3.0,
      );
    });
  }
}

// ─── Data Classes ──────────────────────────────────────────────────────────

class HistoryPoint {
  final DateTime timestamp;
  final double temperature;
  final double pressure;
  final double methane;
  final double slurryLevel;

  const HistoryPoint({
    required this.timestamp,
    required this.temperature,
    required this.pressure,
    required this.methane,
    required this.slurryLevel,
  });
}

class ProductionSummary {
  final double volume; // m³
  final double efficiency; // %
  final double energyGenerated; // kWh
  final double co2Reduction; // tons
  final int readingCount;
  final String period;

  const ProductionSummary({
    required this.volume,
    required this.efficiency,
    required this.energyGenerated,
    required this.co2Reduction,
    required this.readingCount,
    required this.period,
  });

  factory ProductionSummary.empty() => const ProductionSummary(
    volume: 0, efficiency: 0, energyGenerated: 0,
    co2Reduction: 0, readingCount: 0, period: 'daily',
  );
}
