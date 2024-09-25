import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../types/provider/extension_provider.dart';
import '../../types/provider/setting_provider.dart';
import '../../utils/general.dart';
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
    await initMainLua();

    Navigator.pushReplacement(
      buildContext,
      MaterialPageRoute(builder: (context) => const Home()),
    );
  }

  @override
  Widget build(BuildContext context) {
    _init(context);
    return const Scaffold(
      body: Center(
        child: Text('Loading...'),
      ),
    );
  }
}
