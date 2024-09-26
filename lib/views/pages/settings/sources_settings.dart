import 'package:flutter/cupertino.dart';
import 'package:toonfu/types/provider/setting_provider.dart';
import 'package:provider/provider.dart';

class SourcesSettings extends StatefulWidget {
  const SourcesSettings({super.key});

  @override
  State<SourcesSettings> createState() => _SourcesSettingsState();
}

class _SourcesSettingsState extends State<SourcesSettings> {
  final TextEditingController _sourceUrlController = TextEditingController();

  Widget _buildSourceItem(String source) {
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: CupertinoButton(
            onPressed: () {
              context.read<SettingProvider>().removeSource(source);
            },
            child: const Icon(CupertinoIcons.minus),
          ),
        ),
        Expanded(
          flex: 9,
          child: Text(source),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Sources'),
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
          children: [
            Expanded(
              flex: 1,
              child: Row(
                children: [
                  Expanded(
                      flex: 1,
                      child: CupertinoButton(
                          onPressed: () {
                            context
                                .read<SettingProvider>()
                                .addSource(_sourceUrlController.text);
                          },
                          child: const Icon(CupertinoIcons.add))),
                  Expanded(
                      flex: 9,
                      child: CupertinoTextField(
                        controller: _sourceUrlController,
                        placeholder: 'Source url',
                        placeholderStyle:
                            const TextStyle(color: CupertinoColors.systemGrey),
                      )),
                ],
              ),
            ),
            Expanded(
              flex: 10,
              child: ListView.builder(
                itemCount: context.watch<SettingProvider>().sources.length,
                itemBuilder: (context, index) {
                  return _buildSourceItem(
                      context.watch<SettingProvider>().sources[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
