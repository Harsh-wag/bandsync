import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../state/event_provider.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Consumer<EventProvider>(
      builder: (context, eventProvider, child) {
        return Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: const Text('Calendar'),
            actions: [
              IconButton(
                icon: const Icon(Icons.notifications),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Notifications enabled')),
                  );
                },
              ),
            ],
          ),
          body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF090D17), Color(0xFF111F32), Color(0xFF1A1027)],
              ),
            ),
            child: Column(
              children: [
                TableCalendar(
                  firstDay: DateTime.utc(2020, 1, 1),
                  lastDay: DateTime.utc(2030, 12, 31),
                  focusedDay: _focusedDay,
                  selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                  eventLoader: (day) => eventProvider.getEventsForDay(day),
                  calendarStyle: CalendarStyle(
                    todayDecoration: BoxDecoration(
                      color: colorScheme.primary.withValues(alpha: 0.35),
                      shape: BoxShape.circle,
                    ),
                    selectedDecoration: BoxDecoration(
                      color: colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                    markerDecoration: BoxDecoration(
                      color: colorScheme.tertiary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                    });
                  },
                  onPageChanged: (focusedDay) {
                    _focusedDay = focusedDay;
                  },
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: _buildEventList(eventProvider),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEventList(EventProvider eventProvider) {
    final events = eventProvider.getEventsForDay(_selectedDay!);
    if (events.isEmpty) {
      return const Center(child: Text('No events for this day'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: events.length,
      itemBuilder: (context, index) {
        final event = events[index];
        final colorScheme = Theme.of(context).colorScheme;
        final isPerformance = event.type == 'Performance';

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor:
                  isPerformance ? colorScheme.errorContainer : colorScheme.primaryContainer,
              child: Icon(
                isPerformance ? Icons.music_note : Icons.mic,
                color: isPerformance
                    ? colorScheme.onErrorContainer
                    : colorScheme.onPrimaryContainer,
              ),
            ),
            title: Text(event.title),
            subtitle: Text(
              '${DateFormat('h:mm a').format(event.dateTime)} - ${event.location}',
            ),
            trailing: Icon(
              event.notifyBefore ? Icons.notifications_active : Icons.notifications_off,
            ),
          ),
        );
      },
    );
  }
}
