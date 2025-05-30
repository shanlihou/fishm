import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:fishm/utils/utils_general.dart';
import 'package:fishm/utils/utils_widget.dart';

import '../../../api/flutter_call_lua/method.dart';
import '../../../const/assets_const.dart';
import '../../../const/color_const.dart';
import '../../../const/general_const.dart';
import '../../../types/manager/actions.dart';
import '../../../types/provider/setting_provider.dart';
import 'package:flutter_gen/gen_l10n/localizations.dart';

class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  String baseVersion = 'unknown';
  bool isResetting = false;

  @override
  void initState() {
    super.initState();
    _getBaseVersion();
  }

  void _getBaseVersion() async {
    Map<String, dynamic> ret = await getBaseVersion() as Map<String, dynamic>;
    setState(() {
      baseVersion = ret['version'];
    });
  }

  Future<bool> _onResetPressed(BuildContext buildContext) async {
    setState(() {
      isResetting = true;
    });

    var settingProvider = buildContext.read<SettingProvider>();
    bool ret = await resetMainLua(
        settingProvider.settings?.localMainLuaDeubugPath ?? "");

    setState(() {
      isResetting = false;
    });

    actionsManager.resetMainLua();
    return ret;
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(AppLocalizations.of(context)!.about),
      ),
      child: SafeArea(
        child: Column(
          children: [
            buildCommonBase(
              context,
              aboutBig,
              AppLocalizations.of(context)!.about,
            ),
            Container(
              height: 150.h,
              alignment: Alignment.center,
              margin: EdgeInsets.only(left: 40.w, right: 40.w, top: 20.h),
              padding: EdgeInsets.only(left: 40.w, right: 40.w, top: 20.h),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(color: settingBoxColor),
                color: CupertinoColors.white,
                boxShadow: [
                  BoxShadow(
                    color: settingBoxShadowColor,
                    blurRadius: 10.r,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Text(AppLocalizations.of(context)!.aboutKernal),
                      Container(
                        margin: EdgeInsets.only(left: 20.w),
                        child: Text(baseVersion,
                            style: TextStyle(
                                fontSize: 40.sp,
                                color: CupertinoColors.secondaryLabel)),
                      ),
                      Expanded(
                        child: Container(
                          alignment: Alignment.centerRight,
                          child: GestureDetector(
                            onTap: () async {
                              if (!isResetting) {
                                bool ret = await _onResetPressed(context);
                                if (ret) {
                                  showCupertinoToast(
                                      context: context,
                                      message: AppLocalizations.of(context)!
                                          .resetSuccess);
                                } else {
                                  showCupertinoToast(
                                      context: context,
                                      message: AppLocalizations.of(context)!
                                          .resetFailed);
                                }
                              }
                            },
                            child: Text(AppLocalizations.of(context)!.reset,
                                style: TextStyle(
                                    fontSize: 50.sp,
                                    color: isResetting
                                        ? CupertinoColors.systemGrey
                                            .withOpacity(0.5)
                                        : primaryTextColor)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              height: 150.h,
              margin: EdgeInsets.only(left: 40.w, right: 40.w, top: 40.h),
              padding: EdgeInsets.only(left: 40.w, right: 40.w, top: 20.h),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(color: settingBoxColor),
                color: CupertinoColors.white,
                boxShadow: [
                  BoxShadow(
                    color: settingBoxShadowColor,
                    blurRadius: 10.r,
                  ),
                ],
              ),
              child: Row(
                children: [
                  Text(AppLocalizations.of(context)!.fishmVersion),
                  Container(
                    margin: EdgeInsets.only(left: 20.w),
                    child: Text(fishmVersion,
                        style: TextStyle(
                            fontSize: 40.sp,
                            color: CupertinoColors.secondaryLabel)),
                  ),
                ],
              ),
            ),
            Container(
              height: 150.h,
              margin: EdgeInsets.only(left: 40.w, right: 40.w, top: 40.h),
              padding: EdgeInsets.only(left: 40.w, right: 40.w, top: 20.h),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(color: settingBoxColor),
                color: CupertinoColors.white,
                boxShadow: [
                  BoxShadow(
                    color: settingBoxShadowColor,
                    blurRadius: 10.r,
                  ),
                ],
              ),
              child: Row(
                children: [
                  Text(AppLocalizations.of(context)!.contactUs),
                  Container(
                    margin: EdgeInsets.only(left: 20.w),
                    child: Text('shanlihou@gmail.com',
                        style: TextStyle(
                            fontSize: 40.sp,
                            color: CupertinoColors.secondaryLabel)),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Clipboard.setData(
                            const ClipboardData(text: 'shanlihou@gmail.com'));
                        showCupertinoToast(
                            context: context,
                            message: AppLocalizations.of(context)!.copied);
                      },
                      child: Container(
                        alignment: Alignment.centerRight,
                        child: Text(AppLocalizations.of(context)!.copy,
                            style: TextStyle(
                                fontSize: 50.sp, color: primaryTextColor)),
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
