import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../models/db/comic_model.dart';
import '../../types/provider/comic_provider.dart';
import '../class/comic_item.dart';
import '../widget/comic_item_widget.dart';

class BookShelfTab extends StatefulWidget {
  const BookShelfTab({super.key});

  @override
  State<BookShelfTab> createState() => _BookShelfTabState();
}

class _BookShelfTabState extends State<BookShelfTab> {
  @override
  Widget build(BuildContext context) {
    List<ComicModel> comics =
        context.watch<ComicProvider>().favoriteComics.values.toList();

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
