import 'package:hive/hive.dart';

part 'read_history_model.g.dart';

@HiveType(typeId: 5)
class ReadHistoryModel {
  @HiveField(0)
  String chapterId;

  @HiveField(1)
  int index;

  ReadHistoryModel(this.chapterId, this.index);
}
