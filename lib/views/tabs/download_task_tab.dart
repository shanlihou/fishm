import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' as material;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../const/assets_const.dart';
import '../../const/general_const.dart';
import '../../models/db/comic_model.dart';
import '../../types/context/extension_comic_reader_context.dart';
import '../../types/provider/comic_provider.dart';
import '../../types/provider/task_provider.dart';
import '../../types/task/task_download.dart';
import '../../utils/utils_general.dart';
import '../pages/reader_page.dart';

class DownloadTaskTab extends StatefulWidget {
  const DownloadTaskTab({super.key});

  @override
  State<DownloadTaskTab> createState() => _DownloadTaskTabState();
}

void _gotoReaderPage(BuildContext context, TaskDownload task) {
  ComicProvider p = context.read<ComicProvider>();
  String uniqueId = getComicUniqueId(task.comicId, task.extensionName);
  ComicModel? comicModel = p.getComicModel(uniqueId);
  if (comicModel == null) {
    return;
  }

  Navigator.push(
    context,
    CupertinoPageRoute(
        builder: (context) => ReaderPage(
            readerContext: ExtensionComicReaderContext(task.extensionName,
                task.comicId, task.chapterId, null, comicModel.extra))),
  );
}

class _DownloadTaskTabState extends State<DownloadTaskTab> {
  List<bool> _selectedTasks = [];
  int _selectNum = 0;

  void _deleteTasks() {
    var p = context.read<TaskProvider>();
    var tasks = p.getTasks();
    if (tasks.length != _selectedTasks.length) {
      return;
    }

    List<String> ids = [];

    for (var i = 0; i < tasks.length; i++) {
      if (_selectedTasks[i]) {
        ids.add(tasks[i].id);
      }
    }

    p.removeTasks(ids);
  }

  Widget _buildTaskStatus(TaskDownload task) {
    if (task.status == TaskStatus.running || task.status == TaskStatus.ready) {
      return Text(
        style: TextStyle(
            fontSize: 40.spMin, color: const Color.fromARGB(255, 18, 148, 199)),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        '${task.currentCount}/${task.imageCount}',
      );
    } else if (task.status == TaskStatus.finished) {
      return GestureDetector(
        onTap: () => _gotoReaderPage(context, task),
        child: Image.asset(
          goToRead,
          width: 60.w,
          height: 60.h,
        ),
      );
    } else if (task.status == TaskStatus.failed) {
      return const Icon(CupertinoIcons.xmark_circle,
          color: CupertinoColors.systemRed);
    }

    return Text(
      style: TextStyle(fontSize: 40.spMin),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      task.status.name,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Consumer<TaskProvider>(
            builder: (context, provider, child) {
              var tasks = provider.getTasks();
              if (tasks.length != _selectedTasks.length) {
                _selectedTasks = List.filled(tasks.length, false);
                _selectNum = 0;
              }

              return ListView.builder(
                itemCount: tasks.length,
                itemBuilder: (context, index) {
                  var task = tasks[index];
                  return GestureDetector(
                    onLongPress: () {
                      provider.removeTask(task.id);
                    },
                    child: Container(
                      width: double.infinity,
                      color: CupertinoColors.white,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (index != 0)
                            Container(
                              height: 0.7.h,
                              margin: EdgeInsets.only(left: 40.w, right: 40.w),
                              color: CupertinoColors.separator,
                            ),
                          Container(
                            margin: EdgeInsets.only(
                                left: 80.w,
                                right: 80.w,
                                top: 20.h,
                                bottom: 20.h),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      margin: EdgeInsets.only(right: 20.w),
                                      height: 40.h,
                                      width: 40.w,
                                      child: CupertinoCheckbox(
                                        shape: const CircleBorder(),
                                        value: _selectedTasks[index],
                                        onChanged: (value) {
                                          setState(() {
                                            print('value: $value');
                                            bool val = value ?? false;
                                            _selectedTasks[index] = val;

                                            if (val) {
                                              _selectNum++;
                                            } else {
                                              _selectNum--;
                                            }
                                          });
                                        },
                                      ),
                                    ),
                                    SizedBox(
                                        width: 550.w,
                                        child: Text(
                                            style: TextStyle(
                                              fontSize: 40.spMin,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            task.displayText())),
                                  ],
                                ),
                                Expanded(
                                  child: Container(
                                      alignment: Alignment.centerRight,
                                      height: 90.h,
                                      child: _buildTaskStatus(task)),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
        Container(
          height: 150.h,
          width: double.infinity,
          color: CupertinoColors.white,
          child:
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Row(
              children: [
                Container(
                  margin: EdgeInsets.only(left: 20.w),
                  child: CupertinoCheckbox(
                    value:
                        _selectNum == _selectedTasks.length && _selectNum != 0,
                    onChanged: (value) {
                      bool val = value ?? false;
                      if (val) {
                        _selectedTasks =
                            List.filled(_selectedTasks.length, true);
                        _selectNum = _selectedTasks.length;
                      } else {
                        _selectedTasks =
                            List.filled(_selectedTasks.length, false);
                        _selectNum = 0;
                      }
                      setState(() {});
                    },
                  ),
                ),
                Text('Select All'),
              ],
            ),
            SizedBox(
              width: 200.w,
              height: 100.h,
              child: CupertinoButton(
                color: CupertinoColors.systemRed,
                padding: EdgeInsets.all(0),
                child: Text(
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  'Delete',
                  style: TextStyle(
                      color: CupertinoColors.white, fontSize: pm(16, 50.spMin)),
                ),
                onPressed: _deleteTasks,
              ),
            ),
          ]),
        ),
      ],
    );
  }
}
