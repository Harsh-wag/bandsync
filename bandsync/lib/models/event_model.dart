class Event {
  final String? id;
  final String title;
  final String type;
  final DateTime dateTime;
  final String location;
  final bool notifyBefore;

  Event({
    this.id,
    required this.title,
    required this.type,
    required this.dateTime,
    required this.location,
    this.notifyBefore = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'type': type,
      'dateTime': dateTime.toIso8601String(),
      'location': location,
      'notifyBefore': notifyBefore,
    };
  }

  factory Event.fromMap(Map<String, dynamic> map) {
    return Event(
      id: map['id'],
      title: map['title'] ?? '',
      type: map['type'] ?? '',
      dateTime: map['dateTime'] != null
          ? DateTime.parse(map['dateTime'])
          : DateTime.now(),
      location: map['location'] ?? '',
      notifyBefore: map['notifyBefore'] ?? true,
    );
  }
}
