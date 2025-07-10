// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'streak_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class StreakAdapter extends TypeAdapter<Streak> {
  @override
  final int typeId = 0;

  @override
  Streak read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Streak(
      startDate: fields[0] as DateTime,
      currentStreak: fields[1] as int,
      history: (fields[2] as List).cast<StreakHistory>(),
    );
  }

  @override
  void write(BinaryWriter writer, Streak obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.startDate)
      ..writeByte(1)
      ..write(obj.currentStreak)
      ..writeByte(2)
      ..write(obj.history);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StreakAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class StreakHistoryAdapter extends TypeAdapter<StreakHistory> {
  @override
  final int typeId = 1;

  @override
  StreakHistory read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return StreakHistory(
      startDate: fields[0] as DateTime,
      endDate: fields[1] as DateTime,
      days: fields[2] as int,
    );
  }

  @override
  void write(BinaryWriter writer, StreakHistory obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.startDate)
      ..writeByte(1)
      ..write(obj.endDate)
      ..writeByte(2)
      ..write(obj.days);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StreakHistoryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
