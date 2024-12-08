import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../../const/assets_const.dart';
import '../../../const/color_const.dart';
import '../../../types/manager/global_manager.dart';
import '../../../types/provider/setting_provider.dart';

import 'package:flutter_gen/gen_l10n/localizations.dart';

import '../../../utils/utils_widget.dart';

class NetworkSettings extends StatefulWidget {
  const NetworkSettings({super.key});

  @override
  State<NetworkSettings> createState() => _NetworkSettingsState();
}

class _NetworkSettingsState extends State<NetworkSettings> {
  final TextEditingController _hostController = TextEditingController();
  final TextEditingController _portController = TextEditingController();
  final FocusNode _hostFocusNode = FocusNode();
  final FocusNode _portFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    _hostFocusNode.addListener(() {
      if (!_hostFocusNode.hasFocus) {
        _saveSettings();
      }
    });

    _portFocusNode.addListener(() {
      if (!_portFocusNode.hasFocus) {
        _saveSettings();
      }
    });
  }

  @override
  void dispose() {
    _hostFocusNode.dispose();
    _portFocusNode.dispose();
    _hostController.dispose();
    _portController.dispose();
    super.dispose();
  }

  Future<void> _saveSettings() async {
    var p = context.read<SettingProvider>();
    p.settings!.proxyHost = _hostController.text;
    p.settings!.proxyPort = int.parse(_portController.text);
    p.saveSettings();
    globalManager.resetProxy(p);
  }

  @override
  Widget build(BuildContext context) {
    var p = context.watch<SettingProvider>();
    _hostController.text = p.settings?.proxyHost ?? '';
    _portController.text = p.settings?.proxyPort.toString() ?? '';

    List<Widget> children = [
      CupertinoFormSection(
        header: Text(AppLocalizations.of(context)!.proxy),
        children: [
          CupertinoFormRow(
            prefix: Text(AppLocalizations.of(context)!.enable),
            child: CupertinoSwitch(
              value: p.settings?.enableProxy ?? false,
              onChanged: (value) {
                p.settings?.enableProxy = value;
                globalManager.resetProxy(p);
                p.saveSettings();
              },
            ),
          ),
        ],
      ),
    ];

    if (p.settings?.enableProxy ?? false) {
      children.addAll([
        CupertinoTextFormFieldRow(
          controller: _hostController,
          placeholder: AppLocalizations.of(context)!.host,
          focusNode: _hostFocusNode,
        ),
        CupertinoTextFormFieldRow(
          controller: _portController,
          placeholder: AppLocalizations.of(context)!.port,
          keyboardType: TextInputType.number,
          focusNode: _portFocusNode,
        ),
      ]);
    }

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(AppLocalizations.of(context)!.network),
      ),
      child: SafeArea(
        child: Column(
          children: [
            buildCommonBase(context, networkBig,
                AppLocalizations.of(context)!.networkManager),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: CupertinoColors.white,
                borderRadius: BorderRadius.circular(10.r),
                boxShadow: [
                  BoxShadow(
                    color: settingBoxShadowColor,
                    blurRadius: 10.r,
                  )
                ],
                border: Border.all(color: settingBoxColor),
              ),
              margin: EdgeInsets.only(top: 20.h, left: 40.w, right: 40.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: EdgeInsets.only(
                        left: 50.w, right: 50.w, top: 20.h, bottom: 20.h),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(AppLocalizations.of(context)!.proxy),
                        CupertinoSwitch(
                          activeColor: primaryTextColor,
                          value: p.settings?.enableProxy ?? false,
                          onChanged: (value) {
                            p.settings?.enableProxy = value;
                            globalManager.resetProxy(p);
                            p.saveSettings();
                          },
                        ),
                      ],
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(left: 50.w, right: 50.w),
                    height: 1.h,
                    color: settingBoxColor,
                  ),
                  Container(
                    margin: EdgeInsets.only(
                        left: 50.w, right: 50.w, top: 20.h, bottom: 20.h),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(AppLocalizations.of(context)!.host),
                        Expanded(
                          child: CupertinoTextField(
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: CupertinoColors.transparent),
                            ),
                            style: const TextStyle(
                              color: Color.fromARGB(255, 133, 133, 134),
                            ),
                            controller: _hostController,
                            placeholder: AppLocalizations.of(context)!.host,
                            textAlign: TextAlign.right,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(left: 50.w, right: 50.w),
                    height: 1.h,
                    color: settingBoxColor,
                  ),
                  Container(
                    margin: EdgeInsets.only(
                        left: 50.w, right: 50.w, top: 20.h, bottom: 20.h),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(AppLocalizations.of(context)!.port),
                        Expanded(
                          child: CupertinoTextField(
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: CupertinoColors.transparent),
                            ),
                            style: const TextStyle(
                              color: Color.fromARGB(255, 133, 133, 134),
                            ),
                            textAlign: TextAlign.right,
                            controller: _portController,
                            placeholder: AppLocalizations.of(context)!.port,
                          ),
                        ),
                      ],
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
