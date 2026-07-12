import 'dart:async';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../supabase.dart';
import '../services/auth_service.dart';

import '../services/sensor_service.dart';
import '../services/alert_service.dart';
import '../services/anomaly_service.dart';
import '../services/history_service.dart';
import '../services/notification_service.dart';
import '../services/cache_service.dart';
import '../services/farm_service.dart';
import '../services/simulation_service.dart';
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
  bool _isPasswordRecovery = false;
  void Function(bool authenticated)? authStateListener;

  AuthProvider(this._authService) {
    _authSub = _authService.authStateChanges.listen((authState) async {
      _isPasswordRecovery = authState.event == AuthChangeEvent.passwordRecovery;
      if (authState.session != null) {
        _user = await _authService.getCurrentUserProfile();
      } else {
        _user = null;
      }
      notifyListeners();
      authStateListener?.call(_user != null);
    });
  }

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null;
  String? get error => _error;
  bool get isPasswordRecovery => _isPasswordRecovery;

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

  Future<bool> signInWithGoogle({String expectedRole = 'user'}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _user = await _authService.signInWithGoogle(expectedRole: expectedRole);
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
    _isPasswordRecovery = false;
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

  Future<void> completePasswordReset(String newPassword) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await _authService.completePasswordReset(newPassword);
      _isLoading = false;
      _isPasswordRecovery = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  void clearRecoveryState() {
    _isPasswordRecovery = false;
    notifyListeners();
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
// Sensor Provider (real-time data from ESP8266 via Supabase Realtime)
// ═══════════════════════════════════════════════════════════════════════════

class SensorProvider extends ChangeNotifier {
  final SensorService _sensorService;
  final HistoryService _historyService;
  final NotificationService _notificationService;
  final CacheService _cacheService;
  final SimulationService _simulationService;

  SensorReading? _latestReading;
  Esp32StatusData? _esp32Status;
  StreamSubscription? _sensorSub;
  StreamSubscription? _esp32Sub;
  bool _isLoading = true;
  String? _error;
  bool _isOnline = true;
  bool _isSimulation = false;

  SensorProvider(
    this._sensorService,
    this._historyService,
    this._notificationService,
    this._cacheService,
    this._simulationService,
  );

  SensorReading? get latestReading => _latestReading;
  Esp32StatusData? get esp32Status => _esp32Status;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isOnline => _isOnline;
  bool get isSimulation => _isSimulation;

  /// Start listening to real-time sensor data.
  /// Shows empty state until a real ESP8266 connects and pushes data.
  void startListening() {
    _isLoading = true;
    notifyListeners();

    _sensorSub = _sensorService.sensorDataStream().listen(
      (reading) async {
        // Real data arrived from ESP8266
        if (_isSimulation) {
          _simulationService.stop();
          _isSimulation = false;
        }
        _latestReading = reading;
        _isLoading = false;
        _error = null;
        _isOnline = true;
        notifyListeners();

        await _cacheService.cacheSensorReading(reading);
        await _historyService.logReading(reading);
        await _notificationService.checkAndNotify(reading);
      },
      onError: (e) {
        _error = e.toString();
        _isLoading = false;
        _isOnline = false;
        _latestReading = _cacheService.getLastCachedReading();
        notifyListeners();
      },
    );

    _esp32Sub = _sensorService.esp32StatusStream().listen((status) {
      _esp32Status = status;
      notifyListeners();
    });

    // No auto-simulation: show empty state until real ESP8266 data arrives
    Future.delayed(const Duration(seconds: 3), () {
      if (_latestReading == null || _latestReading!.temperature == 0) {
        _isLoading = false;
        notifyListeners();
      }
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
    _simulationService.stop();
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
      // Check if user is admin - if so, load all farms
      final userRole = supabase.auth.currentUser != null 
          ? await _getUserRole() 
          : 'user';

      if (userRole == 'admin') {
        _farms = await _farmService.getAllFarms();
      } else {
        _farms = await _farmService.getUserFarms();
      }
      _error = null;
    } catch (e) {
      _error = e.toString();
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<String> _getUserRole() async {
    try {
      final response = await supabase
          .from('profiles')
          .select('role')
          .eq('id', supabase.auth.currentUser!.id)
          .maybeSingle();
      return response?['role'] as String? ?? 'user';
    } catch (_) {
      return 'user';
    }
  }

  Future<void> loadSystemStats() async {
    try {
      _systemStats = await _farmService.getSystemStats();
      notifyListeners();
    } catch (_) {}
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
// Notification Provider
// ═══════════════════════════════════════════════════════════════════════════

class NotificationProvider extends ChangeNotifier {
  final NotificationService _notificationService;

  List<AppNotification> _notifications = [];
  bool _isLoading = false;
  StreamSubscription? _sub;

  NotificationProvider(this._notificationService);

  List<AppNotification> get notifications => _notifications;
  bool get isLoading => _isLoading;
  int get unreadCount => _notifications.where((n) => !n.read).length;

  void startListening() {
    _isLoading = true;
    notifyListeners();
    _sub = _notificationService.notificationsStream().listen(
      (notifications) {
        _notifications = notifications;
        _isLoading = false;
        notifyListeners();
      },
      onError: (_) {
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  Future<void> markAsRead(String id) async {
    await _notificationService.markAsRead(id);
  }

  Future<void> markAllAsRead() async {
    for (final n in _notifications.where((n) => !n.read)) {
      await _notificationService.markAsRead(n.id);
    }
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
// Theme Provider
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
    } catch (_) {}
  }

  dynamic get _themeBox {
    try {
      return Hive.box('themeBox');
    } catch (_) {
      return null;
    }
  }

  Future<void> toggleTheme(bool dark) async {
    _themeMode = dark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
    try {
      final box = _themeBox;
      if (box != null) {
        await box.put('darkMode', dark);
      }
    } catch (_) {}
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Locale Provider (French + English only)
// ═══════════════════════════════════════════════════════════════════════════

class LocaleProvider extends ChangeNotifier {
  Locale _locale = const Locale('fr');

  Locale get locale => _locale;
  bool get isFrench => _locale.languageCode == 'fr';

  LocaleProvider() {
    _loadFromCache();
  }

  void _loadFromCache() {
    try {
      final box = Hive.box('localeBox');
      final saved = box.get('language', defaultValue: 'fr') as String;
      _locale = Locale(saved);
    } catch (_) {}
  }

  Future<void> setLocale(Locale locale) async {
    _locale = locale;
    notifyListeners();
    try {
      final box = await Hive.openBox('localeBox');
      await box.put('language', locale.languageCode);
    } catch (_) {}
  }

  Future<void> toggleLanguage(bool isFrench) async {
    await setLocale(Locale(isFrench ? 'fr' : 'en'));
  }
}
