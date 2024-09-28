import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../types/provider/setting_provider.dart';

class DebugSettingPage extends StatefulWidget {
  const DebugSettingPage({super.key});

  @override
  State<DebugSettingPage> createState() => _DebugSettingPageState();
}

class _DebugSettingPageState extends State<DebugSettingPage> {
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Debug'),
      ),
      child: SafeArea(
        child: GestureDetector(
          onTap: () async {
            var provider = context.read<SettingProvider>();
            var path = await _showEditPathDialog(context);
            if (path != "") {
              provider.settings?.localMainLuaDeubugPath = path;
              await provider.saveSettings();
            }
          },
          child: Center(
            child: Row(
              children: [
                const Text('debug path: '),
                Text(context
                        .watch<SettingProvider>()
                        .settings
                        ?.localMainLuaDeubugPath ??
                    ""),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<String> _showEditPathDialog(BuildContext context) async {
    String result = "";
    await showCupertinoDialog(
      context: context,
      builder: (BuildContext context) => CupertinoAlertDialog(
        title: Text('edit path'),
        content: CupertinoTextField(
          placeholder: 'input path',
          onChanged: (value) {
            result = value;
          },
        ),
        actions: <CupertinoDialogAction>[
          CupertinoDialogAction(
            child: Text('cancel'),
            onPressed: () {
              result = "";
              Navigator.pop(context);
            },
          ),
          CupertinoDialogAction(
            child: Text('confirm'),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
    return result;
  }
}
