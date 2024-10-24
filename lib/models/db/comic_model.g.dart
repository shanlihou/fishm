// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'comic_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ChapterModelAdapter extends TypeAdapter<ChapterModel> {
  @override
  final int typeId = 4;

  @override
  ChapterModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ChapterModel(
      fields[0] as String,
      fields[1] as String,
      fields[2] == null ? [] : (fields[2] as List).cast<String>(),
      fields[3] == null ? '{}' : fields[3] as String,
    );
  }

  @override
  void write(BinaryWriter writer, ChapterModel obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.images)
      ..writeByte(3)
      ..write(obj._extra);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChapterModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ComicModelAdapter extends TypeAdapter<ComicModel> {
  @override
  final int typeId = 3;

  @override
  ComicModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ComicModel(
      fields[0] as String,
      fields[1] as String,
      fields[2] == null ? '{}' : fields[2] as String,
      (fields[3] as List).cast<ChapterModel>(),
      fields[4] as String,
      fields[5] as String,
    );
  }

  @override
  void write(BinaryWriter writer, ComicModel obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj._extra)
      ..writeByte(3)
      ..write(obj.chapters)
      ..writeByte(4)
      ..write(obj.cover)
      ..writeByte(5)
      ..write(obj.extensionName);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ComicModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
