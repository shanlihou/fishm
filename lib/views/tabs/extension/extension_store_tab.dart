import 'dart:io';

import 'package:archive/archive.dart';
import 'package:dio/dio.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:yaml/yaml.dart';

import '../../../common/log.dart';
import '../../../const/general_const.dart';
import '../../../const/lua_const.dart';
import '../../../const/path.dart';
import '../../../models/db/extensions.dart' as model_extensions;
import '../../../types/manager/actions.dart';
import '../../../types/provider/extension_provider.dart';
import '../../../types/provider/setting_provider.dart';
import '../../../utils/utils_general.dart';

typedef Exts = List<model_extensions.Extension>;

class ExtensionStoreTab extends StatefulWidget {
  const ExtensionStoreTab({super.key});

  @override
  State<ExtensionStoreTab> createState() => _ExtensionStoreTabState();
}

class _ExtensionStoreTabState extends State<ExtensionStoreTab> {
  final EasyRefreshController _easyRefreshController =
      EasyRefreshController(controlFinishRefresh: true);
  final ValueNotifier<Exts> _extensions = ValueNotifier([]);

  @override
  void initState() {
    super.initState();
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

  Future<Exts> _loadRemoteExtensions(List<String> sources) async {
    Exts extensions = [];
    for (var src in sources) {
      try {
        if (src.startsWith('http')) {
          extensions = _mergeExtensions(
              extensions, await _loadRemoteExtensionsFromNet(src));
        } else {
          extensions = _mergeExtensions(
              extensions, await _loadRemoteExtensionsFromFile(src));
        }
      } catch (e, s) {
        Log.instance.e('_loadRemoteExtensions error $src: $e, stackTrace: $s');
      }
    }
    return extensions;
  }

  List<model_extensions.Extension> _mergeExtensions(
      List<model_extensions.Extension> extensions1,
      List<model_extensions.Extension> extensions2) {
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

  Future<void> _installExtension(
      model_extensions.Extension extension, BuildContext buildContext) async {
    ExtensionProvider extensionProvider =
        buildContext.read<ExtensionProvider>();

    try {
      if (extension.url.startsWith("http")) {
        await _downloadExtension(extension);
      } else {
        await _copyLocalExtension(extension);
      }
    } catch (e) {
      Log.instance.e('_installExtension error $extension: $e');
      setState(() {});
      return;
    }

    var clone = extension.clone();
    clone.status = extensionStatusInstalled;

    extensionProvider.updateExtension(clone);
    actionsManager.resetMainLua();
    Log.instance.d('installExtension: ok');
  }

  Future<bool?> _showInstallConfirmDialog(
      model_extensions.Extension extension) async {
    return await showCupertinoDialog<bool>(
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          title: Text('Install ${extension.name}?'),
          actions: [
            CupertinoButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel')),
            CupertinoButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Install')),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return EasyRefresh(
        controller: _easyRefreshController,
        onRefresh: () async {
          Exts extensions = await _loadRemoteExtensions(
              context.read<SettingProvider>().sources);
          _extensions.value = _mergeExtensions(extensions, _extensions.value);
          _easyRefreshController.finishRefresh(IndicatorResult.success);
        },
        child: ValueListenableBuilder(
          valueListenable: _extensions,
          builder: (context, extensions, child) {
            return ListView.builder(
              itemCount: extensions.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () async {
                    if (await _showInstallConfirmDialog(extensions[index]) ??
                        false) {
                      _installExtension(extensions[index], context);
                    }
                  },
                  child: Text(
                      '${extensions[index].name}: ${extensions[index].version}'),
                );
              },
            );
          },
        ));
  }
}
