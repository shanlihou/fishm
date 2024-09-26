import 'dart:io';

import 'package:archive/archive.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import '../common/log.dart';
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
  // download repo zip and then unzip to code, the url is mainRelease
  Dio dio = Dio();
  await dio.download(mainRelease, mainReleaseDownloadPath);
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

Future<void> copyMainLuaLocal() async {
  await copyDir(mainReleaseLocal, mainDir);
}

Future<void> resetMainLua() async {
  if (mainReleaseLocal.isEmpty) {
    await downloadMainLua();
  } else {
    await copyMainLuaLocal();
  }
}

Future<void> initMainLua() async {
  if (!(await File('$mainDir/main.lua').exists())) {
    await resetMainLua();
  }
}

int getTimestamp() {
  return DateTime.now().millisecondsSinceEpoch ~/ 1000;
}
