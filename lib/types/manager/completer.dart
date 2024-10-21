import 'dart:async';

import '../../common/log.dart';

const int TIME_OUT = 10;

class CompleterData {
  Completer<Object> completer;
  DateTime createTime;
  CompleterData()
      : completer = Completer<Object>(),
        createTime = DateTime.now();
}

class CompleterManager {
  final Map<int, CompleterData> _map = {};

  int genCompleteId() {
    int id = 1;
    while (_map.containsKey(id)) {
      id++;
    }
    return id;
  }

  Completer<Object> addCompleter(int id) {
    _map[id] = CompleterData();
    return _map[id]!.completer;
  }

  void commplete(int id, Object value) {
    if (_map.containsKey(id)) {
      _map[id]!.completer.complete(value);
      _map.remove(id);
    }
  }

  void clearTimeOut() {
    var now = DateTime.now();
    List<int> ids = [];
    for (var entry in _map.entries) {
      if (now.difference(entry.value.createTime).inSeconds > TIME_OUT) {
        ids.add(entry.key);
      }
    }

    for (var id in ids) {
      _map[id]!.completer.completeError("time out");
      Log.instance.e("completer time out: $id");
      _map.remove(id);
    }
  }
}

final completerManager = CompleterManager();
