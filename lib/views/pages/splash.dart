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
    await buildContext.read<SettingProvider>().loadSettings();
    await buildContext.read<ExtensionProvider>().loadExtensions();
    await buildContext.read<ComicProvider>().loadComics();
    await initMainLua();

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
