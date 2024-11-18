import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter_gen/gen_l10n/localizations.dart';
import 'package:provider/provider.dart';
import 'package:toonfu/const/general_const.dart';

import '../../../common/log.dart';
import '../../../types/provider/comic_provider.dart';
import '../../../types/provider/local_provider.dart';
import '../../../types/provider/setting_provider.dart';
import '../../../utils/utils_general.dart';
import '../../dialog/loading_dialog.dart';

class GeneralSettings extends StatefulWidget {
  const GeneralSettings({super.key});

  @override
  State<GeneralSettings> createState() => _GeneralSettingsState();
}

class _GeneralSettingsState extends State<GeneralSettings> {
  void _showLanguagePicker(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        title: Text(AppLocalizations.of(context)!.language),
        actions: <CupertinoActionSheetAction>[
          CupertinoActionSheetAction(
            child: const Text('中文'),
            onPressed: () {
              Navigator.pop(context);
              context.read<LocalProvider>().setLocale(const Locale('zh'));
              context.read<SettingProvider>().settings?.language = "zh";
              context.read<SettingProvider>().saveSettings();
            },
          ),
          CupertinoActionSheetAction(
            child: const Text('English'),
            onPressed: () {
              Navigator.pop(context);
              context.read<LocalProvider>().setLocale(const Locale('en'));
              context.read<SettingProvider>().settings?.language = "en";
              context.read<SettingProvider>().saveSettings();
            },
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          child: Text(AppLocalizations.of(context)!.cancel),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
    );
  }

  Future<void> _clearAll() async {
    var entry = showLoadingDialog(context);
    var root = Directory(archiveImageDir);
    for (var extensionPath in root.listSync()) {
      var extensionDir = Directory(extensionPath.path);
      for (var comicDir in extensionDir.listSync()) {
        var extensionName = osPathSplit(extensionDir.path).last;
        var comicId = osPathSplit(comicDir.path).last;
        var comicUniqueId = getComicUniqueId(comicId, extensionName);
        if (context.read<ComicProvider>().getComicModel(comicUniqueId) ==
            null) {
          Log.instance.d('delete comic: $comicUniqueId');
          await comicDir.delete(recursive: true);
        }
      }
    }
    entry.remove();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(AppLocalizations.of(context)!.general),
      ),
      child: SafeArea(
        child: Column(
          children: [
            CupertinoButton(
              child: Consumer<LocalProvider>(
                builder: (context, provider, child) => Text(
                    '${AppLocalizations.of(context)!.language}: ${provider.locale}'),
              ),
              onPressed: () => _showLanguagePicker(context),
            ),
            CupertinoButton(
              onPressed: _clearAll,
              child: const Text('clear'),
            ),
          ],
        ),
      ),
    );
  }
}
