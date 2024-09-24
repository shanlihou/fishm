import 'package:hive/hive.dart';

part 'settings.g.dart';

@HiveType(typeId: 0)
class Settings {
  @HiveField(0)
  final List<String> sources;

  Settings(this.sources);

  static Settings defaultSettings() {
    return Settings([]);
  }
}
