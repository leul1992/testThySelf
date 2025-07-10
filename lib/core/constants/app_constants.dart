import 'dart:ui';

class AppConstants {
  static const String appName = 'Progress Tracker';
  static const Color primaryColor = Color(0xFF6C63FF);
  
  // Notification channels
  static const String notificationChannelId = 'progress_tracker_channel';
  static const String notificationChannelName = 'Progress Tracker Notifications';
  static const String notificationChannelDesc = 'Progress tracking reminders';
  
  // Hive boxes
  static const String streakBox = 'streak_box';
  static const String settingsBox = 'settings_box';
  
  // SharedPreferences keys
  static const String firstLaunchKey = 'first_launch';
  static const String authEnabledKey = 'auth_enabled';
}
