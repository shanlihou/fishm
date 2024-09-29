import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../api/flutter_call_lua/method.dart';
import '../../models/api/gallery_result.dart';
import '../../types/provider/extension_provider.dart';
import '../widget/comic_item_widget.dart';

class SearchTab extends StatefulWidget {
  const SearchTab({super.key});

  @override
  State<SearchTab> createState() => _SearchTabState();
}

class _SearchTabState extends State<SearchTab> {
  ExtensionProvider? extensionProvider;
  TextEditingController searchController = TextEditingController();
  List<(String, GalleryResult)> searchResults = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _search(String keyword, int page) async {
    if (extensionProvider == null) {
      return;
    }

    for (var extension in extensionProvider!.extensions) {
      var ret = await search(extension.name, keyword, page);
      GalleryResult galleryResult =
          GalleryResult.fromJson(ret as Map<String, dynamic>);
      setState(() {
        searchResults.add((extension.name, galleryResult));
      });
    }
  }

  Widget _buildExtensionResult(
      String extensionName, GalleryResult galleryResult) {
    return Column(
      children: [
        Text(extensionName),
        if (galleryResult.success)
          SizedBox(
            height: 0.4.sw,
            width: 1.sw,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: galleryResult.data.length,
              itemBuilder: (BuildContext context, int index) {
                return ComicItemWidget(
                    galleryResult.data[index], extensionName);
              },
            ),
          )
        else
          Text('error'),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    extensionProvider ??= context.read<ExtensionProvider>();

    return Center(
      child: Column(children: [
        Row(
          children: [
            SizedBox(
              width: 0.9.sw,
              child: CupertinoTextField(
                controller: searchController,
                placeholder: 'name of comic',
                decoration: BoxDecoration(
                  color: CupertinoColors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            CupertinoButton(
              onPressed: () {
                _search(searchController.text, 0);
              },
              child: const Icon(CupertinoIcons.search),
            ),
          ],
        ),
        Expanded(
          child: ListView.builder(
            itemCount: searchResults.length,
            itemBuilder: (BuildContext context, int index) {
              return _buildExtensionResult(
                  searchResults[index].$1, searchResults[index].$2);
            },
          ),
        ),
      ]),
    );
  }
}
