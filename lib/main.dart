// import 'dart:isolate';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:toonfu/types/provider/extension_provider.dart';
import 'package:provider/provider.dart';
import 'package:toonfu/types/provider/setting_provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:toonfu/models/db/settings.dart';
import 'package:toonfu/models/db/extensions.dart';
import 'package:toonfu/models/db/comic_model.dart';
import 'package:toonfu/types/provider/comic_provider.dart';
import 'package:toonfu/views/pages/splash.dart';

import 'models/db/read_history_model.dart';
import 'utils/utils_general.dart';

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
  Hive.registerAdapter(ComicModelAdapter());
  Hive.registerAdapter(ChapterModelAdapter());
  Hive.registerAdapter(ReadHistoryModelAdapter());

  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => SettingProvider()),
      ChangeNotifierProvider(create: (_) => ExtensionProvider()),
      ChangeNotifierProvider(create: (_) => ComicProvider()),
    ],
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // call provider
    return ScreenUtilInit(
      designSize: const Size(1179, 2556),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return const CupertinoApp(
          title: 'ToonFu',
          theme: CupertinoThemeData(
            primaryColor: CupertinoColors.systemPurple,
            brightness: Brightness.light,
          ),
          home: SplashScreen(),
        );
      },
    );
  }
}
