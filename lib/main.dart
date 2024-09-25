// import 'dart:isolate';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:toonfu/types/provider/extension_provider.dart';
import 'package:toonfu/views/pages/home.dart';
import 'package:provider/provider.dart';
import 'package:toonfu/types/provider/setting_provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:toonfu/models/db/settings.dart';
import 'package:toonfu/models/db/extensions.dart';

import 'utils/general.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  _main();
}

Future<void> _main() async {
  // Isolate.spawn<void>(luaLoop, null);
  await initDirectory();
  Hive.init(Directory.current.path);
  await Hive.initFlutter();
  // Hive.openBox('settings');
  Hive.registerAdapter(SettingsAdapter());
  Hive.registerAdapter(ExtensionAdapter());
  Hive.registerAdapter(ExtensionsAdapter());

  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => SettingProvider()),
      ChangeNotifierProvider(create: (_) => ExtensionProvider()),
    ],
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // call provider
    context.read<SettingProvider>().loadSettings();
    context.read<ExtensionProvider>().loadExtensions();
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const Home(),
    );
  }
}
