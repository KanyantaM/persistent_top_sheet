import 'package:flutter/material.dart';

/// The controller that can be used to open, close, or toggle the top sheet.
class PersistentTopSheetController extends ChangeNotifier {
  PersistentTopSheetController({
    bool initialIsOpen = false,
    double initialHeight = 0,
  })  : _isOpen = initialIsOpen,
        _currentHeight = initialHeight;

  bool _isOpen;
  double _currentHeight;

  /// Whether the top sheet is open.
  bool get isOpen => _isOpen;

  /// The current height of the top sheet.
  double get currentHeight => _currentHeight;

  /// Opens the top sheet.
  void open() {
    if (_isOpen) return;
    _isOpen = true;
    notifyListeners();
  }

  /// Closes the top sheet.
  void close() {
    if (!_isOpen) return;
    _isOpen = false;
    notifyListeners();
  }

  /// Toggles the top sheet (opens if closed, closes if open).
  void toggle() {
    if (_isOpen) {
      close();
    } else {
      open();
    }
  }

  /// Sets the height of the top sheet directly.
  void setHeight(double height) {
    _currentHeight = height;
    notifyListeners();
  }
}
