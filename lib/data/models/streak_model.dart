import 'package:hive/hive.dart';

part 'streak_model.g.dart';

@HiveType(typeId: 0)
class Streak {
  @HiveField(0)
  final DateTime startDate;
  
  @HiveField(1)
  final int currentStreak;
  
  @HiveField(2)
  final List<StreakHistory> history;

  Streak({
    required this.startDate,
    required this.currentStreak,
    required this.history,
  });
}

@HiveType(typeId: 1)
class StreakHistory {
  @HiveField(0)
  final DateTime startDate;
  
  @HiveField(1)
  final DateTime endDate;
  
  @HiveField(2)
  final int days;

  StreakHistory({
    required this.startDate,
    required this.endDate,
    required this.days,
  });
}
