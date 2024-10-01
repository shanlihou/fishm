// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'read_history_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ReadHistoryModelAdapter extends TypeAdapter<ReadHistoryModel> {
  @override
  final int typeId = 5;

  @override
  ReadHistoryModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ReadHistoryModel(
      fields[0] as String,
      fields[1] as int,
    );
  }

  @override
  void write(BinaryWriter writer, ReadHistoryModel obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.chapterId)
      ..writeByte(1)
      ..write(obj.index);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReadHistoryModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
