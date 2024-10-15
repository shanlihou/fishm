import 'package:flutter/cupertino.dart';
import 'dart:async';
import 'package:toonfu/views/tabs/explore_tab.dart';
import 'package:toonfu/views/tabs/bookshelf.dart';
import '../mixin/lua_mixin.dart';
import '../tabs/search_tab.dart';
import 'settings/main_settings.dart';
import '../tabs/extensions_tab.dart';
import '../tabs/history_tab.dart';
import 'package:flutter_gen/gen_l10n/localizations.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home>
    with SingleTickerProviderStateMixin, LuaMixin {
  @override
  void initState() {
    super.initState();
    initLua();

    startLuaLoop();

    startLuaLoop();
  }

  void startLuaLoop() async {
    Timer.periodic(const Duration(milliseconds: 100), (timer) {
      loopOnce();
    });
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      resizeToAvoidBottomInset: false,
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Home'),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Icon(CupertinoIcons.settings),
          onPressed: () {
            Navigator.push(
              context,
              CupertinoPageRoute(builder: (context) => const MainSettings()),
            );
          },
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: CupertinoTabView(
                builder: (context) {
                  return CupertinoTabScaffold(
                    tabBar: CupertinoTabBar(
                      items: [
                        BottomNavigationBarItem(
                          icon: Icon(CupertinoIcons.star),
                          label: AppLocalizations.of(context)!.favorite,
                        ),
                        BottomNavigationBarItem(
                          icon: Icon(CupertinoIcons.clock),
                          label: AppLocalizations.of(context)!.history,
                        ),
                        BottomNavigationBarItem(
                          icon: Icon(CupertinoIcons.square_grid_2x2),
                          label: AppLocalizations.of(context)!.extensions,
                        ),
                        BottomNavigationBarItem(
                          icon: Icon(CupertinoIcons.globe),
                          label: AppLocalizations.of(context)!.explore,
                        ),
                        BottomNavigationBarItem(
                          icon: Icon(CupertinoIcons.search),
                          label: AppLocalizations.of(context)!.search,
                        ),
                      ],
                    ),
                    tabBuilder: (context, index) {
                      switch (index) {
                        case 0:
                          return const BookShelfTab();
                        case 1:
                          return const HistoryTab();
                        case 2:
                          return const ExtensionsTab();
                        case 3:
                          return const ExploreTab();
                        case 4:
                          return const SearchTab();
                        default:
                          return const SizedBox.shrink();
                      }
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
