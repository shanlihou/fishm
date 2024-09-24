import 'package:flutter/material.dart';
import 'package:toonfu/types/provider/setting_provider.dart';
import 'package:provider/provider.dart';

class SourcesSettings extends StatefulWidget {
  const SourcesSettings({super.key});

  @override
  State<SourcesSettings> createState() => _SourcesSettingsState();
}

class _SourcesSettingsState extends State<SourcesSettings> {
  final TextEditingController _sourceUrlController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sources'),
      ),
      body: Column(
        children: [
          Expanded(
            flex: 1,
            child: Row(
              children: [
                Expanded(
                    flex: 1,
                    child: IconButton(
                        onPressed: () {
                          context
                              .read<SettingProvider>()
                              .addSource(_sourceUrlController.text);
                        },
                        icon: const Icon(Icons.add))),
                Expanded(
                    flex: 9,
                    child: TextField(
                      controller: _sourceUrlController,
                      decoration: const InputDecoration(
                        hintText: 'Source url',
                        hintStyle: TextStyle(color: Colors.grey),
                      ),
                    )),
              ],
            ),
          ),
          Expanded(
            flex: 10,
            child: ListView.builder(
              itemCount:
                  context.watch<SettingProvider>().settings.sources.length,
              itemBuilder: (context, index) {
                return Text(
                    context.watch<SettingProvider>().settings.sources[index]);
              },
            ),
          )
        ],
      ),
    );
  }
}
