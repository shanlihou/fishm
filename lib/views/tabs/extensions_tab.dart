import 'dart:io';

import 'package:archive/archive.dart';
import 'package:dio/dio.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:toonfu/const/path.dart';
import 'package:yaml/yaml.dart';
import '../../common/log.dart';
import '../../const/general_const.dart';
import '../../const/lua_const.dart';
import '../../models/db/extensions.dart' as model_extensions;
import '../../types/manager/actions.dart';
import '../../types/provider/extension_provider.dart';
import '../../types/provider/setting_provider.dart';
import '../../utils/utils_general.dart';
import 'package:flutter_gen/gen_l10n/localizations.dart';

import 'extension/extension_installed_tab.dart';
import 'extension/extension_store_tab.dart';

class ExtensionsTab extends StatefulWidget {
  const ExtensionsTab({super.key});

  @override
  State<ExtensionsTab> createState() => _ExtensionsTabState();
}

class _ExtensionsTabState extends State<ExtensionsTab> {
  final PageController _pageController = PageController();
  final List<String> _tabs = ['installed', 'store'];

  final ValueNotifier<int> _curPage = ValueNotifier(0);

  @override
  void initState() {
    super.initState();
  }

  String _getTabTitle(int index) {
    String title = _tabs[index];
    if (title == 'installed') {
      return AppLocalizations.of(context)!.installed;
    } else if (title == 'store') {
      return AppLocalizations.of(context)!.store;
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> tabs = [];
    for (int i = 0; i < _tabs.length; i++) {
      tabs.add(Expanded(
        child: GestureDetector(
          onTap: () {
            _curPage.value = i;
            _pageController.jumpToPage(i);
          },
          child: Center(
            child: Column(
              children: [
                Text(_getTabTitle(i)),
                ValueListenableBuilder(
                  valueListenable: _curPage,
                  builder: (context, value, child) {
                    return Container(
                      height: 1,
                      width: 0.1.sw,
                      color: value == i
                          ? CupertinoColors.black
                          : CupertinoColors.transparent,
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ));
    }

    return Column(
      children: [
        Expanded(
          flex: 1,
          child: Row(
            children: tabs,
          ),
        ),
        Expanded(
          flex: 9,
          child: PageView(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(),
            children: const [
              ExtensionInstalledTab(),
              ExtensionStoreTab(),
            ],
          ),
        ),
      ],
    );
  }
}
