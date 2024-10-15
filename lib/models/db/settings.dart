import 'package:hive/hive.dart';

part 'settings.g.dart';

@HiveType(typeId: 0)
class Settings {
  @HiveField(0)
  final List<String> sources;

  @HiveField(1, defaultValue: "")
  String localMainLuaDeubugPath;

  @HiveField(2, defaultValue: "")
  String language;

  Settings(this.sources, this.localMainLuaDeubugPath, this.language);

  static Settings defaultSettings() {
    return Settings([], "", "");
  }
}
