// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sub_destination.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SubDestinationAdapter extends TypeAdapter<SubDestination> {
  @override
  final int typeId = 1;

  @override
  SubDestination read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SubDestination(
      name: fields[0] as String,
      startTime: fields[1] as DateTime,
      endTime: fields[2] as DateTime,
      note: fields[3] as String,
    );
  }

  @override
  void write(BinaryWriter writer, SubDestination obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.startTime)
      ..writeByte(2)
      ..write(obj.endTime)
      ..writeByte(3)
      ..write(obj.note);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SubDestinationAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
