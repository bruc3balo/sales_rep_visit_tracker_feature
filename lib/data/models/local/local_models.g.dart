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
      customerIdVisited: fields[0] as int,
      visitDate: fields[1] as DateTime,
      status: fields[2] as String,
      location: fields[3] as String,
      notes: fields[4] as String,
      activityIdsDone: (fields[5] as List).cast<int>(),
      createdAt: fields[6] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, UnSyncedLocalVisit obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.customerIdVisited)
      ..writeByte(1)
      ..write(obj.visitDate)
      ..writeByte(2)
      ..write(obj.status)
      ..writeByte(3)
      ..write(obj.location)
      ..writeByte(4)
      ..write(obj.notes)
      ..writeByte(5)
      ..write(obj.activityIdsDone)
      ..writeByte(6)
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
