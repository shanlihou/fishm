import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import '../../types/provider/comic_provider.dart';
import '../../types/provider/extension_provider.dart';
import '../../types/provider/setting_provider.dart';
import '../../utils/utils_general.dart';
import 'home.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _isInit = false;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _init(BuildContext buildContext) async {
    if (_isInit) {
      return;
    }

    _isInit = true;
    var settingProvider = buildContext.read<SettingProvider>();
    var extensionProvider = buildContext.read<ExtensionProvider>();
    var comicProvider = buildContext.read<ComicProvider>();
    await settingProvider.loadSettings();
    await extensionProvider.loadExtensions();
    await comicProvider.loadComics();
    await initMainLua(settingProvider.settings?.localMainLuaDeubugPath ?? "");

    Navigator.pushReplacement(
      buildContext,
      CupertinoPageRoute(builder: (context) => const Home()),
    );
  }

  @override
  Widget build(BuildContext context) {
    _init(context);
    return const CupertinoPageScaffold(
      child: Center(
        child: Text('Loading...'),
      ),
    );
  }
}
