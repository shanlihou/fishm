import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:toonfu/const/general_const.dart';
import 'package:toonfu/models/db/comic_model.dart';
import 'package:toonfu/types/provider/comic_provider.dart';

import '../../types/context/net_iamge_context.dart';
import '../class/comic_item.dart';
import '../pages/comic_detail_page.dart';
import '../widget/net_image.dart';

class HistoryTab extends StatefulWidget {
  const HistoryTab({super.key});

  @override
  State<HistoryTab> createState() => _HistoryTabState();
}

class _HistoryTabState extends State<HistoryTab> {
  Widget _buildHistoryItem(ComicModel comic, BuildContext buildContext) {
    return Container(
      child: GestureDetector(
        onTap: () {
          context.read<ComicProvider>().addComic(comic);
          ComicItem item = ComicItem.fromComicModel(comic);
          Navigator.push(
            buildContext,
            CupertinoPageRoute(
              builder: (context) => ComicDetailPage(item, comic.extensionName),
            ),
          );
        },
        child: Column(
          children: [
            NetImage(
              NetImageType.cover,
              NetImageContextCover(comic.extensionName, comic.id, comic.cover),
              0.2.sw,
              0.2.sw,
            ),
            Text(comic.title),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<ComicModel> comics = context.watch<ComicProvider>().historyComics;

    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('历史记录'),
      ),
      child: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: comics.length,
                itemBuilder: (context, index) {
                  return _buildHistoryItem(comics[index], context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
