// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SettingsAdapter extends TypeAdapter<Settings> {
  @override
  final int typeId = 0;

  @override
  Settings read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Settings(
      (fields[0] as List).cast<String>(),
      fields[1] == null ? '' : fields[1] as String,
      fields[2] == null ? '' : fields[2] as String,
      fields[3] == null ? false : fields[3] as bool,
      fields[4] == null ? '' : fields[4] as String,
      fields[5] == null ? 0 : fields[5] as int,
      fields[6] == null ? false : fields[6] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, Settings obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.sources)
      ..writeByte(1)
      ..write(obj.localMainLuaDeubugPath)
      ..writeByte(2)
      ..write(obj.language)
      ..writeByte(3)
      ..write(obj.enableProxy)
      ..writeByte(4)
      ..write(obj.proxyHost)
      ..writeByte(5)
      ..write(obj.proxyPort)
      ..writeByte(6)
      ..write(obj.landscape);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SettingsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
