import 'package:hive/hive.dart';
import 'package:yaml/yaml.dart';

import '../../const/general.dart';

part 'extensions.g.dart';

@HiveType(typeId: 1)
class Extension {
  @HiveField(0)
  final String url;

  @HiveField(1)
  final String name;

  @HiveField(2)
  int status;

  @HiveField(3)
  final String version;

  Extension clone() {
    return Extension(url, name, status, version);
  }

  Extension(this.url, this.name, this.status, this.version);

  static Extension fromYaml(YamlMap json) {
    return Extension(
        json['url'], json['name'], extensionStatusRemote, json['version']);
  }
}

@HiveType(typeId: 2)
class Extensions {
  @HiveField(0)
  final List<Extension> extensions;

  static Extensions defaultExtensions() {
    return Extensions([]);
  }

  Extensions(this.extensions);
}
