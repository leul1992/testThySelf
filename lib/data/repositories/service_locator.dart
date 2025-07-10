import 'package:test_thy_self/core/services/auth_service.dart';
import 'package:test_thy_self/core/services/notification_service.dart';
import 'package:test_thy_self/core/services/streak_service.dart';
import 'package:test_thy_self/data/repositories/storage_service.dart';
import 'package:test_thy_self/data/repositories/streak_repository.dart';

class ServiceLocator {
  static final ServiceLocator instance = ServiceLocator._internal();

  late final StreakRepository streakRepository;
  late final StreakService streakService;
  late final AuthService authService;
  late final NotificationService notificationService;

  ServiceLocator._internal();

  Future<void> init() async {
    try {
      // Initialize services
      authService = AuthService();
      notificationService = NotificationService();
      await notificationService.init();
      
      // Initialize repositories
      streakRepository = StreakRepository(StorageService.streakBox);

      // Initialize services
      streakService = StreakService(streakRepository);
    } catch (e) {
      throw Exception('Failed to initialize ServiceLocator: $e');
    }
  }
}
