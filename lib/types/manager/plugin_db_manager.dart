import 'package:hive_flutter/hive_flutter.dart';

class PluginDbManager {
  Map<String, bool> pluginInit = {};

  void initPlugin(String plugin) {
    if (pluginInit[plugin] == null) {
      pluginInit[plugin] = true;
      Hive.openBox(plugin);
    }
  }

  void initPlugins(List<String> plugins) {
    for (var plugin in plugins) {
      initPlugin(plugin);
    }
  }
}

PluginDbManager pluginDbManager = PluginDbManager();
