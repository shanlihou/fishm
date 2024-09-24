import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:toonfu/models/db/settings.dart' as model_settings;
import 'package:toonfu/views/pages/settings/sources_settings.dart';

class MainSettings extends StatefulWidget {
  const MainSettings({super.key});

  @override
  State<MainSettings> createState() => _MainSettingsState();
}

class _MainSettingsState extends State<MainSettings> {
  late Box<model_settings.Settings> _settingsBox;
  model_settings.Settings? _settings;
  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    _settingsBox = await Hive.openBox<model_settings.Settings>('settings');

    final settings = _settingsBox.get('settings');
    if (settings != null) {
      _settings = settings;
    } else {
      _settings = model_settings.Settings.defaultSettings();
      await _settingsBox.put('settings', _settings!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Column(
        children: [
          GestureDetector(
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => SourcesSettings()));
            },
            child: const Text('Sources'),
          ),
          const Text('Extensions'),
        ],
      ),
    );
  }
}
