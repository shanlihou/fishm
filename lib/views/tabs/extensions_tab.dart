import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_gen/gen_l10n/localizations.dart';

import '../../const/color_const.dart';
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
          child: ValueListenableBuilder(
            valueListenable: _curPage,
            builder: (context, value, child) {
              bool isSelected = value == i;
              return Container(
                // #FFFFFF 100%
                decoration: BoxDecoration(
                  // #EFEFEF 100%
                  color: isSelected
                      ? CupertinoColors.white
                      : const Color(0xFFEFEFEF),
                  boxShadow: [
                    BoxShadow(
                      color: CupertinoColors.black.withOpacity(0.06),
                      blurRadius: 10.r,
                    ),
                  ],
                ),
                margin: EdgeInsets.symmetric(horizontal: 8.w),
                alignment: Alignment.center,
                child: Text(
                  _getTabTitle(i),
                  style: TextStyle(
                    // #B886F8 88%
                    // #9A9A9A 100%
                    color: isSelected
                        ? const Color(0xFFB886F8).withOpacity(0.88)
                        : const Color(0xFF9A9A9A),
                  ),
                ),
              );
            },
          ),
        ),
      ));
    }

    return Container(
      color: backgroundColor06,
      child: Column(
        children: [
          Container(
            margin: EdgeInsets.fromLTRB(35.w, 44.h, 35.w, 0.h),
            height: 120.h,
            child: Row(
              children: tabs,
            ),
          ),
          Expanded(
            flex: 9,
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                ExtensionInstalledTab(onTap: () {
                  _curPage.value = 1;
                  _pageController.jumpToPage(1);
                }),
                const ExtensionStoreTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
