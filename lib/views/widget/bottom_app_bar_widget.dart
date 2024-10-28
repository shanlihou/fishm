import 'package:flutter/cupertino.dart';

class BottomAppBarWidget extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const BottomAppBarWidget({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: CupertinoTabBar(
            currentIndex: currentIndex,
            onTap: onTap,
            height: 65,
            items: [
              const BottomNavigationBarItem(
                icon: Icon(CupertinoIcons.home),
                label: '首页',
              ),
              const BottomNavigationBarItem(
                icon: Icon(CupertinoIcons.search),
                label: '搜索',
              ),
              // 中间留空
              const BottomNavigationBarItem(
                icon: SizedBox(),
                label: '',
              ),
              const BottomNavigationBarItem(
                icon: Icon(CupertinoIcons.cloud_download),
                label: '下载',
              ),
              const BottomNavigationBarItem(
                icon: Icon(CupertinoIcons.settings),
                label: '设置',
              ),
            ],
          ),
        ),
        // 中间凸起的按钮
        Positioned(
          left: 0,
          right: 0,
          bottom: 30, // 调整按钮位置
          child: GestureDetector(
            onTap: () => onTap(2), // 点击中间按钮时的回调
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: CupertinoColors.activeBlue,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: CupertinoColors.black.withOpacity(0.2),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: const Icon(
                CupertinoIcons.book,
                color: CupertinoColors.white,
                size: 30,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
