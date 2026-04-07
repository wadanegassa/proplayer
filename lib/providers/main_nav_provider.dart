import 'package:flutter/foundation.dart';

/// Drives the main tab index so child screens (e.g. Home) can jump to Library/Browse.
class MainNavProvider extends ChangeNotifier {
  int _index = 0;

  int get currentIndex => _index;

  void setIndex(int index) {
    if (index == _index || index < 0 || index > 3) return;
    _index = index;
    notifyListeners();
  }
}
