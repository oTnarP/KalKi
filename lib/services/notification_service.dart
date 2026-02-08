import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    await AwesomeNotifications().initialize(
      null, // Use null to use the default app icon (safest)
      [
        NotificationChannel(
          channelGroupKey: 'basic_channel_group',
          channelKey: 'water_reminder',
          channelName: 'Water Reminders',
          channelDescription: 'Periodic reminders to drink water',
          defaultColor: const Color(0xFF9D50DD),
          ledColor: Colors.white,
          importance: NotificationImportance.High,
          channelShowBadge: true,
          playSound: true,
          criticalAlerts: true,
        ),
        NotificationChannel(
          channelGroupKey: 'basic_channel_group',
          channelKey: 'menu_check',
          channelName: 'Daily Menu Check',
          channelDescription: 'Daily reminder to check and lock your menu',
          defaultColor: const Color(0xFF9D50DD),
          ledColor: Colors.white,
          importance: NotificationImportance.High,
          channelShowBadge: true,
          playSound: true,
          criticalAlerts: true,
        ),
      ],
      // Channel groups are only visual and are optional
      channelGroups: [
        NotificationChannelGroup(
          channelGroupKey: 'basic_channel_group',
          channelGroupName: 'Basic group',
        ),
      ],
      debug: kDebugMode,
    );

    // Set up listeners for debugging
    AwesomeNotifications().setListeners(
      onActionReceivedMethod: onActionReceivedMethod,
      onNotificationCreatedMethod: onNotificationCreatedMethod,
      onNotificationDisplayedMethod: onNotificationDisplayedMethod,
      onDismissActionReceivedMethod: onDismissActionReceivedMethod,
    );

    _initialized = true;
  }

  /// Use this method to detect when a new notification or a schedule is created
  @pragma("vm:entry-point")
  static Future<void> onNotificationCreatedMethod(
    ReceivedNotification receivedNotification,
  ) async {
    debugPrint('CALKI: Notification created: ${receivedNotification.id}');
  }

  /// Use this method to detect every time that a new notification is displayed
  @pragma("vm:entry-point")
  static Future<void> onNotificationDisplayedMethod(
    ReceivedNotification receivedNotification,
  ) async {
    debugPrint('CALKI: Notification displayed: ${receivedNotification.id}');
  }

  /// Use this method to detect if the user dismissed a notification
  @pragma("vm:entry-point")
  static Future<void> onDismissActionReceivedMethod(
    ReceivedAction receivedAction,
  ) async {
    debugPrint('CALKI: Notification dismissed: ${receivedAction.id}');
  }

  /// Use this method to detect when the user taps on a notification or action button
  @pragma("vm:entry-point")
  static Future<void> onActionReceivedMethod(
    ReceivedAction receivedAction,
  ) async {
    debugPrint('CALKI: Notification action received: ${receivedAction.id}');
  }

  Future<bool> showTestNotification() async {
    try {
      if (!_initialized) await initialize();

      bool isAllowed = await AwesomeNotifications().isNotificationAllowed();
      debugPrint('CALKI: Notification allowed? $isAllowed');

      if (!isAllowed) {
        isAllowed = await requestPermissions();
        if (!isAllowed) {
          debugPrint('CALKI: Notifications NOT allowed by user');
          return false;
        }
      }

      final result = await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: 999,
          channelKey: 'menu_check',
          title: '🔔 Test Notification',
          body: 'If you see this, notifications are working!',
          notificationLayout: NotificationLayout.Default,
          category: NotificationCategory.Reminder,
          wakeUpScreen: true,
          autoDismissible: false,
          criticalAlert: true,
        ),
      );
      debugPrint('CALKI: Test notification creation result: $result');
      return result;
    } catch (e) {
      debugPrint('CALKI: Error showing test notification: $e');
      return false;
    }
  }

  Future<bool> requestPermissions() async {
    bool isAllowed = await AwesomeNotifications().isNotificationAllowed();
    if (!isAllowed) {
      // This shows a dialog by default, but we can also just request
      isAllowed = await AwesomeNotifications()
          .requestPermissionToSendNotifications();
    }
    return isAllowed;
  }

  Future<void> scheduleWaterReminders({
    required int hours,
    required String title,
    required String body,
  }) async {
    if (!_initialized) await initialize();

    // Cancel existing water reminder only (ID 100)
    await AwesomeNotifications().cancel(100);

    // Awesome Notifications schedule
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 100, // Water Reminder ID
        channelKey: 'water_reminder',
        title: title,
        body: body,
        notificationLayout: NotificationLayout.Default,
        category: NotificationCategory.Reminder,
        wakeUpScreen: true,
      ),
      schedule: NotificationInterval(
        interval: Duration(hours: hours),
        timeZone: await AwesomeNotifications().getLocalTimeZoneIdentifier(),
        repeats: true,
        preciseAlarm: true,
      ),
    );
  }

  Future<void> cancelWaterReminders() async {
    await AwesomeNotifications().cancel(100);
    debugPrint('CALKI: Water reminders canceled');
  }

  Future<void> scheduleDailyMenuReminder({
    required String checkTitle,
    required String checkBody,
    required String reminderTitle,
    required String reminderBody,
    required String lastCallTitle,
    required String lastCallBody,
  }) async {
    if (!_initialized) await initialize();

    // Schedule 1: 10:00 PM (22:00)
    await _scheduleDailyNotification(
      id: 200,
      title: checkTitle,
      body: checkBody,
      hour: 22,
      minute: 0,
    );

    // Schedule 2: 11:00 PM (23:00) - Reminder 1
    await _scheduleDailyNotification(
      id: 201,
      title: reminderTitle,
      body: reminderBody,
      hour: 23,
      minute: 0,
    );

    // Schedule 3: 11:59 PM (23:59) - Final Call
    await _scheduleDailyNotification(
      id: 202,
      title: lastCallTitle,
      body: lastCallBody,
      hour: 23,
      minute: 59,
    );

    debugPrint(
      'CALKI: Menu reminders scheduled for 10:00 PM, 11:00 PM, 11:59 PM',
    );
  }

  Future<void> _scheduleDailyNotification({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
  }) async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: id,
        channelKey: 'menu_check',
        title: title,
        body: body,
        notificationLayout: NotificationLayout.Default,
        category: NotificationCategory.Reminder,
        wakeUpScreen: true,
      ),
      schedule: NotificationCalendar(
        hour: hour,
        minute: minute,
        second: 0,
        millisecond: 0,
        repeats: true,
        allowWhileIdle: true,
        preciseAlarm: true,
        timeZone: 'Asia/Dhaka',
      ),
    );
  }

  Future<void> cancelMenuReminder() async {
    await AwesomeNotifications().cancel(200);
    await AwesomeNotifications().cancel(201);
    await AwesomeNotifications().cancel(202);
    debugPrint('CALKI: All menu reminders canceled');
  }

  Future<void> cancelAllReminders() async {
    await AwesomeNotifications().cancelAll();
  }
}
