import 'dart:async';

import 'package:flutter/material.dart';

import '../models/countdown.dart';
import '../models/event.dart';
import '../routes.dart';
import '../utils/confirm.dart';
import '../utils/format.dart';
import '../widgets/empty_state.dart';

class EventDetail extends StatefulWidget {
  const EventDetail({super.key, required this.arguments});
  final DetailArguments arguments;

  @override
  State<EventDetail> createState() => _EventDetailState();
}

class _EventDetailState extends State<EventDetail> {
  late Event _event;
  late final Timer _timer;
  DateTime _now = DateTime.now();
  bool _asking = false;

  @override
  void initState() {
    super.initState();
    _event = widget.arguments.event;
    _timer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (!mounted) return;
      setState(() => _now = DateTime.now());
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _update(Event event) {
    widget.arguments.onChanged(event);
    setState(() => _event = event);
  }

  Future<void> _edit() async {
    final edited = await Navigator.of(
      context,
    ).pushNamed<Event>(Routes.form, arguments: FormArguments(event: _event));
    if (!mounted || edited == null) return;
    _update(edited);
  }

  Future<void> _delete() async {
    final approved = await confirm(
      context,
      title: 'Delete event?',
      message: 'Delete "${_event.title}" and its registrations?',
      action: 'Delete',
    );
    if (!mounted || !approved) return;
    widget.arguments.onDelete();
    Navigator.of(context).pop();
  }

  Future<void> _register() async {
    if (_asking) return;
    final name = widget.arguments.profile.name.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Enter your name in your profile first.'),
          action: SnackBarAction(
            label: 'Profile',
            onPressed: widget.arguments.onProfile,
          ),
        ),
      );
      return;
    }
    final joined = _event.contains(name);
    _asking = true;
    final approved = await confirm(
      context,
      title: joined ? 'Cancel registration?' : 'Register for this event?',
      message: joined
          ? 'Remove $name from the registered names?'
          : 'Add $name to "${_event.title}"?',
      action: joined ? 'Cancel registration' : 'Register',
    );
    if (!mounted) return;
    _asking = false;
    if (!approved) return;
    final names = joined
        ? _event.attendees
              .where((person) => person.toLowerCase() != name.toLowerCase())
              .toList()
        : [..._event.attendees, name];
    _update(_event.copyWith(attendees: names));
  }

  String get _countdownText => switch (Countdown.forEvent(_event.when, _now)) {
    Upcoming(:final remaining) when remaining.inDays > 0 =>
      'In ${remaining.inDays} days',
    Upcoming(:final remaining) when remaining.inHours > 0 =>
      'In ${remaining.inHours} hours',
    Upcoming(:final remaining) =>
      'In ${remaining.inMinutes < 1 ? 1 : remaining.inMinutes} min',
    Started() => 'In progress',
    Ended() => 'Ended',
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final (:taken, :free) = _event.places;
    final name = widget.arguments.profile.name;
    final joined = name.isNotEmpty && _event.contains(name);
    final canRegister = !_event.isPast && !_event.isFull;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Event details'),
          actions: [
            IconButton(
              tooltip: _event.favourite ? 'Remove favourite' : 'Add favourite',
              onPressed: () =>
                  _update(_event.copyWith(favourite: !_event.favourite)),
              icon: Icon(
                _event.favourite ? Icons.favorite : Icons.favorite_border,
              ),
            ),
            PopupMenuButton<String>(
              tooltip: 'Event menu',
              onSelected: (action) {
                if (action == 'edit') _edit();
                if (action == 'delete') _delete();
              },
              itemBuilder: (_) => const [
                PopupMenuItem(value: 'edit', child: Text('Edit')),
                PopupMenuItem(value: 'delete', child: Text('Delete')),
              ],
            ),
          ],
        ),
        body: Column(
          children: [
            TabBar(
              tabs: [
                const Tab(text: 'About'),
                Tab(text: 'Registered ($taken)'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  ListView(
                    padding: const EdgeInsets.only(bottom: 24),
                    children: [
                      Stack(
                        children: [
                          Image.asset(
                            'assets/campus.png',
                            height: 210,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                          Positioned(
                            top: 12,
                            left: 12,
                            child: Chip(label: Text(_event.category.label)),
                          ),
                          Positioned(
                            top: 12,
                            right: 12,
                            child: Chip(label: Text(_countdownText)),
                          ),
                          Positioned(
                            bottom: 16,
                            left: 16,
                            child: CircleAvatar(
                              radius: 28,
                              backgroundColor: scheme.surface,
                              child: Icon(
                                _event.category.icon,
                                color: _event.category.color(scheme),
                                size: 30,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _event.title,
                              style: theme.textTheme.headlineSmall,
                            ),
                            const SizedBox(height: 20),
                            _InfoRow(
                              icon: Icons.schedule,
                              text: formatDateTime(_event.when),
                            ),
                            const SizedBox(height: 12),
                            _InfoRow(
                              icon: _event.online
                                  ? Icons.videocam_outlined
                                  : Icons.location_on_outlined,
                              text: _event.location,
                            ),
                            const SizedBox(height: 12),
                            _InfoRow(
                              icon: Icons.people_outline,
                              text: '$taken registered · $free free places',
                            ),
                            if (_event.description != null) ...[
                              const SizedBox(height: 24),
                              Text(_event.description ?? ''),
                            ],
                            if (_event.isPast) ...[
                              const SizedBox(height: 20),
                              const Text(
                                'This event has already started. Registration is closed.',
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                  _event.attendees.isEmpty
                      ? const EmptyState(
                          icon: Icons.people_outline,
                          message: 'Nobody has registered yet.',
                        )
                      : ListView(
                          padding: const EdgeInsets.all(16),
                          children: [
                            for (final person in _event.attendees)
                              ListTile(
                                title: Text(person),
                                selected:
                                    person.toLowerCase() == name.toLowerCase(),
                                selectedTileColor: scheme.primaryContainer,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                trailing:
                                    person.toLowerCase() == name.toLowerCase()
                                    ? const Chip(label: Text('You'))
                                    : null,
                              ),
                          ],
                        ),
                ],
              ),
            ),
          ],
        ),
        bottomNavigationBar: SafeArea(
          minimum: const EdgeInsets.all(16),
          child: FilledButton.icon(
            onPressed: joined || canRegister ? _register : null,
            icon: Icon(
              joined ? Icons.person_remove_outlined : Icons.person_add_outlined,
            ),
            label: Text(
              joined
                  ? 'Cancel registration'
                  : _event.isPast
                  ? 'Registration closed'
                  : _event.isFull
                  ? 'Event full'
                  : 'Register',
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
      const SizedBox(width: 12),
      Expanded(child: Text(text)),
    ],
  );
}
