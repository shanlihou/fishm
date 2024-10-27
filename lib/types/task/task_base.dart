import 'package:flutter/cupertino.dart';

import '../../const/general_const.dart';
import 'task_download.dart';

abstract class TaskBase {
  static const int taskType = 0;
  String id;
  DateTime? createTime;
  TaskStatus status;
  TaskBase({required this.id, this.status = TaskStatus.ready});
  Stream<bool> run(BuildContext context);

  double progress();
  void reset();
  String displayText();

  String archive();
  int get taskTypeValue;

  String toArchiveString() {
    var ret = archive();
    String taskTypeStr = taskTypeValue.toString().padLeft(3, '0');
    return '$taskTypeStr$ret';
  }

  static TaskBase fromArchiveString(String archiveString) {
    var taskTypeStr = archiveString.substring(0, 3);
    var taskType = int.parse(taskTypeStr);
    var archive = archiveString.substring(3);
    if (taskType == taskTypeDownload) {
      return TaskDownload.fromJsonString(archive);
    }
    throw Exception('unknown task type');
  }

  void setStatus(TaskStatus status) {
    this.status = status;
  }
}
