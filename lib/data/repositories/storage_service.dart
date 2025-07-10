import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_constants.dart';
import '../models/streak_model.dart';

class StorageService {
  static late final Box<Streak> _streakBox;
  static late final Box _settingsBox;
  static late SharedPreferences _prefs;

  static Future<void> init() async {
    try {
      final appDocumentDir = await getApplicationDocumentsDirectory();
      Hive.init(appDocumentDir.path);

      if (!Hive.isAdapterRegistered(0)) {
        Hive.registerAdapter(StreakAdapter());
      }
      if (!Hive.isAdapterRegistered(1)) {
        Hive.registerAdapter(StreakHistoryAdapter());
      }

      _streakBox = await Hive.openBox<Streak>(AppConstants.streakBox);
      _settingsBox = await Hive.openBox(AppConstants.settingsBox);
      _prefs = await SharedPreferences.getInstance();
    } catch (e) {
      throw Exception('Failed to initialize storage: $e');
    }
  }

  static Future<void> ensureInitialized() async {
    if (!_streakBox.isOpen || !_settingsBox.isOpen) {
      await init();
    }
  }

  // Getters for boxes
  static Box<Streak> get streakBox => _streakBox;
  static Box get settingsBox => _settingsBox;

  // SharedPreferences methods
  static bool get firstLaunch => _prefs.getBool(AppConstants.firstLaunchKey) ?? true;
  
  static Future<void> setFirstLaunch(bool value) async {
    await _prefs.setBool(AppConstants.firstLaunchKey, value);
  }

  static bool get authEnabled => _prefs.getBool(AppConstants.authEnabledKey) ?? false;
  
  static Future<void> setAuthEnabled(bool value) async {
    await _prefs.setBool(AppConstants.authEnabledKey, value);
  }

  

  static bool get useBiometrics => _settingsBox.get('useBiometrics', defaultValue: false);

static Future<void> setUseBiometrics(bool value) async {
  await _settingsBox.put('useBiometrics', value);
  await _settingsBox.flush();
}
}