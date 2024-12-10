import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:toonfu/types/provider/setting_provider.dart';
import 'package:provider/provider.dart';

import '../../../const/assets_const.dart';
import '../../../const/color_const.dart';
import '../../../utils/utils_widget.dart';
import 'package:flutter_gen/gen_l10n/localizations.dart';

class SourcesSettings extends StatefulWidget {
  const SourcesSettings({super.key});

  @override
  State<SourcesSettings> createState() => _SourcesSettingsState();
}

class _SourcesSettingsState extends State<SourcesSettings> {
  final TextEditingController _sourceUrlController = TextEditingController();

  Widget _buildSourceItem(String source) {
    return Container(
      margin: EdgeInsets.only(right: 30.w, bottom: 20.h),
      child: Row(
        children: [
          Container(
            margin: EdgeInsets.only(
                right: 20.w, left: 20.w, top: 20.h, bottom: 10.h),
            child: GestureDetector(
              onTap: () {
                context.read<SettingProvider>().removeSource(source);
              },
              child: Image.asset(
                sourceDelete,
                width: 60.w,
                height: 60.h,
              ),
            ),
          ),
          Expanded(
            flex: 9,
            child: Text(source),
          ),
        ],
      ),
    );
  }

  Future<void> _onPressAdd(BuildContext context) async {
    for (var source in context.read<SettingProvider>().sources) {
      if (source == _sourceUrlController.text) {
        showCupertinoToast(context: context, message: '已存在');
        return;
      }
    }

    context.read<SettingProvider>().addSource(_sourceUrlController.text);
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Sources'),
      ),
      child: SafeArea(
        child: Container(
          color: backgroundColor06,
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
          child: Column(
            children: [
              buildCommonBase(
                  context, sourceBig, AppLocalizations.of(context)!.import),
              Container(
                margin: EdgeInsets.only(
                    bottom: 20.h, left: 30.w, right: 40.w, top: 20.h),
                child: Row(
                  children: [
                    Expanded(
                        flex: 9,
                        child: CupertinoTextField(
                          controller: _sourceUrlController,
                          placeholder: 'Source url',
                          placeholderStyle: const TextStyle(
                              color: CupertinoColors.systemGrey),
                        )),
                    Container(
                        margin: EdgeInsets.only(left: 20.w),
                        child: GestureDetector(
                          onTap: () {
                            _onPressAdd(context);
                          },
                          child: Image.asset(
                            sourceAdd,
                            width: 60.w,
                            height: 60.h,
                          ),
                        )),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Container(
                    margin: EdgeInsets.only(top: 20.h, left: 20.w, right: 20.w),
                    padding: EdgeInsets.only(bottom: 20.h),
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
                    child: Consumer<SettingProvider>(
                      builder: (context, provider, child) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              margin: EdgeInsets.only(
                                  top: 20.h, left: 30.w, bottom: 20.h),
                              child: Text(
                                  AppLocalizations.of(context)!.sourceComment,
                                  style: TextStyle(
                                      fontSize: 40.spMin,
                                      color: CupertinoColors.systemGrey)),
                            ),
                            for (var source in provider.sources)
                              _buildSourceItem(source),
                          ],
                        );
                        // return ListView.builder(
                        //   itemCount: provider.sources.length,
                        //   itemBuilder: (context, index) {
                        //     return _buildSourceItem(provider.sources[index]);
                        //   },
                        // );
                      },
                    ),
                    // ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
