import 'package:flutter/cupertino.dart';

import '../../common/log.dart';
import '../../const/general_const.dart';
import '../../types/provider/task_provider.dart';

mixin TaskMixin {
  BuildContext getContext() {
    throw UnimplementedError();
  }

  Future<void> startTaskLoop(TaskProvider provider) async {
    await Future.delayed(const Duration(milliseconds: 1000));

    while (true) {
      var task = provider.getAvailableTask();
      if (task == null) {
        await Future.delayed(const Duration(milliseconds: 100));
        continue;
      }

      provider.changeTaskStatus(task.id, TaskStatus.running);

      try {
        await for (var ret in task.run(getContext())) {
          if (!ret) {
            provider.changeTaskStatus(task.id, TaskStatus.failed);
            continue;
          }

          provider.onTaskUpdate(task.id);
        }

        provider.changeTaskStatus(task.id, TaskStatus.finished);
      } catch (e) {
        Log.instance.e('task run error $e');
        provider.changeTaskStatus(task.id, TaskStatus.failed);
      }
    }
  }
}
