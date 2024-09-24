import 'package:flutter/material.dart';
import './comic_item.dart';
import '../pages/detail.dart';

class GalleryRow {
  final List<ComicItem> items;
  final int maxColumn;

  GalleryRow(this.items, this.maxColumn);

  Widget toWidget(BuildContext context, String extensionName) {
    List<Widget> children = [];

    for (var item in items) {
      children.add(Expanded(
        child: Column(
          children: [
            GestureDetector(
              onTap: () {
                // 在这里添加点击图片时的操作
                print('点击了图片: ${item.title}');
                // 这里跳转到详情页
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ComicDetailPage(
                      extensionName,
                      item.extra,
                      title: item.title,
                      author: '未知',
                      coverImage: item.imageUrl,
                      description: '暂无简介',
                    ),
                  ),
                );
              },
              child: Image.network(
                item.imageUrl,
                width: 100,
                height: 100,
                errorBuilder: (context, error, stackTrace) {
                  return const SizedBox(
                    width: 100,
                    height: 100,
                    child: Icon(Icons.error),
                  );
                },
              ),
            ),
            Text(item.title),
          ],
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
