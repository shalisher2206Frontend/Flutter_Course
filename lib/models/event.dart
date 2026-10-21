import 'category.dart';

class Event {
  // Copy the input list so neither the caller nor a widget can mutate it.
  factory Event({
    required String id,
    required String title,
    required EventCategory category,
    required DateTime when,
    required String location,
    required int limit,
    List<String> attendees = const [],
    bool online = false,
    String? description,
    bool favourite = false,
  }) => Event._(
    id: id,
    title: title,
    category: category,
    when: when,
    location: location,
    limit: limit,
    attendees: List<String>.unmodifiable(attendees),
    online: online,
    description: description,
    favourite: favourite,
  );

  // Private const construction keeps the public factory's list protection.
  const Event._({
    required this.id,
    required this.title,
    required this.category,
    required this.when,
    required this.location,
    required this.limit,
    required this.attendees,
    required this.online,
    required this.description,
    required this.favourite,
  });

  factory Event.empty() {
    final now = DateTime.now();
    return Event(
      id: now.microsecondsSinceEpoch.toString(),
      title: '',
      category: EventCategory.tech,
      when: DateTime(now.year, now.month, now.day + 1, 10),
      location: '',
      limit: 30,
    );
  }

  final String id;
  final String title;
  final EventCategory category;
  final DateTime when;
  final String location;
  final int limit;
  final List<String> attendees;
  final bool online;
  final String? description;
  final bool favourite;

  int get count => attendees.length;
  int get freePlaces => limit - count;
  bool get isFull => count >= limit;
  bool get isPast => when.isBefore(DateTime.now());
  ({int taken, int free}) get places => (taken: count, free: freePlaces);

  bool contains(String name) => attendees.any(
    (person) => person.toLowerCase() == name.trim().toLowerCase(),
  );

  Event copyWith({
    String? id,
    String? title,
    EventCategory? category,
    DateTime? when,
    String? location,
    int? limit,
    List<String>? attendees,
    bool? online,
    String? description,
    bool clearDescription = false,
    bool? favourite,
  }) => Event(
    id: id ?? this.id,
    title: title ?? this.title,
    category: category ?? this.category,
    when: when ?? this.when,
    location: location ?? this.location,
    limit: limit ?? this.limit,
    attendees: attendees ?? this.attendees,
    online: online ?? this.online,
    description: clearDescription ? null : description ?? this.description,
    favourite: favourite ?? this.favourite,
  );
}
