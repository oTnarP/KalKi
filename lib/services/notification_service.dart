import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    // Android initialization
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    // iOS initialization
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    await _notifications.initialize(
      settings: const InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      ),
      onDidReceiveNotificationResponse: (response) {
        // Handle notification tap
      },
    );

    // Create Android notification channel
    const androidChannel = AndroidNotificationChannel(
      'water_reminder',
      'Water Reminders',
      description: 'Periodic reminders to drink water',
      importance: Importance.high,
    );

    await _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(androidChannel);

    _initialized = true;
  }

  Future<void> scheduleWaterReminders(int hours) async {
    if (!_initialized) await initialize();

    // Cancel existing reminders first
    await cancelAllReminders();

    // Schedule repeating notification (hourly only)
    await _notifications.periodicallyShow(
      id: 0,
      title: '💧 Time to Drink Water!',
      body: 'Stay hydrated for better health',
      repeatInterval: RepeatInterval.hourly,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'water_reminder',
          'Water Reminders',
          channelDescription: 'Periodic reminders to drink water',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }

  Future<void> cancelAllReminders() async {
    await _notifications.cancelAll();
  }
}
