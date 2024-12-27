import 'package:flutter/widgets.dart';
import '../../const/general_const.dart';

class TabProvider extends ChangeNotifier {
  int currentIndex = initTabIndex;

  void setCurrentIndex(int index) {
    currentIndex = index;
    notifyListeners();
  }
}
