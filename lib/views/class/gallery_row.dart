import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../const/general_const.dart';
import '../../types/context/net_iamge_context.dart';
import '../pages/comic_detail_page.dart';
import '../widget/net_image.dart';
import './comic_item.dart';

class GalleryRow {
  final List<ComicItem> items;
  final int maxColumn;

  GalleryRow(this.items, this.maxColumn);

  Widget toWidget(BuildContext context, String extensionName) {
    List<Widget> children = [];

    for (var item in items) {
      children.add(Expanded(
        child: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              CupertinoPageRoute(
                builder: (context) => ComicDetailPage(
                  item,
                  extensionName,
                ),
              ),
            );
          },
          child: Column(
            children: [
              NetImage(
                NetImageType.cover,
                NetImageContextCover(
                  extensionName,
                  item.comicId,
                  item.imageUrl,
                ),
                0.33.sw,
                0.33.sw,
              ),
              Text(item.title),
            ],
          ),
        ),
      ));
    }

    while (children.length < maxColumn) {
      children.add(const Expanded(child: SizedBox()));
    }

    return Container(
      padding: const EdgeInsets.all(10),
      child: Row(
        children: children,
      ),
    );
  }
}
