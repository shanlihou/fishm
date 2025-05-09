import 'package:hive/hive.dart';
import 'package:yaml/yaml.dart';

import '../../const/general_const.dart';

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

  @HiveField(4, defaultValue: '')
  final String alias;

  Extension clone() {
    return Extension(url, name, status, version, alias);
  }

  Extension(this.url, this.name, this.status, this.version, this.alias);

  static Extension fromYaml(YamlMap json) {
    return Extension(json['url'], json['name'], extensionStatusRemote,
        json['version'], json['alias'] ?? "");
  }

  String get displayName {
    return alias.isEmpty ? name : alias;
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
