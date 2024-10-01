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
  @override
  Widget build(BuildContext context) {
    List<ComicModel> comics = context.watch<ComicProvider>().historyComics;

    return ListView.builder(
      itemCount: comics.length,
      itemBuilder: (context, index) {
        return ComicItemWidget(
          ComicItem.fromComicModel(comics[index]),
          comics[index].extensionName,
          width: 0.2.sw,
          height: 0.2.sw,
        );
      },
    );
  }
}
