import 'package:hive/hive.dart';
import '../models/streak_model.dart';

class StreakRepository {
  final Box<Streak> _streakBox;

  StreakRepository(this._streakBox);

  Future<Streak?> getCurrentStreak() async {
    return _streakBox.get('current');
  }

  Future<void> saveCurrentStreak(Streak streak) async {
    await _streakBox.put('current', streak);
  }

  Future<void> resetStreak() async {
    final current = await getCurrentStreak();
    if (current != null) {
      final history = current.history.toList()
        ..add(StreakHistory(
          startDate: current.startDate,
          endDate: DateTime.now(),
          days: current.currentStreak,
        ));
      
      await _streakBox.put('current', Streak(
        startDate: DateTime.now(),
        currentStreak: 0,
        history: history,
      ));
    } else {
      await _streakBox.put('current', Streak(
        startDate: DateTime.now(),
        currentStreak: 0,
        history: [],
      ));
    }
  }

  Future<void> incrementStreak() async {
    final current = await getCurrentStreak();
    if (current != null) {
      await _streakBox.put('current', Streak(
        startDate: current.startDate,
        currentStreak: current.currentStreak + 1,
        history: current.history,
      ));
    } else {
      await _streakBox.put('current', Streak(
        startDate: DateTime.now(),
        currentStreak: 1,
        history: [],
      ));
    }
  }

  Future<List<StreakHistory>> getStreakHistory() async {
    final current = await getCurrentStreak();
    return current?.history ?? [];
  }
}
