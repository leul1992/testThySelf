import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:test_thy_self/core/constants/app_theme.dart';
import 'package:test_thy_self/core/constants/routes.dart';
import 'package:test_thy_self/features/auth/auth_gate.dart';
import 'package:test_thy_self/features/home/home_screen.dart';
import 'package:test_thy_self/features/progress/progress_screen.dart';
import 'package:test_thy_self/features/settings/settings_screen.dart';
import 'package:test_thy_self/core/constants/app_constants.dart';
import 'package:test_thy_self/main_layout.dart';

class ProgressTrackerApp extends StatelessWidget {
  const ProgressTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en', 'US')],
      theme: AppThemes.lightTheme,
      darkTheme: AppThemes.darkTheme,
      themeMode: ThemeMode.system,
      initialRoute: AppRoutes.home,
      routes: {
        AppRoutes.home: (context) => const MainLayout(child: AuthGate(child: HomeScreen())),
        AppRoutes.progress: (context) => const MainLayout(child: AuthGate(child: ProgressScreen())),
        AppRoutes.settings: (context) => const MainLayout(child: AuthGate(child: SettingsScreen())),
      },
    );
  }
}
