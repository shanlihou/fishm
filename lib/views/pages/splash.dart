import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' as material;
import 'package:provider/provider.dart';
import 'package:talker_flutter/talker_flutter.dart';

import '../../common/log.dart';
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
  String _stepText = 'loading';

  @override
  void initState() {
    super.initState();
  }

  void _updateStepText(String text) {
    if (!mounted) {
      return;
    }

    setState(() {
      _stepText = text;
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

    _updateStepText('init directory');
    while (!await initDirectory()) {
      Log.instance.d('init directory failed, retry...');
      await Future.delayed(const Duration(milliseconds: 1000));
    }

    _isInit = true;
    _updateStepText('load settings');
    await settingProvider.loadSettings();
    _updateStepText('init global');
    globalManager.initGlobal(settingProvider);
    _updateStepText('load extensions');
    await extensionProvider.loadExtensions();
    _updateStepText('load comics');
    await comicProvider.loadComics();
    _updateStepText('load tasks');
    await taskProvider.loadTasks();
    _updateStepText('init main lua');
    await initMainLua(settingProvider.settings?.localMainLuaDeubugPath ?? "");

    _updateStepText('set locale');
    if (settingProvider.settings?.language == "") {
      String language = Localizations.localeOf(buildContext).languageCode;
      context.read<LocalProvider>().setLocale(Locale(language));
    } else {
      context
          .read<LocalProvider>()
          .setLocale(Locale(settingProvider.settings?.language ?? "en"));
    }

    _updateStepText('init plugins');
    pluginDbManager.initPlugins(extensionProvider.extensionNames());

    _updateStepText('go to home');
    Navigator.pushReplacement(
      buildContext,
      CupertinoPageRoute(builder: (context) => const Home()),
    );
  }

  @override
  Widget build(BuildContext context) {
    _init(context);
    return CupertinoPageScaffold(
      child: Center(
        child: Column(
          children: [
            CupertinoButton(
              child: Text(_stepText),
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
