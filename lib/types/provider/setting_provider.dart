import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:toonfu/models/db/settings.dart' as model_settings;

class SettingProvider with ChangeNotifier {
  bool _isLoad = false;
  late Box<model_settings.Settings> _settingsBox;
  model_settings.Settings? _settings;

  SettingProvider();

  Future<void> loadSettings() async {
    if (_isLoad) {
      return;
    }

    _isLoad = true;
    _settingsBox = await Hive.openBox<model_settings.Settings>('settings');
    _settings = _settingsBox.get('settings');
    notifyListeners();
  }

  model_settings.Settings get settings => _settings!;

  void addSource(String source) {
    _settings?.sources.add(source);
    _settingsBox.put('settings', _settings!);
    notifyListeners();
  }
}
