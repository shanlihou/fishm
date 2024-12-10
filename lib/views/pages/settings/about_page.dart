import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:toonfu/utils/utils_general.dart';
import 'package:toonfu/utils/utils_widget.dart';

import '../../../api/flutter_call_lua/method.dart';
import '../../../const/assets_const.dart';
import '../../../const/color_const.dart';
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

  Future<void> _onResetPressed(BuildContext buildContext) async {
    setState(() {
      isResetting = true;
    });

    var settingProvider = buildContext.read<SettingProvider>();
    await resetMainLua(settingProvider.settings?.localMainLuaDeubugPath ?? "");

    setState(() {
      isResetting = false;
    });

    actionsManager.resetMainLua();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('About'),
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
                            onTap: () {
                              if (!isResetting) {
                                _onResetPressed(context);
                                showCupertinoToast(
                                    context: context, message: '已重置');
                              }
                            },
                            child: Text('reset',
                                style: TextStyle(
                                    fontSize: 50.sp, color: primaryTextColor)),
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
                  const Text('toonfu版本'),
                  Container(
                    margin: EdgeInsets.only(left: 20.w),
                    child: Text('v1.0.0',
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
                  const Text('联系我们'),
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
                            context: context, message: '已复制到剪贴板');
                      },
                      child: Container(
                        alignment: Alignment.centerRight,
                        child: Text('copy',
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
