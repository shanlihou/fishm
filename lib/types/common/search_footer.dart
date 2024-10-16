import 'package:flutter/material.dart';
import 'package:easy_refresh/easy_refresh.dart';

class SearchFooter extends ClassicFooter {
  final String idleText; // 空闲时的文本
  final String loadingText; // 加载中的文本
  final String noMoreText; // 没有更多数据的文本
  final String failText; // 加载失败的文本
  final String processedText; // 加载成功的文本
  final String readyText; // 准备加载的文本

  SearchFooter({
    this.idleText = "上拉加载更多",
    this.loadingText = "正在加载...",
    this.noMoreText = "没有更多数据了",
    this.failText = "加载失败，点击重试",
    this.processedText = "加载成功",
    this.readyText = "准备加载",
    Color? textColor,
    Color? backgroundColor,
    Color? indicatorColor,
    bool float = false,
  }) : super(
          triggerOffset: 55,
          clamping: false,
          position: IndicatorPosition.behind,
          processedDuration: const Duration(milliseconds: 300),
          springRebound: false,
          safeArea: false,
          hapticFeedback: true,
          showText: false,
        );

  @override
  Widget build(BuildContext context, IndicatorState state) {
    return super.build(context, state);
  }
}
