import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/event_model.dart';

class EventService {
  final SupabaseClient _supabase = Supabase.instance.client;

  String get _userId => _supabase.auth.currentUser!.id;

  Stream<List<Event>> getEvents() {
    return _supabase
        .from('events')
        .stream(primaryKey: ['id'])
        .eq('user_id', _userId)
        .order('date_time')
        .map((data) => data.map((json) => Event.fromMap(json)).toList());
  }

  Future<void> addEvent(Event event) async {
    await _supabase.from('events').insert({
      'user_id': _userId,
      ...event.toMap(),
    });
  }

  Future<void> deleteEvent(String eventId) async {
    await _supabase.from('events').delete().eq('id', eventId);
  }

  List<Event> getEventsForDay(List<Event> events, DateTime day) {
    return events.where((event) {
      return event.dateTime.year == day.year &&
          event.dateTime.month == day.month &&
          event.dateTime.day == day.day;
    }).toList();
  }
}
