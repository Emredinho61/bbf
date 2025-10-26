import 'package:flutter/material.dart';

class LoadingProvider extends ChangeNotifier {
  bool _isLoading = false;
  bool _showCheckmark = false;

  bool get isLoading => _isLoading;
  bool get showCheckmark => _showCheckmark;

  void startLoading() {
    _isLoading = true;
    _showCheckmark = false;
    notifyListeners();
  }

  void stopLoadingWithCheckmark() async {
    _isLoading = false;
    _showCheckmark = true;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 1));
    _showCheckmark = false;
    notifyListeners();
  }

  void stopLoading() {
    _isLoading = false;
    notifyListeners();
  }
}
