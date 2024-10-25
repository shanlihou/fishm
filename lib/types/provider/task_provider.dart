import 'package:flutter/cupertino.dart';
import '../../const/general_const.dart';
import '../task/task_base.dart';

class TaskProvider extends ChangeNotifier {
  Map<String, TaskBase> tasks = {};

  TaskBase? getAvailableTask() {
    for (var task in tasks.values) {
      if (task.status == TaskStatus.ready) {
        return task;
      }
    }
    return null;
  }

  List<TaskBase> getTasks() {
    var tasks = this.tasks.values.toList();
    tasks.sort((a, b) => a.createTime!.compareTo(b.createTime!));
    return tasks;
  }

  bool isHasTask(String id) {
    return tasks.containsKey(id);
  }

  void addTask(TaskBase task) {
    if (tasks.containsKey(task.id)) {
      throw Exception('task id already exists');
    }
    task.createTime = DateTime.now();
    tasks[task.id] = task;
    notifyListeners();
  }

  void onTaskUpdate(String id) {
    notifyListeners();
  }

  void changeTaskStatus(String id, TaskStatus status) {
    var task = tasks[id];
    if (task == null) {
      return;
    }
    task.setStatus(status);
    notifyListeners();
  }
}
