import 'package:flutter/foundation.dart';

class AppNavigation extends ChangeNotifier {
  int _index = 0;
  int get index => _index;
  void select(int index) {
    if (index == _index) return;
    _index = index;
    notifyListeners();
  }
}
