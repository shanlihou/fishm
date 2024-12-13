import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../api/flutter_call_lua/method.dart';
import '../../common/log.dart';
import '../../const/color_const.dart';
import '../../models/api/gallery_result.dart';
import '../../types/common/search_footer.dart';
import '../../types/common/search_header.dart';
import '../class/comic_item.dart';
import 'comic_item_widget.dart';
import 'package:flutter_gen/gen_l10n/localizations.dart';

class SearchResultController {
  ValueChanged<String>? onChanged;

  void setKeyword(String keyword) {
    onChanged?.call(keyword);
  }

  void dispose() {
    onChanged = null;
  }

  SearchResultController();
}

class SearchResultWidget extends StatefulWidget {
  final String extensionName;
  final String displayName;
  final SearchResultController controller;

  const SearchResultWidget(
      {super.key,
      required this.extensionName,
      required this.displayName,
      required this.controller});

  @override
  State<SearchResultWidget> createState() => _SearchResultWidgetState();
}

class _SearchResultWidgetState extends State<SearchResultWidget> {
  int _page = 0;
  String _keyword = '';
  final List<ComicItem> _comicItems = [];
  bool _isLoading = false;
  final EasyRefreshController _easyRefreshController = EasyRefreshController(
    controlFinishLoad: true,
  );

  @override
  void initState() {
    super.initState();
    widget.controller.onChanged = _onKeywordChanged;
  }

  void _onKeywordChanged(String keyword) {
    _page = 0;
    _keyword = keyword;
    _comicItems.clear();
    _loadMore();
  }

  Future<void> _loadMore() async {
    if (_isLoading) {
      return;
    }

    _isLoading = true;
    if (mounted) {
      setState(() {});
    }
    Log.instance.d('search ${widget.extensionName} $_keyword $_page');
    var ret = await search(widget.extensionName, _keyword, _page);
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
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _easyRefreshController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget result;
    double height = 0.4.sw;
    double width = 1.sw;
    if (_isLoading && _comicItems.isEmpty) {
      result = Container(
          height: height,
          width: width,
          alignment: Alignment.center,
          child: const CupertinoActivityIndicator());
    } else {
      result = SizedBox(
        height: height,
        width: width,
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
              return Container(
                margin: EdgeInsets.only(right: 20.w),
                child: ComicItemWidget(
                  _comicItems[index],
                  widget.extensionName,
                  width: 405.w,
                  height: 541.h,
                ),
              );
            },
          ),
        ),
      );
    }
    return Container(
      decoration: BoxDecoration(
        color: CupertinoColors.white,
        borderRadius: BorderRadius.circular(10.r),
      ),
      margin: EdgeInsets.fromLTRB(43.w, 44.h, 43.w, 0),
      child: Column(
        children: [
          Container(
            alignment: Alignment.centerLeft,
            margin: EdgeInsets.fromLTRB(40.w, 20.h, 20.w, 0),
            child: Text(
                style: const TextStyle(color: lineColor),
                '${AppLocalizations.of(context)!.extensions} : ${widget.displayName}'),
          ),
          Container(
            margin: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 0),
            color: lineColor,
            height: 1.h,
          ),
          result,
        ],
      ),
    );
  }
}
