import '../models/category.dart';
import '../models/event.dart';

List<Event> seedEvents() {
  final today = DateTime.now();
  DateTime at(int day, int hour, [int minute = 0]) =>
      DateTime(today.year, today.month, today.day + day, hour, minute);

  return [
    // Exactly 60 characters: check the two-line card title on a small phone.
    Event(
      id: 'flutter',
      title: 'Build your first Flutter app with friends at our campus club!',
      category: EventCategory.tech,
      when: at(1, 16),
      location: 'Innovation Lab',
      limit: 25,
      attendees: ['Amina', 'Dana'],
      description: 'Bring your laptop. We will build a tiny app together.',
      favourite: true,
    ),
    // Full event: registration is disabled for a new participant.
    Event(
      id: 'pottery',
      title: 'Pottery for beginners',
      category: EventCategory.arts,
      when: at(1, 17, 30),
      location: 'Art Studio 2',
      limit: 3,
      attendees: ['Ali', 'Mira', 'Sam'],
      description: 'Make a small cup. Materials are provided.',
    ),
    // Past event: hidden until Show past is selected.
    Event(
      id: 'welcome',
      title: 'Welcome picnic',
      category: EventCategory.social,
      when: at(-2, 12),
      location: 'Campus Lawn',
      limit: 40,
      attendees: ['Dana', 'Ali'],
      description: 'Meet students from other groups over a picnic.',
    ),
    // Online event: the location is a link.
    Event(
      id: 'design',
      title: 'Design a better study space',
      category: EventCategory.arts,
      when: at(2, 18),
      location: 'https://meet.example.com/design',
      limit: 50,
      online: true,
      description: 'An online workshop about organising your desk.',
      favourite: true,
    ),
    // No optional description.
    Event(
      id: 'chess',
      title: 'Chess at lunch',
      category: EventCategory.social,
      when: at(2, 12),
      location: 'Student Lounge',
      limit: 12,
      attendees: ['Amina'],
    ),
    Event(
      id: 'basketball',
      title: 'Friendly basketball',
      category: EventCategory.sport,
      when: at(3, 17),
      location: 'Sports Hall',
      limit: 8,
      attendees: ['Ali', 'Sam', 'Dana', 'Mira'],
      description: 'All levels welcome. Wear comfortable shoes.',
    ),
    Event(
      id: 'math',
      title: 'Math revision circle',
      category: EventCategory.study,
      when: at(3, 15, 15),
      location: 'Library Room 4',
      limit: 15,
      attendees: ['Amina', 'Mira'],
      description: 'Bring two questions you would like to discuss.',
    ),
    Event(
      id: 'photo',
      title: 'Campus photo walk',
      category: EventCategory.arts,
      when: at(4, 16, 30),
      location: 'Main Entrance',
      limit: 20,
      description: 'A phone camera is all you need.',
    ),
    Event(
      id: 'python',
      title: 'Python problem solving',
      category: EventCategory.tech,
      when: at(4, 14),
      location: 'Computer Room 3',
      limit: 18,
      attendees: ['Sam'],
      description: 'Solve beginner puzzles in pairs.',
    ),
    Event(
      id: 'yoga',
      title: 'Morning stretch',
      category: EventCategory.sport,
      when: at(5, 8, 30),
      location: 'Wellbeing Room',
      limit: 10,
      attendees: ['Dana', 'Mira', 'Ali', 'Sam', 'Amina', 'Noor'],
      description: 'A gentle session before classes. Bring a mat.',
    ),
    Event(
      id: 'english',
      title: 'English conversation hour',
      category: EventCategory.study,
      when: at(5, 13),
      location: 'https://meet.example.com/english',
      limit: 30,
      online: true,
      description: 'Practise speaking through simple group activities.',
    ),
    Event(
      id: 'games',
      title: 'Board game evening',
      category: EventCategory.social,
      when: at(6, 18),
      location: 'Student Lounge',
      limit: 24,
      attendees: ['Noor', 'Sam'],
      description: 'Learn a new game and meet your next teammate.',
      favourite: true,
    ),
  ];
}
