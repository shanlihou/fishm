import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:toonfu/models/db/comic_model.dart';
import 'package:toonfu/types/provider/comic_provider.dart';

import '../class/comic_item.dart';
import '../widget/comic_item_widget.dart';

class HistoryTab extends StatefulWidget {
  const HistoryTab({super.key});

  @override
  State<HistoryTab> createState() => _HistoryTabState();
}

class _HistoryTabState extends State<HistoryTab> {
  Set<int> selectedIndices = {};
  bool isSelectionMode = false;

  @override
  Widget build(BuildContext context) {
    List<ComicModel> comics = context.watch<ComicProvider>().historyComics;

    return Stack(
      children: [
        ListView.builder(
          itemCount: comics.length,
          itemBuilder: (context, index) {
            return GestureDetector(
              onLongPress: () {
                setState(() {
                  isSelectionMode = true;
                  selectedIndices.add(index);
                });
              },
              child: Container(
                color: selectedIndices.contains(index)
                    ? CupertinoColors.systemGrey5
                    : null,
                child: Row(
                  children: [
                    if (isSelectionMode)
                      CupertinoCheckbox(
                        value: selectedIndices.contains(index),
                        onChanged: (bool? value) {
                          setState(() {
                            if (value == true) {
                              selectedIndices.add(index);
                            } else {
                              selectedIndices.remove(index);
                            }
                          });
                        },
                      ),
                    Expanded(
                      child: ComicItemWidget(
                        ComicItem.fromComicModel(comics[index]),
                        comics[index].extensionName,
                        width: 405.w,
                        height: 541.h,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        if (isSelectionMode)
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Center(
              child: CupertinoButton(
                color: CupertinoColors.destructiveRed,
                child: const Text('delete'),
                onPressed: () {
                  List<String> uniqueIds = selectedIndices.map((index) {
                    return comics[index].uniqueId;
                  }).toList();
                  isSelectionMode = false;
                  selectedIndices.clear();
                  context.read<ComicProvider>().removeHistoryComic(uniqueIds);
                },
              ),
            ),
          ),
      ],
    );
  }
}
