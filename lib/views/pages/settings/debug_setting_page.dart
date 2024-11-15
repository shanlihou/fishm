import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:talker_flutter/talker_flutter.dart';

import '../../../common/log.dart';
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
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Debug'),
      ),
      child: SafeArea(
        child: Column(
          children: [
            CupertinoButton(
              child: const Text('console'),
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) =>
                      TalkerScreen(talker: Log.instance.talker),
                ));
              },
            ),
            GestureDetector(
              onTap: () async {
                var provider = context.read<SettingProvider>();
                var path = await _showEditPathDialog(context);
                if (path != "") {
                  provider.settings?.localMainLuaDeubugPath = path;
                  await provider.saveSettings();
                }
              },
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
            Text('current: ${Directory.current}'),
          ],
        ),
      ),
    );
  }

  Future<String> _showEditPathDialog(BuildContext context) async {
    String result = "";
    await showCupertinoDialog(
      context: context,
      builder: (BuildContext context) => CupertinoAlertDialog(
        title: const Text('edit path'),
        content: CupertinoTextField(
          placeholder: 'input path',
          onChanged: (value) {
            result = value;
          },
        ),
        actions: <CupertinoDialogAction>[
          CupertinoDialogAction(
            child: const Text('cancel'),
            onPressed: () {
              result = "";
              Navigator.pop(context);
            },
          ),
          CupertinoDialogAction(
            child: const Text('confirm'),
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
