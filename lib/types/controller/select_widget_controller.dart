import 'package:flutter/widgets.dart';

class SelectWidgetController {
  ValueChanged<String>? labelChanged;
  ValueChanged<List<String>>? itemsChanged;

  set label(String value) {
    labelChanged?.call(value);
  }

  set items(List<String> value) {
    itemsChanged?.call(value);
  }
}
