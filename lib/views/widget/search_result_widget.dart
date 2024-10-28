import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../api/flutter_call_lua/method.dart';
import '../../common/log.dart';
import '../../models/api/gallery_result.dart';
import '../../types/common/search_footer.dart';
import '../../types/common/search_header.dart';
import '../class/comic_item.dart';
import 'comic_item_widget.dart';

class SearchResultWidget extends StatefulWidget {
  final String extensionName;
  final String keyword;

  const SearchResultWidget(
      {super.key, required this.extensionName, required this.keyword});

  @override
  State<SearchResultWidget> createState() => _SearchResultWidgetState();
}

class _SearchResultWidgetState extends State<SearchResultWidget> {
  int _page = 0;
  final List<ComicItem> _comicItems = [];
  bool _isLoading = false;
  final EasyRefreshController _easyRefreshController = EasyRefreshController(
    controlFinishLoad: true,
  );

  @override
  void initState() {
    super.initState();
    _loadMore();
  }

  @override
  void didUpdateWidget(covariant SearchResultWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.keyword != widget.keyword) {
      _page = 0;
      _comicItems.clear();
      _loadMore();
    }
  }

  Future<void> _loadMore() async {
    if (_isLoading) {
      return;
    }

    _isLoading = true;
    Log.instance.d('search ${widget.extensionName} ${widget.keyword} $_page');
    var ret = await search(widget.extensionName, widget.keyword, _page);
    try {
      var galleryResult = GalleryResult.fromJson(ret as Map<String, dynamic>);
      if (galleryResult.success) {
        if (mounted) {
          setState(() {
            _comicItems.addAll(galleryResult.data);
          });
        }
        _page++;

        if (galleryResult.data.isEmpty) {
          _easyRefreshController.finishLoad(IndicatorResult.noMore);
        } else if (galleryResult.noMore) {
          _easyRefreshController.finishLoad(IndicatorResult.noMore);
        } else {
          _easyRefreshController.finishLoad(IndicatorResult.success);
        }
      } else {
        _easyRefreshController.finishLoad(IndicatorResult.fail);
      }
    } catch (e) {
      Log.instance.e('search $widget.extensionName failed: $e');
      _easyRefreshController.finishLoad(IndicatorResult.fail);
    }

    _isLoading = false;
  }

  @override
  void dispose() {
    _easyRefreshController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(widget.extensionName),
        SizedBox(
          height: 0.4.sw,
          width: 1.sw,
          child: EasyRefresh(
            controller: _easyRefreshController,
            header: SearchHeader(),
            footer: SearchFooter(),
            onLoad: () async {
              await _loadMore();
            },
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _comicItems.length,
              itemBuilder: (BuildContext context, int index) {
                return ComicItemWidget(
                    _comicItems[index], widget.extensionName);
              },
            ),
          ),
        )
      ],
    );
  }
}
