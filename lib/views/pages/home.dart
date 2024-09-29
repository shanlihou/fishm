import 'package:flutter/cupertino.dart';
import 'dart:async';
import 'package:toonfu/views/tabs/explore_tab.dart';
import 'package:toonfu/views/tabs/bookshelf.dart';
import '../mixin/lua_mixin.dart';
import '../tabs/search_tab.dart';
import 'settings/main_settings.dart';
import '../tabs/extensions_tab.dart';
import '../tabs/history_tab.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home>
    with SingleTickerProviderStateMixin, LuaMixin {
  final List<String> _tabs = <String>[
    'Bookshelf',
    'History',
    'Extensions',
    'Explore',
    'Search',
  ];

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
                        for (final tab in _tabs)
                          BottomNavigationBarItem(
                            icon: Icon(CupertinoIcons.book),
                            label: tab,
                          )
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
