import 'package:flutter/material.dart';
import 'package:toonfu/views/tabs/explore.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _tabs = <String>[
    'Tab 1',
    'Tab 2',
    'Explore',
  ];

  @override
  void initState() {
    super.initState();

    _tabController = TabController(
      length: _tabs.length,
      vsync: this,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
      ),
      body: Column(
        children: [
          Expanded(
              child: TabBarView(
            controller: _tabController,
            children: <Widget>[
              Center(
                child: Text('Tab 1'),
              ),
              Center(
                child: Text('Tab 2'),
              ),
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
