import 'dart:io';

import 'package:archive/archive.dart';
import 'package:dio/dio.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:toonfu/const/path.dart';
import 'package:yaml/yaml.dart';
import '../../common/log.dart';
import '../../const/general_const.dart';
import '../../const/lua_const.dart';
import '../../models/db/extensions.dart' as model_extensions;
import '../../types/manager/actions.dart';
import '../../types/provider/extension_provider.dart';
import '../../types/provider/setting_provider.dart';
import '../../utils/utils_general.dart';
import 'package:flutter_gen/gen_l10n/localizations.dart';

import 'extension/extension_installed_tab.dart';
import 'extension/extension_store_tab.dart';

class ExtensionsTab extends StatefulWidget {
  const ExtensionsTab({super.key});

  @override
  State<ExtensionsTab> createState() => _ExtensionsTabState();
}

class _ExtensionsTabState extends State<ExtensionsTab> {
  final List<model_extensions.Extension> _remoteExtensions = [];
  bool _isInitContext = false;
  bool _isLoadingRemote = false;
  BuildContext? _buildCtx;
  List<String> _tabs = ['installed', 'store'];

  ValueNotifier<int> _curPage = ValueNotifier(0);

  @override
  void initState() {
    super.initState();
    _isLoadingRemote = true;
  }

  Future<void> _initWithContext(BuildContext context) async {
    if (_isInitContext) {
      return;
    }

    _isInitContext = true;
    List<String> sources = context.read<SettingProvider>().sources;
    await _loadRemoteExtensions(sources);
    _isLoadingRemote = false;
  }

  Future<void> _onRefresh() async {
    if (_isLoadingRemote) {
      return;
    }

    setState(() {
      _isLoadingRemote = true;
    });
    await _loadRemoteExtensions(context.read<SettingProvider>().sources);
    setState(() {
      _isLoadingRemote = false;
    });
  }

  Future<void> _loadRemoteExtensionsFromNet(String source) async {
    Dio dio = Dio();
    await dio.download(source, tempSrcDownloadPath);
    final srcFileContent = await File(tempSrcDownloadPath).readAsString();
    var doc = loadYaml(srcFileContent);
    for (var ext in doc[yamlExtensionKey]) {
      _remoteExtensions.add(model_extensions.Extension.fromYaml(ext));
    }
  }

  Future<void> _loadRemoteExtensionsFromFile(String path) async {
    final srcFileContent = await File(path).readAsString();
    var doc = loadYaml(srcFileContent);
    for (var ext in doc[yamlExtensionKey]) {
      _remoteExtensions.add(model_extensions.Extension.fromYaml(ext));
    }
  }

  Future<void> _loadRemoteExtensions(List<String> sources) async {
    for (var src in sources) {
      try {
        if (src.startsWith('http')) {
          await _loadRemoteExtensionsFromNet(src);
        } else {
          await _loadRemoteExtensionsFromFile(src);
        }
      } catch (e) {
        Log.instance.e('_loadRemoteExtensions error $src: $e');
      }
    }

    if (mounted) {
      setState(() {});
    }
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
      print(filename);
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
    setState(() {});

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

    if (_buildCtx != null) {
      print('updateExtension');
      _buildCtx!.read<ExtensionProvider>().updateExtension(clone);
    }
    actionsManager.resetMainLua();
    setState(() {});
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
                child: Text('Cancel')),
            CupertinoButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text('Install')),
          ],
        );
      },
    );
  }

  Widget buildExtensionItem(model_extensions.Extension ext, bool isInstalled,
      BuildContext buildContext) {
    return GestureDetector(
      onTap: () async {
        if (isInstalled) {
          // TODO: show extension detail
        } else {
          if (await _showInstallConfirmDialog(ext) ?? false) {
            _installExtension(ext, buildContext);
          }
        }
      },
      child: Row(
        children: [
          Column(
            children: [
              Text(ext.name),
              Text(ext.version),
            ],
          ),
          Text(isInstalled ? 'status' : ''),
        ],
      ),
    );
  }

  Widget buildExtensionList(BuildContext context, String title,
      List<model_extensions.Extension>? exts, bool isInstalled) {
    return Expanded(
      child: Column(
        children: [
          Expanded(flex: 1, child: Text(title)),
          Expanded(
            flex: 9,
            child: EasyRefresh(
              onRefresh: _onRefresh,
              child: ListView.builder(
                itemCount: exts?.length ?? 0,
                itemBuilder: (context, index) {
                  return buildExtensionItem(exts![index], isInstalled, context);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getTabTitle(int index) {
    String title = _tabs[index];
    if (title == 'installed') {
      return AppLocalizations.of(context)!.installed;
    } else if (title == 'store') {
      return AppLocalizations.of(context)!.store;
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> tabs = [];
    for (int i = 0; i < _tabs.length; i++) {
      tabs.add(GestureDetector(
        onTap: () {
          _curPage.value = i;
        },
        child: Center(
          child: Column(
            children: [
              Text(_getTabTitle(i)),
              ValueListenableBuilder(
                valueListenable: _curPage,
                builder: (context, value, child) {
                  return Container(
                    height: 1,
                    width: 0.1.sw,
                    color: value == i
                        ? CupertinoColors.black
                        : CupertinoColors.transparent,
                  );
                },
              ),
            ],
          ),
        ),
      ));
    }

    return Column(
      children: [
        Expanded(
          flex: 1,
          child: Row(
            children: tabs,
          ),
        ),
        Expanded(
          flex: 9,
          child: PageView(
            controller: PageController(),
            physics: const NeverScrollableScrollPhysics(),
            children: [
              const ExtensionInstalledTab(),
              const ExtensionStoreTab(),
            ],
          ),
        ),
      ],
    );
  }
}
