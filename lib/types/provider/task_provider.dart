import 'package:flutter/cupertino.dart';
import 'package:hive/hive.dart';
import 'package:toonfu/types/task/task_download.dart';
import '../../const/db_const.dart';
import '../../const/general_const.dart';

class TaskProvider extends ChangeNotifier {
  Map<String, TaskDownload> tasks = {};

  Future<void> loadTasks() async {
    var box = Hive.box(taskHiveKey);
    var entries = box.toMap().entries;
    for (var entry in entries) {
      tasks[entry.key] = TaskDownload.fromJsonString(entry.value as String);
    }
  }

  TaskDownload? getAvailableTask() {
    for (var task in tasks.values) {
      if (task.status == TaskStatus.ready ||
          task.status == TaskStatus.running) {
        return task;
      }
    }
    return null;
  }

  void removeTasks(List<String> ids) {
    for (var id in ids) {
      removeTask(id, notify: false);
    }
    notifyListeners();
  }

  List<TaskDownload> getTasks() {
    var tasks = this.tasks.values.toList();
    tasks.sort((a, b) => a.createTime!.compareTo(b.createTime!));
    return tasks;
  }

  bool isExtensionInUse(String extensionName) {
    for (var task in tasks.values) {
      if (task.extensionName == extensionName) {
        return true;
      }
    }
    return false;
  }

  bool isHasTask(String id) {
    return tasks.containsKey(id);
  }

  void removeTask(String id, {bool notify = true}) {
    var task = tasks.remove(id);
    if (task == null) {
      return;
    }

    task.setStatus(TaskStatus.deleted);
    Hive.box(taskHiveKey).delete(id);
    if (notify) {
      notifyListeners();
    }
  }

  void addTask(TaskDownload task) {
    if (tasks.containsKey(task.id)) {
      throw Exception('task id already exists');
    }
    task.createTime = DateTime.now();
    tasks[task.id] = task;

    Hive.box(taskHiveKey).put(task.id, task.archive());
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
    Hive.box(taskHiveKey).put(id, task.archive());
    notifyListeners();
  }
}
