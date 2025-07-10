import 'package:flutter/material.dart';
import 'package:test_thy_self/app.dart';
import 'package:test_thy_self/core/widgets/splash_screen.dart';
import 'package:test_thy_self/data/repositories/service_locator.dart';
import 'package:test_thy_self/data/repositories/storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Show splash screen while initializing
  runApp(const MaterialApp(
      debugShowCheckedModeBanner: false, 
      home: SplashScreen()));

  try {
    await StorageService.init();
    await ServiceLocator.instance.init();

    // Schedule notifications
    await ServiceLocator.instance.notificationService
        .scheduleDailyNotifications();

    // Check for missed notifications at startup
    await ServiceLocator.instance.notificationService
        .checkForMissedNotifications();
  } catch (e) {
    debugPrint('Initialization error: $e');
  }

  runApp(const ProgressTrackerApp());
}
