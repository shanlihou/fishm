import 'package:flutter/cupertino.dart';

import '../../const/general_const.dart';

abstract class TaskBase {
  String id;
  DateTime? createTime;
  TaskStatus status;
  TaskBase({required this.id, this.status = TaskStatus.ready});
  Stream<bool> run(BuildContext context);

  double progress();
  void reset();
  String displayText();

  void setStatus(TaskStatus status) {
    this.status = status;
  }
}
