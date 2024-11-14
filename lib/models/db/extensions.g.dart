// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'extensions.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ExtensionAdapter extends TypeAdapter<Extension> {
  @override
  final int typeId = 1;

  @override
  Extension read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Extension(
      fields[0] as String,
      fields[1] as String,
      fields[2] as int,
      fields[3] as String,
      fields[4] == null ? '' : fields[4] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Extension obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.url)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.status)
      ..writeByte(3)
      ..write(obj.version)
      ..writeByte(4)
      ..write(obj.alias);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExtensionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ExtensionsAdapter extends TypeAdapter<Extensions> {
  @override
  final int typeId = 2;

  @override
  Extensions read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Extensions(
      (fields[0] as List).cast<Extension>(),
    );
  }

  @override
  void write(BinaryWriter writer, Extensions obj) {
    writer
      ..writeByte(1)
      ..writeByte(0)
      ..write(obj.extensions);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExtensionsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
