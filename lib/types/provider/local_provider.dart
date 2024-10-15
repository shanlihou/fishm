import 'package:flutter/cupertino.dart';

class LocalProvider extends ChangeNotifier {
  Locale _locale = Locale('en');

  Locale get locale => _locale;

  void setLocale(Locale locale) {
    _locale = locale;
    notifyListeners();
  }
}
