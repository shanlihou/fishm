import 'package:easy_refresh/easy_refresh.dart';

class SearchHeader extends ClassicHeader {
  String idleText;
  String loadingText;
  String noMoreText;
  String failText;

  SearchHeader({
    super.key,
    super.triggerOffset,
    super.clamping,
    super.position,
    super.processedDuration,
    super.springRebound,
    this.idleText = "下拉加载更多",
    this.loadingText = "正在加载...",
    this.noMoreText = "没有更多数据了",
    this.failText = "加载失败，点击重试",
  });
}
