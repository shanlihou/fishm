import 'dart:async';

class CompleterManager {
  final Map<int, Completer<Object>> _map = {};

  int genCompleteId() {
    int id = 1;
    while (_map.containsKey(id)) {
      id++;
    }
    return id;
  }

  void addCompleter(int id, Completer<Object> completer) {
    _map[id] = completer;
  }

  void commplete(int id, Object value) {
    if (_map.containsKey(id)) {
      _map[id]!.complete(value);
      _map.remove(id);
    }
  }
}

final completerManager = CompleterManager();
