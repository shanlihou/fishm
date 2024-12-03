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
    return Row(
      children: [
        Container(
          margin:
              EdgeInsets.only(right: 20.w, left: 20.w, top: 20.h, bottom: 10.h),
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Sources'),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Icon(CupertinoIcons.xmark),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
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
                margin: EdgeInsets.only(bottom: 20.h),
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
                            context
                                .read<SettingProvider>()
                                .addSource(_sourceUrlController.text);
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
                    decoration: BoxDecoration(
                      color: CupertinoColors.white,
                      borderRadius: BorderRadius.circular(10.r),
                      border: Border.all(color: CupertinoColors.systemGrey),
                    ),
                    child: Consumer<SettingProvider>(
                      builder: (context, provider, child) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(AppLocalizations.of(context)!.sourceComment,
                                style: TextStyle(
                                    fontSize: 40.spMin,
                                    color: CupertinoColors.systemGrey)),
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
