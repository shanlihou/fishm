import 'package:flutter/cupertino.dart';
import '../widget/comic_item_widget.dart';
import './comic_item.dart';

class GalleryRow {
  final List<ComicItem> items;
  final int maxColumn;

  GalleryRow(this.items, this.maxColumn);

  Widget toWidget(BuildContext context, String extensionName) {
    List<Widget> children = [];

    for (var item in items) {
      children.add(Expanded(
        child: ComicItemWidget(item, extensionName),
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
