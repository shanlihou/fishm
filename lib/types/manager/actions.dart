import '../../api/flutter_call_lua/action.dart';
import 'package:lua_dardo_co/lua.dart';


class ActionsManager {
  List<Action> actions = [];

  void addAction(Action action) {
    actions.add(action);
  }

  bool hasActions() {
    return actions.isNotEmpty;
  }

  void toTableList(LuaState ls) {
    ls.newTable();
    for (int i = 0; i < actions.length; i++) {
      ls.pushInteger(i + 1);
      actions[i].toLuaTable(ls);
      ls.setTable(-3);
    }

    actions.clear();
  }
}

final actionsManager = ActionsManager();

