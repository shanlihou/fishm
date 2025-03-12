import 'package:flutter/cupertino.dart';
import 'package:hive/hive.dart';

import '../../const/db_const.dart';
import '../../models/db/extensions.dart' as model_extensions;
import '../../utils/utils_general.dart';
import '../manager/plugin_db_manager.dart';

class ExtensionProvider with ChangeNotifier {
  bool _isLoad = false;
  late Box<model_extensions.Extensions> _extensionsBox;
  model_extensions.Extensions? _extensions;
  model_extensions.Extensions? _extensionsStore;

  ExtensionProvider();

  Future<void> loadExtensions() async {
    if (_isLoad) {
      return;
    }

    _isLoad = true;
    _extensionsBox =
        await Hive.openBox<model_extensions.Extensions>(extensionKey);

    _extensions = _extensionsBox.get(extensionKey);
    if (_extensions == null) {
      _extensions = model_extensions.Extensions.defaultExtensions();
      await _extensionsBox.put(extensionKey, _extensions!);
    }

    _extensionsStore = _extensionsBox.get(extensionStoreKey);
    if (_extensionsStore == null) {
      _extensionsStore = model_extensions.Extensions.defaultExtensions();
      await _extensionsBox.put(extensionStoreKey, _extensionsStore!);
    }

    notifyListeners();
  }

  Future<void> removeExtension(String name) async {
    _extensions!.extensions.removeWhere((e) => e.name == name);
    await _extensionsBox.put(extensionKey, _extensions!);
    notifyListeners();
  }

  model_extensions.Extension? getStoreExtension(String name) {
    return _extensionsStore!.extensions.firstWhere((e) => e.name == name);
  }

  List<String> extensionNames() {
    return extensions.map((e) => e.name).toList();
  }

  void updateExtension(model_extensions.Extension extension) {
    bool found = false;
    for (var i = _extensions!.extensions.length - 1; i >= 0; i--) {
      if (_extensions!.extensions[i].name == extension.name) {
        _extensions!.extensions[i] = extension;
        found = true;
        break;
      }
    }

    if (!found) {
      _extensions!.extensions.add(extension);
    }

    _extensionsBox.put(extensionKey, _extensions!);
    pluginDbManager.initPlugin(extension.name);
    notifyListeners();
  }

  void removeExtensionStore(String name) {
    _extensionsStore!.extensions.removeWhere((e) => e.name == name);
    _extensionsBox.put(extensionStoreKey, _extensionsStore!);
    notifyListeners();
  }

  void updateExtensionStore(List<model_extensions.Extension> extensions) {
    mergeExtensions(_extensionsStore!.extensions, extensions);
    _extensionsBox.put(extensionStoreKey, _extensionsStore!);
    notifyListeners();
  }

  List<model_extensions.Extension> get extensions =>
      _extensions?.extensions ?? [];

  List<model_extensions.Extension> get extensionsStore =>
      _extensionsStore?.extensions ?? [];
}
