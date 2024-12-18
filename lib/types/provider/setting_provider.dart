import 'package:flutter/cupertino.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:fishm/models/db/settings.dart' as model_settings;

class SettingProvider with ChangeNotifier {
  bool _isLoad = false;
  late Box<model_settings.Settings> _settingsBox;
  model_settings.Settings? settings;

  SettingProvider();

  Future<void> loadSettings() async {
    if (_isLoad) {
      return;
    }

    _isLoad = true;
    _settingsBox = await Hive.openBox<model_settings.Settings>('settings');
    settings = _settingsBox.get('settings');
    if (settings == null) {
      settings = model_settings.Settings.defaultSettings();
      _settingsBox.put('settings', settings!);
    }

    notifyListeners();
  }

  List<String> get sources => settings?.sources ?? [];

  void addSource(String source) {
    settings?.sources.add(source);
    _settingsBox.put('settings', settings!);
    notifyListeners();
  }

  void removeSource(String source) {
    settings?.sources.remove(source);
    _settingsBox.put('settings', settings!);
    notifyListeners();
  }

  Future<void> saveSettings() async {
    await _settingsBox.put('settings', settings!);
    notifyListeners();
  }
}
