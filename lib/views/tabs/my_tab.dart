import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:toonfu/const/color_const.dart';
import 'package:flutter_gen/gen_l10n/localizations.dart';

import '../pages/settings/about_page.dart';
import '../pages/settings/debug_setting_page.dart';
import '../pages/settings/general_settings.dart';
import '../pages/settings/network_settings.dart';
import '../pages/settings/sources_settings.dart';

class MyTab extends StatelessWidget {
  const MyTab({super.key});

  Widget _buildSettingItem(
      BuildContext context, String title, WidgetBuilder toPage) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, CupertinoPageRoute(builder: toPage));
      },
      child: Row(
        children: [
          Container(
              width: 80.w,
              height: 80.h,
              margin: EdgeInsets.fromLTRB(73.5.w, 43.h, 56.w, 29.h),
              child: Icon(CupertinoIcons.settings)),
          Expanded(child: Text(title)),
          Container(
              height: 75.h,
              width: 75.w,
              margin: EdgeInsets.only(right: 33.w),
              child: Icon(CupertinoIcons.right_chevron)),
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
              _buildSettingItem(context, AppLocalizations.of(context)!.sources,
                  (context) => const SourcesSettings()),
              _buildSettingItem(context, AppLocalizations.of(context)!.network,
                  (context) => const NetworkSettings()),
            ]),
            _buildSettingGroup([
              _buildSettingItem(context, AppLocalizations.of(context)!.general,
                  (context) => const GeneralSettings()),
            ]),
            _buildSettingGroup([
              _buildSettingItem(context, AppLocalizations.of(context)!.about,
                  (context) => const AboutPage()),
              _buildSettingItem(context, AppLocalizations.of(context)!.debug,
                  (context) => const DebugSettingPage()),
            ]),
          ],
        ));
  }
}
