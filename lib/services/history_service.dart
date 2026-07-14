import '../supabase.dart';
import 'sensor_service.dart';

/// Historical data service: automatic logging and chart data retrieval.
class HistoryService {
  String? get _uid => supabase.auth.currentUser?.id;

  // ─── Automatic Data Logging ─────────────────────────────────────────────

  Future<void> logReading(SensorReading reading) async {
    if (_uid == null) return;
    await supabase.from('history_readings').insert({
      'user_id': _uid,
      'temperature': reading.temperature,
      'pressure': reading.pressure,
      'methane': reading.methane,
      'slurry_level': reading.slurryLevel,
    });
  }

  // ─── Chart Data Retrieval ───────────────────────────────────────────────

  Future<List<HistoryPoint>> getLast24Hours() async {
    if (_uid == null) return [];
    return _getReadingsSince(DateTime.now().subtract(const Duration(hours: 24)));
  }

  Future<List<HistoryPoint>> getLast7Days() async {
    if (_uid == null) return [];
    return _getReadingsSince(DateTime.now().subtract(const Duration(days: 7)));
  }

  Future<List<HistoryPoint>> getLast30Days() async {
    if (_uid == null) return [];
    return _getReadingsSince(DateTime.now().subtract(const Duration(days: 30)));
  }

  Future<List<HistoryPoint>> getLast12Months() async {
    if (_uid == null) return [];
    return _getReadingsSince(DateTime.now().subtract(const Duration(days: 365)));
  }

  Future<List<HistoryPoint>> _getReadingsSince(DateTime since) async {
    if (_uid == null) return [];
    final response = await supabase
        .from('history_readings')
        .select()
        .eq('user_id', _uid!)
        .gte('created_at', since.toIso8601String())
        .order('created_at');
    return response.map((row) {
      return HistoryPoint(
        timestamp: DateTime.tryParse(row['created_at']?.toString() ?? '') ?? DateTime.now(),
        temperature: (row['temperature'] as num?)?.toDouble() ?? 0,
        pressure: (row['pressure'] as num?)?.toDouble() ?? 0,
        methane: (row['methane'] as num?)?.toDouble() ?? 0,
        slurryLevel: (row['slurry_level'] as num?)?.toDouble() ?? 0,
      );
    }).toList();
  }

  // ─── Production Aggregation ─────────────────────────────────────────────

  Future<ProductionSummary> getProductionSummary(String period) async {
    if (_uid == null) return ProductionSummary.empty();
    DateTime since;
    switch (period) {
      case 'daily': since = DateTime.now().subtract(const Duration(days: 1)); break;
      case 'weekly': since = DateTime.now().subtract(const Duration(days: 7)); break;
      case 'monthly': since = DateTime.now().subtract(const Duration(days: 30)); break;
      case 'annual': since = DateTime.now().subtract(const Duration(days: 365)); break;
      default: since = DateTime.now().subtract(const Duration(days: 7));
    }
    final response = await supabase
        .from('history_readings')
        .select()
        .eq('user_id', _uid!)
        .gte('created_at', since.toIso8601String());
    if (response.isEmpty) return ProductionSummary.empty();
    double totalMethane = 0, avgTemp = 0;
    int count = response.length;
    for (final doc in response) {
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
  final double volume;
  final double efficiency;
  final double energyGenerated;
  final double co2Reduction;
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
