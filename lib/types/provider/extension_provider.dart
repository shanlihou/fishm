import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import '../../const/db_const.dart';
import '../../models/db/extensions.dart' as model_extensions;

class ExtensionProvider with ChangeNotifier {
  bool _isLoad = false;
  late Box<model_extensions.Extensions> _extensionsBox;
  model_extensions.Extensions? _extensions;

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

    notifyListeners();
  }

  void updateExtension(model_extensions.Extension extension) {
    for (var i = _extensions!.extensions.length - 1; i >= 0; i--) {
      if (_extensions!.extensions[i].name == extension.name) {
        _extensions!.extensions[i] = extension;
        break;
      }
    }

    _extensionsBox.put(extensionKey, _extensions!);
    notifyListeners();
  }

  List<model_extensions.Extension> get extensions =>
      _extensions?.extensions ?? [];
}
