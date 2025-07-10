import 'package:test_thy_self/data/models/streak_model.dart';
import 'package:test_thy_self/data/repositories/streak_repository.dart';

class StreakService {
  final StreakRepository _repository;

  StreakService(this._repository);

  Future<void> startTracking() async {
    final current = await _repository.getCurrentStreak();
    if (current == null) {
      await _repository.saveCurrentStreak(Streak(
        startDate: DateTime.now(),
        currentStreak: 0,
        history: [],
      ));
    }
  }

  Future<void> logSuccess() async {
    await _repository.incrementStreak();
  }

  Future<void> logFailure() async {
    await _repository.resetStreak();
  }

  Future<int> getCurrentStreakDays() async {
    final current = await _repository.getCurrentStreak();
    return current?.currentStreak ?? 0;
  }

  Future<DateTime> getCurrentStreakStartDate() async {
    final current = await _repository.getCurrentStreak();
    return current?.startDate ?? DateTime.now();
  }

  Future<List<StreakHistory>> getStreakHistory() async {
    final current = await _repository.getCurrentStreak();
    return current?.history ?? [];
  }
}
