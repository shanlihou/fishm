import 'dart:io';

import 'package:archive/archive.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:yaml/yaml.dart';

import '../common/log.dart';
import '../const/general_const.dart';
import '../const/lua_const.dart';
import '../const/path.dart';
import '../models/db/extensions.dart' as model_extensions;
import '../types/common/alias.dart';

void openAppSettings() {
  if (Platform.isAndroid) {}
}

Future<bool> getStoragePermission() async {
  late PermissionStatus status;
  if (Platform.isAndroid) {
    status = await Permission.storage.request();
  } else {
    // TODO: check iOS permission
    return true;
  }

  return status == PermissionStatus.granted;
}

Future<void> initDirectory() async {
  if (!await getStoragePermission()) {
    Log.instance.e("no storage permission");
    return;
  }

  if (Platform.isAndroid) {
    var externalDir = await getExternalStorageDirectory();
    var applicationDir = await getApplicationDocumentsDirectory();
    Directory.current = externalDir ?? applicationDir;
  }

  Log.instance.d('external: ${Directory.current}');
}

Future<void> downloadMainLua() async {
  Dio dio = Dio();
  for (var url in mainRelease) {
    try {
      await dio.download(url, mainYamlDownloadPath);
    } catch (e) {
      Log.instance.e('downloadMainLuaTmp down yaml error: $e');
      continue;
    }

    final mainContent = await File(mainYamlDownloadPath).readAsString();
    var doc = loadYaml(mainContent);
    for (var data in doc[yamlMainKey]) {
      try {
        await downloadMainLuaByUrl(data['url']);
        return;
      } catch (e) {
        Log.instance.e('downloadMainLuaTmp down url: ${data['url']} error: $e');
        continue;
      }
    }
  }
}

Future<void> downloadMainLuaByUrl(String mainUrl) async {
  // download repo zip and then unzip to code, the url is mainRelease
  Dio dio = Dio();
  await dio.download(mainUrl, mainReleaseDownloadPath);
  // unzip to code without first class folder
  final bytes = await File(mainReleaseDownloadPath).readAsBytes();
  final archive = ZipDecoder().decodeBytes(bytes);
  for (final file in archive) {
    String filename = file.name;
    if (filename.contains('/')) {
      filename = filename.substring(filename.indexOf('/') + 1);
    }
    print(filename);
    if (file.isFile) {
      final data = file.content as List<int>;
      File('$mainDir/$filename')
        ..createSync(recursive: true)
        ..writeAsBytesSync(data);
    }
  }
}

Future<void> copyDir(String source, String target) async {
  final sourceDir = Directory(source);
  final targetDir = Directory(target);

  if (!await targetDir.exists()) {
    await targetDir.create(recursive: true);
  }

  await for (var entity in sourceDir.list(recursive: true)) {
    if (entity is File) {
      final relativePath = entity.path.substring(sourceDir.path.length + 1);
      final newFile = File('${targetDir.path}/$relativePath');
      if (await newFile.exists()) {
        await newFile.delete();
      }
      await newFile.create(recursive: true);
      await entity.copy(newFile.path);
    }
  }
}

Future<void> copyMainLuaLocal(String mainLuaDebugPath) async {
  await copyDir(mainLuaDebugPath, mainDir);
}

Future<void> resetMainLua(String mainLuaDebugPath) async {
  if (mainLuaDebugPath.isEmpty) {
    await downloadMainLua();
  } else {
    await copyMainLuaLocal(mainLuaDebugPath);
  }
}

Future<void> initMainLua(String mainLuaDebugPath) async {
  if (!(await File('$mainDir/main.lua').exists())) {
    await resetMainLua(mainLuaDebugPath);
  }
}

int getTimestamp() {
  return DateTime.now().millisecondsSinceEpoch ~/ 1000;
}

String getComicUniqueId(String id, String extensionName) {
  return '$id-$extensionName';
}

