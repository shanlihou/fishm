import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' as material;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:talker_flutter/talker_flutter.dart';
import 'package:toonfu/const/color_const.dart';
import 'package:flutter_gen/gen_l10n/localizations.dart';

import '../../common/log.dart';
import '../../const/assets_const.dart';
import '../pages/settings/about_page.dart';
import '../pages/settings/general_settings.dart';
import '../pages/settings/network_settings.dart';
import '../pages/settings/sources_settings.dart';

class MyTab extends StatelessWidget {
  const MyTab({super.key});

  Widget _buildSettingItem(
      BuildContext context, String icon, String title, WidgetBuilder? toPage,
      {VoidCallback? onPress = null}) {
    return GestureDetector(
      onTap: () {
        if (onPress != null) {
          onPress();
          return;
        }
        Navigator.push(context, CupertinoPageRoute(builder: toPage!));
      },
      child: Row(
        children: [
          Container(
              width: 80.w,
              height: 80.h,
              margin: EdgeInsets.fromLTRB(73.5.w, 43.h, 56.w, 29.h),
              child: Image.asset(icon)),
          Expanded(child: Text(title)),
          Container(
              height: 75.h,
              width: 75.w,
              margin: EdgeInsets.only(right: 33.w),
              child: Icon(size: 65.r, CupertinoIcons.right_chevron)),
        ],
      ),
    );
  }

  Widget _buildSettingGroup(List<Widget> children) {
    List<Widget> childrenWithDivider = [];

    for (int i = 0; i < children.length; i++) {
      childrenWithDivider.add(children[i]);
      if (i != children.length - 1) {
        childrenWithDivider.add(Container(
            margin: EdgeInsets.fromLTRB(183.w, 0, 33.w, 0),
            height: 1.h,
            color: lineColor));
      }
    }

    return Container(
      margin: EdgeInsets.fromLTRB(85.w, 45.h, 85.w, 0),
      color: CupertinoColors.white,
      child: Column(
        children: childrenWithDivider,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        color: backgroundColor06,
        child: Column(
          children: [
            _buildSettingGroup([
              _buildSettingItem(
                  context,
                  mySource,
                  AppLocalizations.of(context)!.sources,
                  (context) => const SourcesSettings()),
              _buildSettingItem(
                  context,
                  myNet,
                  AppLocalizations.of(context)!.network,
                  (context) => const NetworkSettings()),
            ]),
            _buildSettingGroup([
              _buildSettingItem(
                  context,
                  mySetting,
                  AppLocalizations.of(context)!.general,
                  (context) => const GeneralSettings()),
            ]),
            _buildSettingGroup([
              _buildSettingItem(
                  context,
                  myAbout,
                  AppLocalizations.of(context)!.about,
                  (context) => const AboutPage()),
              _buildSettingItem(
                context,
                myDebug,
                AppLocalizations.of(context)!.debug,
                // (context) => const DebugSettingPage()),
                null,
                onPress: () {
                  Navigator.of(context).push(material.MaterialPageRoute(
                    builder: (context) =>
                        TalkerScreen(talker: Log.instance.talker),
                  ));
                },
              )
            ]),
          ],
        ));
  }
}
