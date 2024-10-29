import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../common/log.dart';
import '../../const/color_const.dart';

class BottomAppBarWidget extends StatefulWidget {
  final List<Widget> pages;
  final List<String> titles;
  final List<IconData> icons;
  final IconData middleIcon;
  final PageController pageController = PageController();

  BottomAppBarWidget({
    super.key,
    required this.pages,
    required this.titles,
    required this.icons,
    required this.middleIcon,
  });

  @override
  State<BottomAppBarWidget> createState() => _BottomAppBarWidgetState();
}

class _BottomAppBarWidgetState extends State<BottomAppBarWidget> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
  }

  void _onTap(int index) {
    Log.instance.d('onTap: $index');
    widget.pageController.jumpToPage(index);
    setState(() {
      _currentIndex = index;
    });
  }

  bool _isMiddle(int index) {
    return index == widget.titles.length / 2;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: Column(
            children: [
              Expanded(
                child: PageView(
                  physics: const NeverScrollableScrollPhysics(),
                  controller: widget.pageController,
                  children: widget.pages,
                ),
              ),
              CupertinoTabBar(
                currentIndex: _currentIndex,
                onTap: _onTap,
                height: 204.h,
                items: List.generate(widget.titles.length + 1, (index) {
                  if (index == widget.titles.length / 2) {
                    return const BottomNavigationBarItem(
                      icon: SizedBox(),
                    );
                  } else if (index > widget.titles.length / 2) {
                    index -= 1;
                  }

                  return BottomNavigationBarItem(
                    icon: Icon(widget.icons[index]),
                    label: widget.titles[index],
                  );
                }),
              ),
            ],
          ),
        ),
        // 中间凸起的按钮
        Positioned(
          left: 0,
          right: 0,
          bottom: 55.h, // 调整按钮位置
          child: GestureDetector(
            onTap: () => _onTap(2), // 点击中间按钮时的回调
            child: Container(
              width: 212.h,
              height: 212.h,
              decoration: BoxDecoration(
                color: _isMiddle(_currentIndex)
                    ? CupertinoColors.white
                    : iconColor88,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Container(
                  width: 180.h,
                  height: 180.h,
                  decoration: BoxDecoration(
                    color: _isMiddle(_currentIndex)
                        ? iconColor
                        : CupertinoColors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: CupertinoColors.black.withOpacity(0.2),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: Icon(
                    CupertinoIcons.book,
                    color: _isMiddle(_currentIndex)
                        ? CupertinoColors.white
                        : iconColor,
                    size: 30,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
