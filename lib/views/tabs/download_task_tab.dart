import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' as material;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../types/provider/task_provider.dart';

class DownloadTaskTab extends StatefulWidget {
  const DownloadTaskTab({super.key});

  @override
  State<DownloadTaskTab> createState() => _DownloadTaskTabState();
}

class _DownloadTaskTabState extends State<DownloadTaskTab> {
  @override
  Widget build(BuildContext context) {
    return Consumer<TaskProvider>(
      builder: (context, provider, child) {
        var tasks = provider.getTasks();
        return ListView.builder(
          itemCount: tasks.length,
          itemBuilder: (context, index) {
            var task = tasks[index];
            return Container(
              width: double.infinity,
              color: CupertinoColors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (index != 0)
                    Container(
                      height: 1,
                      margin: EdgeInsets.only(left: 40.w, right: 40.w),
                      color: CupertinoColors.separator,
                    ),
                  Container(
                    margin: EdgeInsets.only(
                        left: 80.w, right: 80.w, top: 20.h, bottom: 20.h),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(task.displayText()),
                        Text(task.status.name),
                      ],
                    ),
                  ),
                  // const SizedBox(height: 4),
                  // material.Material(
                  //   child: material.LinearProgressIndicator(
                  //     value: task.progress(),
                  //   ),
                  // ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
