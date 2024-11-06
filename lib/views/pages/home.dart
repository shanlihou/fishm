import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'package:toonfu/views/tabs/explore_tab.dart';
import 'package:toonfu/views/tabs/bookshelf.dart';
import '../../const/assets_const.dart';
import '../../types/provider/task_provider.dart';
import '../mixin/lua_mixin.dart';
import '../mixin/task_mixin.dart';
import '../tabs/search_tab.dart';
import '../widget/bottom_app_bar_widget.dart';
import 'settings/main_settings.dart';
import '../tabs/extensions_tab.dart';
import '../tabs/history_tab.dart';
import 'package:flutter_gen/gen_l10n/localizations.dart';

import 'task_page.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home>
    with SingleTickerProviderStateMixin, LuaMixin, TaskMixin {
  ValueNotifier<String> curLabel = ValueNotifier('');

  @override
  void initState() {
    super.initState();
    initLua();
    startLuaLoop();
    var taskProvider = context.read<TaskProvider>();
    startTaskLoop(taskProvider);
  }

  @override
  BuildContext getContext() {
    return context;
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
        middle: ValueListenableBuilder(
          valueListenable: curLabel,
          builder: (context, value, child) {
            return Text(
                value == '' ? AppLocalizations.of(context)!.favorite : value);
          },
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CupertinoButton(
              padding: EdgeInsets.zero,
              child: const Icon(CupertinoIcons.list_bullet),
              onPressed: () {
                Navigator.push(
                  context,
                  CupertinoPageRoute(builder: (context) => const TaskPage()),
                );
              },
            ),
            CupertinoButton(
              padding: EdgeInsets.zero,
              child: const Icon(CupertinoIcons.settings),
              onPressed: () {
                Navigator.push(
                  context,
                  CupertinoPageRoute(
                      builder: (context) => const MainSettings()),
                );
              },
            ),
          ],
        ),
      ),
      child: SafeArea(
        child: BottomAppBarWidget(
          pages: const [
            ExtensionsTab(),
            HistoryTab(),
            BookShelfTab(),
            ExploreTab(),
            SearchTab(),
          ],
          titles: [
            AppLocalizations.of(context)!.extensions,
            AppLocalizations.of(context)!.search,
            AppLocalizations.of(context)!.explore,
            AppLocalizations.of(context)!.my,
          ],
          iconOffs: const [extensionOff, searchOff, modeOff, myOff],
          iconOns: const [extensionOn, searchOn, modeOn, myOn],
        ),
      ),
    );
  }
}
