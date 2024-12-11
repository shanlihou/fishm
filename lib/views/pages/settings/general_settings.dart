import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter_gen/gen_l10n/localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:toonfu/const/general_const.dart';

import '../../../common/log.dart';
import '../../../const/assets_const.dart';
import '../../../const/color_const.dart';
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
  Future<void> _clearAll(BuildContext context) async {
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
    if (context.mounted) {
      showCupertinoToast(context: context, message: '已清除');
    }
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
        height: 120.h,
        color: CupertinoColors.white,
        padding:
            EdgeInsets.only(left: 40.w, right: 40.w, top: 20.h, bottom: 20.h),
        child:
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(language),
          if (context.read<LocalProvider>().locale.languageCode == languageCode)
            Icon(
              size: 60.r,
              CupertinoIcons.checkmark,
            ),
        ]),
      ),
    );
  }

  Widget _buildLandscape(SettingProvider provider, String title, bool value) {
    return GestureDetector(
      onTap: () {
        provider.settings?.landscape = value;
        provider.saveSettings();
      },
      child: Container(
        height: 120.h,
        color: CupertinoColors.white,
        padding:
            EdgeInsets.only(left: 40.w, right: 40.w, top: 20.h, bottom: 20.h),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title),
            if (value == provider.settings?.landscape)
              Icon(
                size: 60.r,
                CupertinoIcons.checkmark,
              ),
          ],
        ),
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
                borderRadius: BorderRadius.circular(20.r),
                boxShadow: [
                  BoxShadow(
                    color: settingBoxShadowColor,
                    blurRadius: 10.r,
                  ),
                ],
                border: Border.all(color: settingBoxColor),
              ),
              margin: EdgeInsets.all(40.r),
              child: Consumer<LocalProvider>(
                builder: (context, provider, child) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLanguage(context, '中文', 'zh'),
                    Container(
                      margin: EdgeInsets.only(left: 50.w, right: 50.w),
                      height: 1.h,
                      color: settingBoxColor,
                    ),
                    _buildLanguage(context, 'English', 'en'),
                  ],
                ),
              ),
            ),
            Container(
              width: double.infinity,
              margin: EdgeInsets.only(left: 40.w, right: 40.w),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20.r),
                boxShadow: [
                  BoxShadow(
                    color: settingBoxShadowColor,
                    blurRadius: 10.r,
                  ),
                ],
                border: Border.all(color: settingBoxColor),
              ),
              child: Consumer<SettingProvider>(
                builder: (context, provider, child) => Column(
                  children: [
                    _buildLandscape(provider, '横屏', true),
                    Container(
                      margin: EdgeInsets.only(left: 50.w, right: 50.w),
                      height: 1.h,
                      color: settingBoxColor,
                    ),
                    _buildLandscape(provider, '竖屏', false),
                  ],
                ),
              ),
            ),
            GestureDetector(
              onTap: () => _clearAll(context),
              child: Container(
                width: double.infinity,
                height: 120.h,
                decoration: BoxDecoration(
                  color: CupertinoColors.white,
                  border: Border.all(color: settingBoxColor),
                  boxShadow: [
                    BoxShadow(
                      color: settingBoxShadowColor,
                      blurRadius: 10.r,
                    ),
                  ],
                ),
                margin: EdgeInsets.all(40.r),
                padding: EdgeInsets.only(
                    left: 40.w, right: 40.w, top: 20.h, bottom: 20.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(AppLocalizations.of(context)!.clear),
                    Icon(CupertinoIcons.delete, size: 60.w),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
