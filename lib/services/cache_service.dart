import 'package:hive_flutter/hive_flutter.dart';
import 'sensor_service.dart';

/// Offline cache service using Hive local database.
/// Stores latest sensor readings for offline viewing and auto-syncs when online.
class CacheService {
  static const String _sensorBox = 'sensorCache';
  static const String _alertBox = 'alertCache';
  static const String _farmBox = 'farmCache';
  static const String _metaBox = 'metaCache';

  late Box _sensors;
  late Box _alerts;
  late Box _farms;
  late Box _meta;

  bool _initialized = false;

  /// Initialize Hive boxes.
  Future<void> initialize() async {
    if (_initialized) return;
    await Hive.initFlutter();
    _sensors = await Hive.openBox(_sensorBox);
    _alerts = await Hive.openBox(_alertBox);
    _farms = await Hive.openBox(_farmBox);
    _meta = await Hive.openBox(_metaBox);
    _initialized = true;
  }

  // ─── Sensor Cache ───────────────────────────────────────────────────────

  /// Cache the latest sensor reading.
  Future<void> cacheSensorReading(SensorReading reading) async {
    if (!_initialized) return;
    await _sensors.put('latest', reading.toJson());
    await _sensors.put('lastCachedAt', DateTime.now().toIso8601String());
  }

  /// Get the last cached sensor reading.
  SensorReading? getLastCachedReading() {
    if (!_initialized) return null;
    final data = _sensors.get('latest');
    if (data == null) return null;
    final map = Map<String, dynamic>.from(data as Map);
    return SensorReading(
      temperature: (map['temperature'] as num?)?.toDouble() ?? 0,
      pressure: (map['pressure'] as num?)?.toDouble() ?? 0,
      methane: (map['methane'] as num?)?.toDouble() ?? 0,
      slurryLevel: (map['slurryLevel'] as num?)?.toDouble() ?? 0,
      timestamp: map['timestamp'] != null
          ? DateTime.tryParse(map['timestamp']) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  /// Get when the sensor cache was last updated.
  DateTime? getLastCacheTime() {
    if (!_initialized) return null;
    final ts = _sensors.get('lastCachedAt');
    if (ts == null) return null;
    return DateTime.tryParse(ts);
  }

  // ─── Alert Cache ────────────────────────────────────────────────────────

  /// Cache alerts for offline viewing.
  Future<void> cacheAlerts(List<Map<String, dynamic>> alerts) async {
    if (!_initialized) return;
    await _alerts.put('all', alerts);
  }

  /// Get cached alerts.
  List<Map<String, dynamic>> getCachedAlerts() {
    if (!_initialized) return [];
    final data = _alerts.get('all');
    if (data == null) return [];
    return List<Map<String, dynamic>>.from(data);
  }

  // ─── Farm Cache ─────────────────────────────────────────────────────────

  /// Cache farm data for offline viewing.
  Future<void> cacheFarmData(String farmId, Map<String, dynamic> farm) async {
    if (!_initialized) return;
    await _farms.put(farmId, farm);
  }

  /// Get cached farm data.
  Map<String, dynamic>? getCachedFarm(String farmId) {
    if (!_initialized) return null;
    final data = _farms.get(farmId);
    if (data == null) return null;
    return Map<String, dynamic>.from(data);
  }

  /// Get all cached farms.
  List<Map<String, dynamic>> getAllCachedFarms() {
    if (!_initialized) return [];
    return _farms.values.map((v) => Map<String, dynamic>.from(v as Map)).toList();
  }

  // ─── Sync Status ────────────────────────────────────────────────────────

  /// Mark pending sync items (for when internet returns).
  Future<void> addPendingSync(String type, Map<String, dynamic> data) async {
    if (!_initialized) return;
    final pending = _meta.get('pendingSync', defaultValue: <Map>[]);
    final list = List<Map>.from(pending);
    list.add({'type': type, 'data': data, 'timestamp': DateTime.now().toIso8601String()});
    await _meta.put('pendingSync', list);
  }

  /// Get all pending sync items.
  List<Map<String, dynamic>> getPendingSyncs() {
    if (!_initialized) return [];
    final data = _meta.get('pendingSync', defaultValue: <Map>[]);
    return List<Map<String, dynamic>>.from(
      (data as List).map((e) => Map<String, dynamic>.from(e as Map)),
    );
  }

  /// Clear pending syncs after successful upload.
  Future<void> clearPendingSyncs() async {
    if (!_initialized) return;
    await _meta.put('pendingSync', <Map>[]);
  }

  /// Check if data is stale (older than given minutes).
  bool isStale({int maxAgeMinutes = 5}) {
    if (!_initialized) return true;
    final lastCached = getLastCacheTime();
    if (lastCached == null) return true;
    return DateTime.now().difference(lastCached).inMinutes > maxAgeMinutes;
  }

  /// Clear all caches.
  Future<void> clearAll() async {
    if (!_initialized) return;
    await _sensors.clear();
    await _alerts.clear();
    await _farms.clear();
    await _meta.clear();
  }
}
