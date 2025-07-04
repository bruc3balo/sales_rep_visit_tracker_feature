// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'local_models.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UnSyncedLocalVisitAdapter extends TypeAdapter<UnSyncedLocalVisit> {
  @override
  final int typeId = 0;

  @override
  UnSyncedLocalVisit read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UnSyncedLocalVisit(
      hash: fields[1] as String,
      customerIdVisited: fields[2] as int,
      visitDate: fields[3] as DateTime,
      status: fields[4] as String,
      location: fields[5] as String,
      notes: fields[6] as String,
      activityIdsDone: (fields[7] as List).cast<int>(),
      createdAt: fields[8] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, UnSyncedLocalVisit obj) {
    writer
      ..writeByte(8)
      ..writeByte(1)
      ..write(obj.hash)
      ..writeByte(2)
      ..write(obj.customerIdVisited)
      ..writeByte(3)
      ..write(obj.visitDate)
      ..writeByte(4)
      ..write(obj.status)
      ..writeByte(5)
      ..write(obj.location)
      ..writeByte(6)
      ..write(obj.notes)
      ..writeByte(7)
      ..write(obj.activityIdsDone)
      ..writeByte(8)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UnSyncedLocalVisitAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class LocalActivityAdapter extends TypeAdapter<LocalActivity> {
  @override
  final int typeId = 1;

  @override
  LocalActivity read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return LocalActivity(
      id: fields[0] as int,
      description: fields[1] as String,
      createdAt: fields[2] as DateTime,
      updatedAt: fields[3] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, LocalActivity obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.description)
      ..writeByte(2)
      ..write(obj.createdAt)
      ..writeByte(3)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LocalActivityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class LocalCustomerAdapter extends TypeAdapter<LocalCustomer> {
  @override
  final int typeId = 2;

  @override
  LocalCustomer read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return LocalCustomer(
      id: fields[0] as int,
      name: fields[1] as String,
      createdAt: fields[2] as DateTime,
      updatedAt: fields[3] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, LocalCustomer obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.createdAt)
      ..writeByte(3)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LocalCustomerAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class LocalVisitStatisticsAdapter extends TypeAdapter<LocalVisitStatistics> {
  @override
  final int typeId = 3;

  @override
  LocalVisitStatistics read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return LocalVisitStatistics(
      statistics: (fields[0] as Map).cast<String, int>(),
      createdAt: fields[1] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, LocalVisitStatistics obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.statistics)
      ..writeByte(1)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LocalVisitStatisticsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
