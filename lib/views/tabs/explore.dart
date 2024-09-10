import 'package:flutter/material.dart';
import '../../api/flutter_call_lua/method.dart';
import '../../common/log.dart';
import '../class/gallery_row.dart';
import '../class/comic_item.dart';


class ExploreTab extends StatefulWidget {
  const ExploreTab({super.key});

  @override
  State<ExploreTab> createState() => _ExploreTabState();
}

class _ExploreTabState extends State<ExploreTab> with SingleTickerProviderStateMixin {
  final int maxColumn = 3;
  List<GalleryRow> galleryRows = [];

  @override
  void initState() {
    super.initState();
    getGallery();
  }

  void getGallery() async {
    List<Object> ret = await gallery();
    // Log.instance.d('get gallery: $ret');
    updateGallery(ret);
  }

  void updateGallery(List<Object> data) {
    setState(() {
      galleryRows.clear();
      while (data.isNotEmpty) {
        List<ComicItem> items = [];
        for (int i = 0; i < maxColumn; i++) {
          if (data.isEmpty) {
            break;
          }

          var val = data.removeAt(0) as Map<String, dynamic>;
          if (!(val.containsKey('cover') && val.containsKey('title'))) {
            continue;
          }

          items.add(ComicItem.fromJson(val));
        }

        galleryRows.add(GalleryRow(items, maxColumn));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: galleryRows.length,
      itemBuilder: (BuildContext context, int index) {
        return galleryRows[index].toWidget(context);
      },
    );
  }
}
