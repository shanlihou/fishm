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
