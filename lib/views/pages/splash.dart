import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' as material;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:talker_flutter/talker_flutter.dart';

import '../../common/log.dart';
import '../../const/assets_const.dart';
import '../../types/manager/global_manager.dart';
import '../../types/manager/plugin_db_manager.dart';
import '../../types/provider/comic_provider.dart';
import '../../types/provider/extension_provider.dart';
import '../../types/provider/local_provider.dart';
import '../../types/provider/setting_provider.dart';
import '../../types/provider/task_provider.dart';
import '../../utils/utils_general.dart';
import 'home.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _isInit = false;
  int _step = 0;

  @override
  void initState() {
    super.initState();
  }

  void _updateStep(int step) {
    Log.instance.d('update step: $step');
    if (!mounted) {
      return;
    }

    setState(() {
      _step = step;
    });
  }

  Future<void> _init(BuildContext buildContext) async {
    if (_isInit) {
      return;
    }

    var settingProvider = buildContext.read<SettingProvider>();
    var extensionProvider = buildContext.read<ExtensionProvider>();
    var comicProvider = buildContext.read<ComicProvider>();
    var taskProvider = buildContext.read<TaskProvider>();

    _updateStep(1);
    while (!await initDirectory()) {
      Log.instance.d('init directory failed, retry...');
      await Future.delayed(const Duration(milliseconds: 1000));
    }

    _isInit = true;
    _updateStep(2);
    await settingProvider.loadSettings();
    _updateStep(3);
    globalManager.initGlobal(settingProvider);
    _updateStep(4);
    await extensionProvider.loadExtensions();
    _updateStep(5);
    await comicProvider.loadComics();
    _updateStep(6);
    await taskProvider.loadTasks();
    _updateStep(7);
    await initMainLua(settingProvider.settings?.localMainLuaDeubugPath ?? "");

    _updateStep(8);
    if (settingProvider.settings?.language == "") {
      String language = Localizations.localeOf(buildContext).languageCode;
      context.read<LocalProvider>().setLocale(Locale(language));
    } else {
      context
          .read<LocalProvider>()
          .setLocale(Locale(settingProvider.settings?.language ?? "en"));
    }

    _updateStep(9);
    pluginDbManager.initPlugins(extensionProvider.extensionNames());

    await Future.delayed(const Duration(seconds: 5));

    _updateStep(10);
    Navigator.pushReplacement(
      buildContext,
      CupertinoPageRoute(builder: (context) => const Home()),
    );
  }

  @override
  Widget build(BuildContext context) {
    _init(context);
    return CupertinoPageScaffold(
      child: Container(
        alignment: Alignment.center,
        height: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(fit: BoxFit.contain, loadingImg),
            CupertinoButton(
              child: Row(
                // display _step num circle
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(
                    _step,
                    (index) => Container(
                          decoration: const BoxDecoration(
                            color: CupertinoColors.systemBlue,
                            shape: BoxShape.circle,
                          ),
                          width: 10.w,
                          height: 10.h,
                        )),
              ),
              onPressed: () {
                Navigator.of(context).push(material.MaterialPageRoute(
                  builder: (context) =>
                      TalkerScreen(talker: Log.instance.talker),
                ));
              },
            ),
          ],
        ),
      ),
    );
  }
}
