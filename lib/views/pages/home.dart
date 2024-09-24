import 'package:flutter/material.dart';
import 'dart:async';
import 'package:toonfu/views/tabs/explore_tab.dart';
import 'package:toonfu/views/tabs/bookshelf.dart';
import '../mixin/lua_mixin.dart';
import 'settings/main_settings.dart';
import '../tabs/extensions_tab.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home>
    with SingleTickerProviderStateMixin, LuaMixin {
  late TabController _tabController;
  final List<String> _tabs = <String>[
    'Bookshelf',
    'Extensions',
    'Explore',
  ];

  @override
  void initState() {
    super.initState();
    initLua();

    _tabController = TabController(
      length: _tabs.length,
      vsync: this,
    );

    startLuaLoop();
  }

  void startLuaLoop() async {
    Timer.periodic(const Duration(milliseconds: 100), (timer) {
      loopOnce();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Expanded(flex: 1, child: Text('Home')),
            Expanded(flex: 8, child: Container()),
            Expanded(
              flex: 1,
              child: IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const MainSettings()),
                  );
                },
                icon: const Icon(Icons.settings),
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
              child: TabBarView(
            controller: _tabController,
            children: const <Widget>[
              BookShelfTab(),
              ExtensionsTab(),
              ExploreTab(),
            ],
          )),
          TabBar(
            controller: _tabController,
            tabs: [for (final tab in _tabs) Tab(text: tab)],
          )
        ],
      ),
    );
  }
}
