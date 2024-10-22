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

  @HiveField(3, defaultValue: false)
  bool enableProxy;

  @HiveField(4, defaultValue: "")
  String proxyHost;

  @HiveField(5, defaultValue: 0)
  int proxyPort;

  Settings(this.sources, this.localMainLuaDeubugPath, this.language,
      this.enableProxy, this.proxyHost, this.proxyPort);

  static Settings defaultSettings() {
    return Settings([], "", "", false, "", 0);
  }
}
