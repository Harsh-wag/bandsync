import 'package:flutter/material.dart';
import '../models/event_model.dart';

class EventProvider extends ChangeNotifier {
  final Map<DateTime, List<Event>> _events = {};

  Map<DateTime, List<Event>> get events => _events;

  List<Event> getEventsForDay(DateTime day) {
    final key = DateTime(day.year, day.month, day.day);
    return _events[key] ?? [];
  }

  void addEvent(Event event) {
    final key = DateTime(event.dateTime.year, event.dateTime.month, event.dateTime.day);
    if (_events[key] == null) {
      _events[key] = [];
    }
    _events[key]!.add(event);
    notifyListeners();
  }

  void deleteEvent(DateTime day, Event event) {
    final key = DateTime(day.year, day.month, day.day);
    _events[key]?.remove(event);
    notifyListeners();
  }
}
