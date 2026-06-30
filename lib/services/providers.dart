import 'dart:async';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import '../services/auth_service.dart';

import '../services/sensor_service.dart';
import '../services/alert_service.dart';
import '../services/anomaly_service.dart';
import '../services/history_service.dart';
import '../services/notification_service.dart';
import '../services/cache_service.dart';
import '../services/farm_service.dart';
import '../models/user_model.dart';

// ═══════════════════════════════════════════════════════════════════════════
// Auth Provider
// ═══════════════════════════════════════════════════════════════════════════

class AuthProvider extends ChangeNotifier {
  final AuthService _authService;

  UserModel? _user;
  bool _isLoading = false;
  String? _error;
  StreamSubscription? _authSub;

  AuthProvider(this._authService) {
    _authSub = _authService.authStateChanges.listen((user) async {
      try {
        if (user != null) {
          _user = await _authService.getCurrentUserProfile();
        } else {
          _user = null;
        }
        _error = null;
      } catch (e) {
        _user = null;
        _error = e.toString();
        debugPrint('AuthProvider.authStateChanges failed: $e');
      }
      notifyListeners();
    });
  }

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null;
  String? get error => _error;

  /// Callbacks to start data listeners after successful login.
  VoidCallback? onDataListenersStart;

  Future<bool> signIn(
    String email,
    String password, {
    required String expectedRole,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _user = await _authService.signIn(
        email: email,
        password: password,
        expectedRole: expectedRole,
      );
      _isLoading = false;
      notifyListeners();
      if (_user != null) onDataListenersStart?.call();
      return _user != null;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signUp({
    required String email,
    required String password,
    required String fullName,
    required String phone,
    required String farmName,
    String? biodigesterType,
    double? biodigesterCapacity,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _user = await _authService.signUp(
        email: email,
        password: password,
        fullName: fullName,
        phone: phone,
        farmName: farmName,
        biodigesterType: biodigesterType,
        biodigesterCapacity: biodigesterCapacity,
      );
      _isLoading = false;
      notifyListeners();
      return _user != null;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
    _user = null;
    notifyListeners();
  }

  Future<void> changePassword(
    String currentPassword,
    String newPassword,
  ) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await _authService.changePassword(currentPassword, newPassword);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<String?> uploadAvatar(String filePath) async {
    _isLoading = true;
    notifyListeners();
    try {
      final url = await _authService.uploadAvatar(filePath);
      if (url != null) {
        _user = _user?.copyWith(profileImageUrl: url);
        notifyListeners();
      }
      _isLoading = false;
      notifyListeners();
      return url;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  Future<void> sendPasswordReset(String email) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await _authService.sendPasswordResetEmail(email);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateProfile(Map<String, dynamic> updates) async {
    await _authService.updateUserProfile(updates);
    _user = await _authService.getCurrentUserProfile();
    notifyListeners();
  }

  @override
  void dispose() {
    _authSub?.cancel();
    super.dispose();
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Sensor Provider (real-time data from ESP32 via Firebase RTDB)
// ═══════════════════════════════════════════════════════════════════════════

class SensorProvider extends ChangeNotifier {
  final SensorService _sensorService;
  final HistoryService _historyService;
  // Injected and used in startListening() for critical threshold notifications.
  final NotificationService _notificationService;

  final CacheService _cacheService;

  SensorReading? _latestReading;
  Esp32StatusData? _esp32Status;
  StreamSubscription? _sensorSub;
  StreamSubscription? _esp32Sub;
  bool _isLoading = true;
  String? _error;
  bool _isOnline = true;

  SensorProvider(
    this._sensorService,
    this._historyService,
    this._notificationService,
    this._cacheService,
  );

  SensorReading? get latestReading => _latestReading;
  Esp32StatusData? get esp32Status => _esp32Status;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isOnline => _isOnline;

  /// Start listening to real-time sensor data.
  void startListening() {
    _isLoading = true;
    notifyListeners();

    _sensorSub = _sensorService.sensorDataStream().listen(
      (reading) async {
        _latestReading = reading;
        _isLoading = false;
        _error = null;
        _isOnline = true;
        notifyListeners();

        // Cache for offline
        try {
          await _cacheService.cacheSensorReading(reading);

          // Log to history
          await _historyService.logReading(reading);

          // Check for critical values and notify
          await _notificationService.checkAndNotify(reading);
        } catch (e) {
          debugPrint('SensorProvider.startListening post-processing failed: $e');
        }
      },
      onError: (e) {
        _error = e.toString();
        _isLoading = false;
        _isOnline = false;
        // Fall back to cache
        _latestReading = _cacheService.getLastCachedReading();
        notifyListeners();
      },
    );

    _esp32Sub = _sensorService.esp32StatusStream().listen((status) {
      _esp32Status = status;
      notifyListeners();
    });
  }

  /// Load cached data when offline.
  void loadCached() {
    _latestReading = _cacheService.getLastCachedReading();
    _isOnline = false;
    _isLoading = false;
    notifyListeners();
  }

  void stopListening() {
    _sensorSub?.cancel();
    _esp32Sub?.cancel();
  }

  @override
  void dispose() {
    stopListening();
    super.dispose();
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Alert Provider
// ═══════════════════════════════════════════════════════════════════════════

class AlertProvider extends ChangeNotifier {
  final AlertService _alertService;

  List<SmartAlert> _alerts = [];
  Map<String, int> _counts = {'critical': 0, 'warning': 0, 'info': 0};
  StreamSubscription? _alertSub;
  bool _isLoading = true;

  AlertProvider(this._alertService);

  List<SmartAlert> get alerts => _alerts;
  Map<String, int> get counts => _counts;
  int get totalCount => _counts.values.fold(0, (a, b) => a + b);
  bool get isLoading => _isLoading;

  void startListening() {
    _alertSub = _alertService.alertsStream().listen((alerts) {
      _alerts = alerts;
      _isLoading = false;
      _updateCounts();
      notifyListeners();
    });
  }

  void _updateCounts() {
    _counts = {'critical': 0, 'warning': 0, 'info': 0};
    for (final a in _alerts.where((a) => !a.resolved)) {
      if (_counts.containsKey(a.severity)) {
        _counts[a.severity] = _counts[a.severity]! + 1;
      }
    }
  }

  Future<void> acknowledge(String id) async {
    await _alertService.acknowledgeAlert(id);
  }

  Future<void> resolve(String id) async {
    await _alertService.resolveAlert(id);
  }

  void stopListening() {
    _alertSub?.cancel();
  }

  @override
  void dispose() {
    stopListening();
    super.dispose();
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Anomaly Provider (real detection engine)
// ═══════════════════════════════════════════════════════════════════════════

class AnomalyProvider extends ChangeNotifier {
  final AnomalyService _anomalyService;

  AnomalyReport? _report;

  AnomalyProvider(this._anomalyService);

  AnomalyReport? get report => _report;

  /// Run anomaly analysis on the latest sensor reading.
  Future<void> analyze(SensorReading reading) async {
    _report = _anomalyService.analyze(reading);
    notifyListeners();
    // Persist to Firestore
    await _anomalyService.saveReport(_report!);
  }

  List<Map<String, dynamic>> _history = [];
  List<Map<String, dynamic>> get history => _history;

  Future<void> loadHistory() async {
    _history = await _anomalyService.getHistory();
    notifyListeners();
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// History Provider
// ═══════════════════════════════════════════════════════════════════════════

class HistoryProvider extends ChangeNotifier {
  final HistoryService _historyService;

  List<HistoryPoint> _data = [];
  ProductionSummary? _production;
  bool _isLoading = false;
  String _selectedRange = '24h';

  HistoryProvider(this._historyService);

  List<HistoryPoint> get data => _data;
  ProductionSummary? get production => _production;
  bool get isLoading => _isLoading;
  String get selectedRange => _selectedRange;

  Future<void> loadData(String range) async {
    _selectedRange = range;
    _isLoading = true;
    notifyListeners();

    switch (range) {
      case '24h':
        _data = await _historyService.getLast24Hours();
        break;
      case '7d':
        _data = await _historyService.getLast7Days();
        break;
      case '30d':
        _data = await _historyService.getLast30Days();
        break;
      case '12m':
        _data = await _historyService.getLast12Months();
        break;
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadProduction(String period) async {
    _production = await _historyService.getProductionSummary(period);
    notifyListeners();
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Connectivity Provider
// ═══════════════════════════════════════════════════════════════════════════

class ConnectivityProvider extends ChangeNotifier {
  final Connectivity _connectivity = Connectivity();
  StreamSubscription? _sub;
  bool _isOnline = true;

  ConnectivityProvider();

  bool get isOnline => _isOnline;

  void startListening() {
    _sub = _connectivity.onConnectivityChanged.listen((results) {
      _isOnline = results.any((r) => r != ConnectivityResult.none);
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Farm Provider
// ═══════════════════════════════════════════════════════════════════════════

class FarmProvider extends ChangeNotifier {
  final FarmService _farmService;

  List<FarmData> _farms = [];
  Map<String, dynamic>? _systemStats;
  bool _isLoading = false;
  String? _error;

  FarmProvider(this._farmService);

  List<FarmData> get farms => _farms;
  Map<String, dynamic>? get systemStats => _systemStats;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadFarms() async {
    _isLoading = true;
    notifyListeners();
    try {
      _farms = await _farmService.getUserFarms();
      _error = null;
    } catch (e) {
      _error = e.toString();
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadSystemStats() async {
    try {
      _systemStats = await _farmService.getSystemStats();
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      debugPrint('FarmProvider.loadSystemStats failed: $e');
      notifyListeners();
    }
  }

  Future<String> createFarm({
    required String name,
    required String location,
    required String biodigesterType,
    required double biodigesterCapacity,
    int cows = 0,
    int pigs = 0,
    int goats = 0,
    int poultry = 0,
  }) async {
    final id = await _farmService.createFarm(
      name: name,
      location: location,
      biodigesterType: biodigesterType,
      biodigesterCapacity: biodigesterCapacity,
      cows: cows,
      pigs: pigs,
      goats: goats,
      poultry: poultry,
    );
    await loadFarms();
    return id;
  }

  Future<void> updateFarm(String farmId, Map<String, dynamic> updates) async {
    await _farmService.updateFarm(farmId, updates);
    await loadFarms();
  }

  Future<void> deleteFarm(String farmId) async {
    await _farmService.deleteFarm(farmId);
    await loadFarms();
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Notification Provider (Firestore-persisted notifications)
// ═══════════════════════════════════════════════════════════════════════════

class NotificationProvider extends ChangeNotifier {
  // ignore: unused_field
  final NotificationService _notificationService;

  /// This project currently uses local notifications (FCM + flutter_local_notifications).
  /// Persistent Firestore notifications are not implemented in NotificationService yet.
  /// We keep the provider for future expansion and expose an empty state for now.
  final List<Object> _notifications = const <Object>[];

  bool _isLoading = false;
  StreamSubscription? _sub;

  // ignore: unused_field
  NotificationProvider(this._notificationService);

  List<Object> get notifications => _notifications;

  bool get isLoading => _isLoading;
  int get unreadCount => 0;

  void startListening() {
    // Not implemented yet (NotificationService has no Firestore stream).
    // This will be completed when persistent notifications are implemented.

    _isLoading = false;
    notifyListeners();
  }

  Future<void> markAsRead(String id) async {
    // Not implemented yet.
  }

  Future<void> markAllAsRead() async {
    // Not implemented yet.
  }

  void stopListening() {
    _sub?.cancel();
  }

  @override
  void dispose() {
    stopListening();
    super.dispose();
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Theme Provider (Dark/Light mode with Hive persistence)
// ═══════════════════════════════════════════════════════════════════════════

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;

  ThemeMode get themeMode => _themeMode;
  bool get isDark => _themeMode == ThemeMode.dark;

  ThemeProvider() {
    _loadFromCache();
  }

  void _loadFromCache() {
    try {
      final box = _themeBox;
      if (box != null) {
        final saved = box.get('darkMode', defaultValue: false);
        _themeMode = saved == true ? ThemeMode.dark : ThemeMode.light;
      }
    } catch (e) {
      debugPrint('ThemeProvider._loadFromCache failed: $e');
    }
  }

  dynamic get _themeBox {
    // CacheService does not expose getBox in this codebase.
    // Theme persistence will be wired when a proper Hive box accessor is added.
    return null;
  }

  Future<void> toggleTheme(bool dark) async {
    _themeMode = dark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
    try {
      _themeBox?.put('darkMode', dark);
    } catch (e) {
      debugPrint('ThemeProvider.toggleTheme failed: $e');
    }
  }
}
