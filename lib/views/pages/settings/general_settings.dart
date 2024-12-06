import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter_gen/gen_l10n/localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:toonfu/const/color_const.dart';
import 'package:toonfu/const/general_const.dart';

import '../../../common/log.dart';
import '../../../const/assets_const.dart';
import '../../../types/provider/comic_provider.dart';
import '../../../types/provider/local_provider.dart';
import '../../../types/provider/setting_provider.dart';
import '../../../utils/utils_general.dart';
import '../../../utils/utils_widget.dart';
import '../../dialog/loading_dialog.dart';

class GeneralSettings extends StatefulWidget {
  const GeneralSettings({super.key});

  @override
  State<GeneralSettings> createState() => _GeneralSettingsState();
}

class _GeneralSettingsState extends State<GeneralSettings> {
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

  Widget _buildLanguage(
      BuildContext context, String language, String languageCode) {
    return GestureDetector(
      onTap: () {
        context.read<LocalProvider>().setLocale(Locale(languageCode));
        context.read<SettingProvider>().settings?.language = languageCode;
        context.read<SettingProvider>().saveSettings();
      },
      child: Container(
        color: CupertinoColors.white,
        padding: EdgeInsets.all(20.r),
        child:
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(language),
          if (context.read<LocalProvider>().locale.languageCode == languageCode)
            Icon(
              CupertinoIcons.checkmark,
            ),
        ]),
      ),
    );
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
            buildCommonBase(
                context, generalBig, AppLocalizations.of(context)!.general),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(color: CupertinoColors.systemGrey),
              ),
              margin: EdgeInsets.all(20.r),
              child: Row(
                children: [
                  Container(
                    margin: EdgeInsets.all(20.r),
                    child: Text(AppLocalizations.of(context)!.language),
                  ),
                  Expanded(
                    child: Consumer<LocalProvider>(
                      builder: (context, provider, child) => Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLanguage(context, '中文', 'zh'),
                          Container(
                            height: 1.h,
                            color: CupertinoColors.systemGrey,
                          ),
                          _buildLanguage(context, 'English', 'en'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: _clearAll,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: CupertinoColors.white,
                  border: Border.all(color: CupertinoColors.systemGrey),
                ),
                margin: EdgeInsets.all(20.r),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(AppLocalizations.of(context)!.clear),
                    Image.asset(extensionDelete),
                  ],
                ),
              ),
            ),
            Container(
              width: double.infinity,
              child: Row(
                children: [
                  Text('横竖'),
                  Consumer<SettingProvider>(
                    builder: (context, provider, child) => CupertinoSwitch(
                      value: provider.settings?.landscape ?? false,
                      onChanged: (value) {
                        provider.settings?.landscape = value;
                        provider.saveSettings();
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
