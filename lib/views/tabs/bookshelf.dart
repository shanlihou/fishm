import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../models/db/comic_model.dart';
import '../../types/provider/comic_provider.dart';
import '../class/comic_item.dart';
import '../widget/comic_item_widget.dart';
import 'favorite_tab.dart';
import 'history_tab.dart';

class BookShelfTab extends StatefulWidget {
  const BookShelfTab({super.key});

  @override
  State<BookShelfTab> createState() => _BookShelfTabState();
}

class _BookShelfTabState extends State<BookShelfTab> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  Widget _buildPageView() {
    return Positioned(
      left: 255.w,
      top: 37.h,
      child: Container(
        decoration: BoxDecoration(
          color: CupertinoColors.white,
          boxShadow: [
            BoxShadow(
              color: const Color.fromRGBO(0, 0, 0, 0.05),
              blurRadius: 16.w,
            ),
          ],
        ),
        width: 893.w,
        height: 1240.h,
        child: PageView(
          controller: _pageController,
          children: const [
            FavoriteTab(),
            HistoryTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildTabItem(double top, String title, int index) {
    bool front = index == _currentIndex;
    return Positioned(
      left: 20.w,
      top: top,
      child: GestureDetector(
        onTap: () => _onTap(index),
        child: Container(
          decoration: BoxDecoration(
            color: front ? CupertinoColors.white : const Color(0xFFEFEFEF),
            borderRadius: BorderRadius.all(Radius.circular(16.r)),
            boxShadow: [
              BoxShadow(
                color: const Color.fromRGBO(0, 0, 0, 0.05),
                blurRadius: 16.w,
              ),
            ],
          ),
          width: 235.w,
          height: 149.h,
          child: Center(
            child: Text(title),
          ),
          //#EFEFEF 100%
        ),
      ),
    );
  }

  void _onTap(int index) {
    setState(() {
      _currentIndex = index;
    });
    _pageController.jumpToPage(index);
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> children;
    var fav = _buildTabItem(37.h, '收藏', 0);
    var history = _buildTabItem(200.h, '历史', 1);
    var pageView = _buildPageView();

    if (_currentIndex == 0) {
      children = [history, pageView, fav];
    } else {
      children = [fav, pageView, history];
    }

    return Container(
      // #7F83F7 6%
      color: const Color(0xFF7F83F7).withOpacity(0.06),
      child: Stack(
        children: children,
      ),
    );
  }
}
