import 'package:flutter/material.dart';

class OverlapClassProvider with ChangeNotifier {
  List<Map<String, dynamic>> _overlappingEvents = [];

  List<Map<String, dynamic>> get overlappingEvents => _overlappingEvents;

  void setOverlappingEvents(List<Map<String, dynamic>> events) {
    _overlappingEvents = events;
    notifyListeners();
  }
}
