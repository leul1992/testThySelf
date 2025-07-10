import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:test_thy_self/core/constants/app_constants.dart';
import 'package:test_thy_self/data/repositories/service_locator.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  late FlutterLocalNotificationsPlugin _notificationsPlugin;

  Future<void> init() async {
    _notificationsPlugin = FlutterLocalNotificationsPlugin();

    // Initialize timezone database
    tz.initializeTimeZones();

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationResponse,
    );

    // Create notification channel (Android)
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      AppConstants.notificationChannelId,
      AppConstants.notificationChannelName,
      description: AppConstants.notificationChannelDesc,
      importance: Importance.high,
      playSound: true,
    );

    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  Future<void> scheduleDailyNotifications() async {
    try {
      // Cancel any existing notifications
      await _notificationsPlugin.cancelAll();

      // Schedule notifications for 10 AM, 2 PM, 6 PM, and 10 PM
      await _scheduleNotification(
        id: 1,
        title: 'Progress Check',
        body: 'How is your progress today?',
        hour: 10,
        minute: 0,
      );

      await _scheduleNotification(
        id: 2,
        title: 'Progress Check',
        body: 'Midday check-in. How are you doing?',
        hour: 14,
        minute: 0,
      );

      await _scheduleNotification(
        id: 3,
        title: 'Progress Check',
        body: 'Evening check. Staying on track?',
        hour: 18,
        minute: 0,
      );

      await _scheduleNotification(
        id: 4,
        title: 'Final Progress Check',
        body: 'Time to log your final progress for the day',
        hour: 22,
        minute: 0,
      );
    } catch (e) {
      debugPrint('Error scheduling notifications: $e');
      // Fallback to inexact alarms if exact alarms fail
      await _scheduleWithInexactAlarms();
    }
  }

  Future<void> _scheduleWithInexactAlarms() async {
    try {
      await _notificationsPlugin.cancelAll();
      
      await _scheduleNotification(
        id: 1,
        title: 'Progress Check',
        body: 'How is your progress today?',
        hour: 10,
        minute: 0,
        exact: false,
      );

      await _scheduleNotification(
        id: 2,
        title: 'Progress Check',
        body: 'Midday check-in. How are you doing?',
        hour: 14,
        minute: 0,
        exact: false,
      );

      await _scheduleNotification(
        id: 3,
        title: 'Progress Check',
        body: 'Evening check. Staying on track?',
        hour: 18,
        minute: 0,
        exact: false,
      );

      await _scheduleNotification(
        id: 4,
        title: 'Final Progress Check',
        body: 'Time to log your final progress for the day',
        hour: 22,
        minute: 0,
        exact: false,
      );
    } catch (e) {
      debugPrint('Error scheduling inexact alarms: $e');
    }
  }

  Future<void> _scheduleNotification({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
    bool exact = true,
  }) async {
    try {
      await _notificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        _nextInstanceOfTime(hour, minute),
        NotificationDetails(
          android: AndroidNotificationDetails(
            AppConstants.notificationChannelId,
            AppConstants.notificationChannelName,
            channelDescription: AppConstants.notificationChannelDesc,
            importance: Importance.high,
            priority: Priority.high,
            enableVibration: true,
            actions: [
              AndroidNotificationAction('success', '✅ OK'),
              AndroidNotificationAction('failure', '❌ Not OK'),
            ],
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        androidScheduleMode: exact
            ? AndroidScheduleMode.exactAllowWhileIdle
            : AndroidScheduleMode.inexact,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } catch (e) {
      debugPrint('Error scheduling notification $id: $e');
      rethrow;
    }
  }

  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    return scheduledDate;
  }

  void _onNotificationResponse(NotificationResponse response) {
    if (response.actionId == null) return;

    final streakService = ServiceLocator.instance.streakService;

    switch (response.actionId) {
      case 'success':
        streakService.logSuccess();
        break;
      case 'failure':
        streakService.logFailure();
        _cancelRemainingNotifications();
        break;
    }
  }

  Future<void> _cancelRemainingNotifications() async {
    final currentHour = DateTime.now().hour;
    
    if (currentHour < 12) {
      await _notificationsPlugin.cancel(2);
      await _notificationsPlugin.cancel(3);
      await _notificationsPlugin.cancel(4);
    } else if (currentHour < 16) {
      await _notificationsPlugin.cancel(3);
      await _notificationsPlugin.cancel(4);
    } else if (currentHour < 20) {
      await _notificationsPlugin.cancel(4);
    }
  }

  Future<void> checkForMissedNotifications() async {
    final now = DateTime.now();
    final currentHour = now.hour;

    // Only check at midnight
    if (currentHour != 0) return;

    final streakService = ServiceLocator.instance.streakService;
    final currentStreak = await streakService.getCurrentStreakDays();
    final startDate = await streakService.getCurrentStreakStartDate();

    // If no success was logged today and it's a new day
    if (startDate.isBefore(DateTime(now.year, now.month, now.day))) {
      await streakService.logFailure();
    }
  }

  Future<bool> requestExactAlarmPermission() async {
    // The method 'requestExactAlarmsPermission' does not exist in the plugin.
    // You may need to handle permissions manually or via another package if required.
    debugPrint('requestExactAlarmsPermission is not implemented.');
    return false;
  }
}
