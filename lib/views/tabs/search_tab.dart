import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:toonfu/types/common/search_footer.dart';

import '../../api/flutter_call_lua/method.dart';
import '../../common/log.dart';
import '../../models/api/gallery_result.dart';
import '../../types/common/search_header.dart';
import '../../types/provider/extension_provider.dart';
import '../widget/comic_item_widget.dart';

class SearchResult {
  final String extensionName;
  final GalleryResult galleryResult;
  final String keyword;
  bool allLoaded = false;
  int page = 0;
  final EasyRefreshController easyRefreshController =
      EasyRefreshController(controlFinishLoad: true);

  SearchResult(this.extensionName, this.galleryResult, this.keyword);
}

class SearchTab extends StatefulWidget {
  const SearchTab({super.key});

  @override
  State<SearchTab> createState() => _SearchTabState();
}

class _SearchTabState extends State<SearchTab> {
  ExtensionProvider? extensionProvider;
  TextEditingController searchController = TextEditingController();
  List<SearchResult> searchResults = [];
  bool isSearching = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> _search(String keyword, int page) async {
    if (extensionProvider == null) {
      return;
    }

    if (isSearching) {
      return;
    }

    isSearching = true;

    setState(() {
      searchResults.clear();
    });

    for (var extension in extensionProvider!.extensions) {
      var ret = await search(extension.name, keyword, page);
      GalleryResult galleryResult =
          GalleryResult.fromJson(ret as Map<String, dynamic>);
      setState(() {
        searchResults.add(SearchResult(extension.name, galleryResult, keyword));
      });
    }

    isSearching = false;
  }

  Future<void> _loadMore(SearchResult searchResult) async {
    if (searchResult.allLoaded) {
      searchResult.easyRefreshController.finishLoad(IndicatorResult.noMore);
      return;
    }

    searchResult.page++;
    late GalleryResult galleryResult;
    try {
      var ret = await search(
          searchResult.extensionName, searchResult.keyword, searchResult.page);
      galleryResult = GalleryResult.fromJson(ret as Map<String, dynamic>);
    } catch (e) {
      Log.instance.e(e.toString());
      searchResult.page--;
      searchResult.easyRefreshController.finishLoad(IndicatorResult.fail);
      return;
    }

    if (!galleryResult.success) {
      searchResult.page--;
      searchResult.easyRefreshController.finishLoad(IndicatorResult.fail);
      return;
    }

    if (galleryResult.data.isEmpty) {
      searchResult.allLoaded = true;
      searchResult.easyRefreshController.finishLoad(IndicatorResult.noMore);
      return;
    }

    setState(() {
      searchResult.galleryResult.extend(galleryResult);
    });

    searchResult.easyRefreshController.finishLoad();
  }

  Widget _buildExtensionResult(SearchResult searchResult) {
    return Column(
      children: [
        Text(searchResult.extensionName),
        if (searchResult.galleryResult.success)
          SizedBox(
            height: 0.4.sw,
            width: 1.sw,
            child: EasyRefresh(
              controller: searchResult.easyRefreshController,
              header: SearchHeader(),
              footer: SearchFooter(),
              onLoad: () async {
                await _loadMore(searchResult);
              },
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: searchResult.galleryResult.data.length,
                itemBuilder: (BuildContext context, int index) {
                  return ComicItemWidget(searchResult.galleryResult.data[index],
                      searchResult.extensionName);
                },
              ),
            ),
          )
        else
          const Text('error'),
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
              width: 0.8.sw,
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
              padding: EdgeInsets.zero,
              minSize: 0.1.sw,
              child: const Icon(CupertinoIcons.search),
            ),
          ],
        ),
        Expanded(
          child: ListView.builder(
            itemCount: searchResults.length,
            itemBuilder: (BuildContext context, int index) {
              return _buildExtensionResult(searchResults[index]);
            },
          ),
        ),
      ]),
    );
  }
}
