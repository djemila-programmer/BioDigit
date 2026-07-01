import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'firebase_service_mixin.dart';
import 'sensor_service.dart';

/// Push notification service using Firebase Cloud Messaging + local notifications.
class NotificationService with FirebaseServiceMixin {
  FlutterLocalNotificationsPlugin? _localNotifications;
  bool _initialized = false;

  FirebaseMessaging? get _fcmInst => messagingOrNull;

  FlutterLocalNotificationsPlugin? get _localNotif {
    _localNotifications ??= FlutterLocalNotificationsPlugin();
    return _localNotifications;
  }

  /// Initialize notification service.
  Future<void> initialize() async {
    if (_initialized || _fcmInst == null) return;

    final settings = await _fcmInst!.requestPermission(
      alert: true, badge: true, sound: true, provisional: false,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      final token = await _fcmInst!.getToken();
      if (token != null) await _saveToken(token);
      _fcmInst!.onTokenRefresh.listen(_saveToken);
    }

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true, requestBadgePermission: true, requestSoundPermission: true,
    );
    const initSettings = InitializationSettings(android: androidSettings, iOS: iosSettings);
    await _localNotif!.initialize(initSettings);

    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    FirebaseMessaging.onBackgroundMessage(_firebaseBackgroundHandler);

    _initialized = true;
  }

  /// Save FCM token to Firestore.
  Future<void> _saveToken(String token) async {
    // Token is saved by the auth provider when user is logged in
    // This is handled in the AuthProvider
  }

  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;
    await _showLocalNotification(
      title: notification.title ?? 'BioSmart',
      body: notification.body ?? '',
    );
  }

  Future<void> _showLocalNotification({
    required String title, required String body, int id = 0,
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
    const details = NotificationDetails(android: androidDetails, iOS: iosDetails);
    await _localNotif!.show(id, title, body, details);
  }

  Future<void> checkAndNotify(SensorReading reading) async {
    if (!_initialized || _localNotif == null) return;
    int notificationId = 100;
    if (reading.temperature > 40 || reading.temperature < 25) {
      await _showLocalNotification(id: notificationId++,
        title: '🌡️ Température Critique',
        body: 'Température à ${reading.temperature.toStringAsFixed(1)}°C — action requise.');
    }
    if (reading.pressure > 1.5 || reading.pressure < 0.8) {
      await _showLocalNotification(id: notificationId++,
        title: '⚠️ Pression Critique',
        body: 'Pression à ${reading.pressure.toStringAsFixed(2)} bar — vérifiez la soupape.');
    }
    if (reading.methane > 500 || reading.methane < 150) {
      await _showLocalNotification(id: notificationId++,
        title: '💨 Méthane Critique',
        body: 'Méthane à ${reading.methane.toStringAsFixed(0)} ppm — risque de fuite.');
    }
    if (reading.slurryLevel > 90 || reading.slurryLevel < 20) {
      await _showLocalNotification(id: notificationId++,
        title: '📊 Niveau de Lisier Critique',
        body: 'Niveau à ${reading.slurryLevel.toStringAsFixed(1)}% — vidange nécessaire.');
    }
  }

  Future<void> subscribeToTopic(String topic) async {
    await _fcmInst?.subscribeToTopic(topic);
  }

  Future<void> unsubscribeFromTopic(String topic) async {
    await _fcmInst?.unsubscribeFromTopic(topic);
  }
}

/// Background message handler (must be top-level function).
@pragma('vm:entry-point')
Future<void> _firebaseBackgroundHandler(RemoteMessage message) async {
  // Firebase handles background notifications automatically
  // This is called when a data-only message is received in background
}
