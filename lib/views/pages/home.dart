import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'package:fishm/views/tabs/bookshelf.dart';
import '../../const/assets_const.dart';
import '../../types/provider/tab_provider.dart';
import '../../types/provider/task_provider.dart';
import '../mixin/lua_mixin.dart';
import '../mixin/task_mixin.dart';
import '../tabs/import_comic_tab.dart';
import '../tabs/my_tab.dart';
import '../tabs/search_tab.dart';
import '../widget/bottom_app_bar_widget.dart';
import '../tabs/extensions_tab.dart';
import 'package:flutter_gen/gen_l10n/localizations.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home>
    with SingleTickerProviderStateMixin, LuaMixin, TaskMixin {
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

  String _getLabel(int index) {
    var labels = [
      AppLocalizations.of(context)!.extensions,
      AppLocalizations.of(context)!.search,
      AppLocalizations.of(context)!.bookshelf,
      AppLocalizations.of(context)!.import,
      AppLocalizations.of(context)!.my,
    ];

    return labels[index];
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      resizeToAvoidBottomInset: false,
      navigationBar: CupertinoNavigationBar(
        middle: Consumer<TabProvider>(builder: (context, tabProvider, child) {
          var text = _getLabel(tabProvider.currentIndex);
          return Text(text);
        }),
        trailing: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [],
        ),
      ),
      child: SafeArea(
        child: BottomAppBarWidget(
          pages: const [
            ExtensionsTab(),
            SearchTab(),
            BookShelfTab(),
            ImportComicTab(),
            MyTab(),
          ],
          titles: [
            AppLocalizations.of(context)!.extensions,
            AppLocalizations.of(context)!.search,
            AppLocalizations.of(context)!.import,
            AppLocalizations.of(context)!.my,
          ],
          iconOffs: const [extensionOff, searchOff, importOff, myOff],
          iconOns: const [extensionOn, searchOn, importOn, myOn],
        ),
      ),
    );
  }
}