int bitSet(int flags, int flag, bool value) {
  if (value) {
    return flags | (1 << flag);
  } else {
    return flags & ~(1 << flag);
  }
}

bool bitGet(int flags, int flag) {
  return (flags & (1 << flag)) != 0;
}

/// return 1 if version1 > version2, -1 if version1 < version2, 0 if version1 == version2
int judgeVersion(String version1, String version2) {
  var v1 = version1.split('.');
  var v2 = version2.split('.');
  if (v1.length != v2.length) {
    return v1.length - v2.length;
  }

  for (var i = 0; i < v1.length; i++) {
    if (int.parse(v1[i]) > int.parse(v2[i])) {
      return 1;
    } else if (int.parse(v1[i]) < int.parse(v2[i])) {
      return -1;
    }
  }

  return 0;
}

Future<void> _downloadExtension(model_extensions.Extension extension) async {
  Dio dio = Dio();
  await dio.download(extension.url, tempExtDownloadPath);
  final bytes = await File(tempExtDownloadPath).readAsBytes();
  final archive = ZipDecoder().decodeBytes(bytes);
  for (final file in archive) {
    String filename = file.name;
    if (filename.contains('/')) {
      filename = filename.substring(filename.indexOf('/') + 1);
    }
    if (file.isFile) {
      final data = file.content as List<int>;
      File('$pluginDir/${extension.name}/$filename')
        ..createSync(recursive: true)
        ..writeAsBytesSync(data);
    }
  }
}

Future<void> _copyLocalExtension(model_extensions.Extension extension) async {
  await copyDir(extension.url, '$pluginDir/${extension.name}');
}

Future<model_extensions.Extension?> installExtension(
    model_extensions.Extension extension) async {
  try {
    if (extension.url.startsWith("http")) {
      await _downloadExtension(extension);
    } else {
      await _copyLocalExtension(extension);
    }
  } catch (e) {
    Log.instance.e('_installExtension error $extension: $e');
    return null;
  }

  var clone = extension.clone();
  clone.status = extensionStatusInstalled;
  return clone;
}

Future<Exts> _loadRemoteExtensionsFromNet(String source) async {
  Exts extensions = [];
  Dio dio = Dio();
  await dio.download(source, tempSrcDownloadPath);
  final srcFileContent = await File(tempSrcDownloadPath).readAsString();
  Log.instance.d('srcFileContent: $srcFileContent');
  var doc = loadYaml(srcFileContent);
  for (var ext in doc[yamlExtensionKey]) {
    extensions.add(model_extensions.Extension.fromYaml(ext));
  }
  return extensions;
}

Future<Exts> _loadRemoteExtensionsFromFile(String path) async {
  Exts extensions = [];
  final srcFileContent = await File(path).readAsString();
  var doc = loadYaml(srcFileContent);
  for (var ext in doc[yamlExtensionKey]) {
    extensions.add(model_extensions.Extension.fromYaml(ext));
  }
  return extensions;
}

Future<Exts> loadRemoteExtensions(List<String> sources) async {
  Exts extensions = [];
  for (var src in sources) {
    try {
      if (src.startsWith('http')) {
        extensions = mergeExtensions(
            extensions, await _loadRemoteExtensionsFromNet(src));
      } else {
        extensions = mergeExtensions(
            extensions, await _loadRemoteExtensionsFromFile(src));
      }
    } catch (e, s) {
      Log.instance.e('_loadRemoteExtensions error $src: $e, stackTrace: $s');
    }
  }
  return extensions;
}

Exts mergeExtensions(Exts extensions1, Exts extensions2) {
  for (var ext in extensions2) {
    int index = extensions1.indexWhere((e) => e.name == ext.name);
    if (index != -1) {
      if (judgeVersion(extensions1[index].version, ext.version) < 0) {
        extensions1[index] = ext;
      }
    } else {
      extensions1.add(ext);
    }
  }
  return extensions1;
}
