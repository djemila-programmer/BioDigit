import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../supabase.dart';
import 'sensor_service.dart';

/// Push notification service using Supabase Realtime + local notifications.
class NotificationService {
  FlutterLocalNotificationsPlugin? _localNotifications;
  bool _initialized = false;

  FlutterLocalNotificationsPlugin? get _localNotif {
    _localNotifications ??= FlutterLocalNotificationsPlugin();
    return _localNotifications;
  }

  /// Initialize notification service.
  Future<void> initialize() async {
    if (_initialized) return;

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const windowsSettings = WindowsInitializationSettings(
      appName: 'BioSmart Africa',
      appUserModelId: 'com.biosmart.africa',
      guid: 'b3d7e8a1-4f2c-4a5b-9d6e-7f8a1b2c3d4e',
    );
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
      windows: windowsSettings,
    );
    await _localNotif!.initialize(initSettings);

    // Listen to real-time notifications from Supabase
    _listenToNotifications();

    _initialized = true;
  }

  /// Listen to notifications from Supabase Realtime.
  void _listenToNotifications() {
    final uid = supabase.auth.currentUser?.id;
    if (uid == null) return;

    supabase
        .from('notifications')
        .stream(primaryKey: ['id'])
        .eq('user_id', uid)
        .listen((rows) {
      final unread = rows.where((row) => row['read'] != true).toList();
      for (final row in unread) {
        _showLocalNotification(
          title: row['title']?.toString() ?? 'BioSmart',
          body: row['body']?.toString() ?? '',
          id: row['id']?.hashCode ?? 0,
        );
      }
    });
  }

  Future<void> _showLocalNotification({
    required String title,
    required String body,
    int id = 0,
  }) async {
    if (_localNotif == null) return;
    const androidDetails = AndroidNotificationDetails(
      'biosmart_alerts', 'BioSmart Alertes',
      channelDescription: 'Alertes critiques du biodigesteur',
      importance: Importance.high, priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true, presentBadge: true, presentSound: true,
    );
    const windowsDetails = WindowsNotificationDetails();
    const details = NotificationDetails(
      android: androidDetails, iOS: iosDetails, windows: windowsDetails,
    );
    await _localNotif!.show(id, title, body, details);
  }

  Future<void> checkAndNotify(SensorReading reading) async {
    if (!_initialized || _localNotif == null) return;
    int notificationId = 100;
    if (reading.temperature > 40 || reading.temperature < 25) {
      await _showLocalNotification(
        id: notificationId++,
        title: 'Température Critique',
        body: 'Température à ${reading.temperature.toStringAsFixed(1)}°C — action requise.',
      );
    }
    if (reading.pressure > 1.5 || reading.pressure < 0.8) {
      await _showLocalNotification(
        id: notificationId++,
        title: 'Pression Critique',
        body: 'Pression à ${reading.pressure.toStringAsFixed(2)} bar — vérifiez la soupape.',
      );
    }
    if (reading.methane > 500 || reading.methane < 150) {
      await _showLocalNotification(
        id: notificationId++,
        title: 'Méthane Critique',
        body: 'Méthane à ${reading.methane.toStringAsFixed(0)} ppm — risque de fuite.',
      );
    }
    if (reading.slurryLevel > 90 || reading.slurryLevel < 20) {
      await _showLocalNotification(
        id: notificationId++,
        title: 'Niveau de Lisier Critique',
        body: 'Niveau à ${reading.slurryLevel.toStringAsFixed(1)}% — vidange nécessaire.',
      );
    }
  }

  /// Stream of notifications for the current user.
  Stream<List<AppNotification>> notificationsStream() {
    final uid = supabase.auth.currentUser?.id;
    if (uid == null) return Stream.value([]);
    return supabase
        .from('notifications')
        .stream(primaryKey: ['id'])
        .eq('user_id', uid)
        .order('created_at', ascending: false)
        .map((rows) => rows.map((row) => AppNotification.fromSupabase(row)).toList());
  }

  /// Mark a notification as read.
  Future<void> markAsRead(String id) async {
    await supabase.from('notifications').update({'read': true}).eq('id', id);
  }

  Future<void> subscribeToTopic(String topic) async {
    // Supabase doesn't have topics like FCM. Use filters instead.
  }

  Future<void> unsubscribeFromTopic(String topic) async {
    // Supabase doesn't have topics like FCM. Use filters instead.
  }
}

/// Notification model for Supabase.
class AppNotification {
  final String id;
  final String title;
  final String body;
  final String type;
  final bool read;
  final DateTime? createdAt;

  const AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.read,
    this.createdAt,
  });

  factory AppNotification.fromSupabase(Map<String, dynamic> data) {
    return AppNotification(
      id: data['id']?.toString() ?? '',
      title: data['title']?.toString() ?? '',
      body: data['body']?.toString() ?? '',
      type: data['type']?.toString() ?? 'info',
      read: data['read'] == true,
      createdAt: data['created_at'] != null
          ? DateTime.tryParse(data['created_at'].toString())
          : null,
    );
  }
}
