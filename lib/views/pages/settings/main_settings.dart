import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:toonfu/views/pages/settings/sources_settings.dart';
import 'package:toonfu/views/pages/settings/about_page.dart';
import 'package:toonfu/views/pages/settings/debug_setting_page.dart';

class MainSettings extends StatefulWidget {
  const MainSettings({super.key});

  @override
  State<MainSettings> createState() => _MainSettingsState();
}

class _MainSettingsState extends State<MainSettings> {
  final List<String> settingItems = ['Sources', 'About', 'Debug'];

  @override
  void initState() {
    super.initState();
  }

  Future<void> _navigateToPage(String page) async {
    if (page == 'Sources') {
      await Navigator.push(
          context, CupertinoPageRoute(builder: (context) => SourcesSettings()));
    } else if (page == 'About') {
      await Navigator.push(
          context, CupertinoPageRoute(builder: (context) => AboutPage()));
    } else if (page == 'Debug') {
      await Navigator.push(context,
          CupertinoPageRoute(builder: (context) => DebugSettingPage()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Settings'),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Icon(CupertinoIcons.xmark),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      child: SafeArea(
        child: Column(
          children: settingItems.map((item) {
            print(item);
            return GestureDetector(
              onTap: () {
                _navigateToPage(item);
              },
              child: SizedBox(
                height: 0.1.sh,
                width: double.infinity,
                child: Text(item),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
