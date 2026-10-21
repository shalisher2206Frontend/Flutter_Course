import 'package:flutter/material.dart';

import '../data/seed.dart';
import '../models/event.dart';
import '../models/profile.dart';
import '../routes.dart';
import '../utils/confirm.dart';
import 'event_list.dart';
import 'profile_tab.dart';

class AppShell extends StatefulWidget {
  const AppShell({
    super.key,
    required this.themeMode,
    required this.onThemeChanged,
  });

  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeChanged;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  List<Event> _events = seedEvents();
  Profile _profile = const Profile.empty();
  int _tab = 0;
  int _resetCount = 0;

  void _replaceEvent(Event updated) {
    setState(() {
      _events = [
        for (final event in _events)
          if (event.id == updated.id) updated else event,
      ];
    });
  }

  // Both tabs and pushed pages use this one shell callback.
  void _switchTab(int index) {
    Navigator.of(context).popUntil((route) => route.isFirst);
    setState(() => _tab = index);
  }

  void _openEvent(Event event) {
    Navigator.of(context).pushNamed<void>(
      Routes.detail,
      arguments: DetailArguments(
        event: event,
        profile: _profile,
        onChanged: _replaceEvent,
        onDelete: () => setState(() {
          _events = _events.where((item) => item.id != event.id).toList();
        }),
        onProfile: () => _switchTab(2),
      ),
    );
  }

  Future<void> _addEvent() async {
    final saved = await Navigator.of(context).pushNamed<Event>(
      Routes.form,
      arguments: const FormArguments(),
    );
    if (!mounted || saved == null) return;
    setState(() => _events = [..._events, saved]);
  }

  Future<void> _reset() async {
    final approved = await confirm(
      context,
      title: 'Reset data?',
      message: 'Restore the 12 example events and clear your profile?',
      action: 'Reset',
    );
    if (!mounted || !approved) return;
    setState(() {
      _events = seedEvents();
      _profile = const Profile.empty();
      _resetCount += 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    const titles = ['Campus events', 'Your favourites', 'Your profile'];
    return Scaffold(
      appBar: AppBar(title: Text(titles[_tab])),
      drawer: Drawer(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text('Campus Events'),
                subtitle: Text('Find something worth joining'),
              ),
              const SizedBox(height: 24),
              ListTile(
                title: const Text('About'),
                onTap: () {
                  Navigator.of(context).pop();
                  showDialog<void>(
                    context: context,
                    builder: (dialogContext) => AlertDialog(
                      title: const Text('Campus Events'),
                      content: const Text(
                        'Browse campus events, save favourites, and join in. '
                        'Data is kept in memory and resets when the app restarts.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(dialogContext).pop(),
                          child: const Text('Close'),
                        ),
                      ],
                    ),
                  );
                },
              ),
              ListTile(
                title: const Text('Reset data'),
                onTap: () {
                  Navigator.of(context).pop();
                  _reset();
                },
              ),
            ],
          ),
        ),
      ),
      body: IndexedStack(
        index: _tab,
        children: [
          EventList(
            events: _events,
            onOpen: _openEvent,
            onChanged: _replaceEvent,
            onBrowse: () => _switchTab(0),
          ),
          EventList(
            events: _events,
            favouritesOnly: true,
            onOpen: _openEvent,
            onChanged: _replaceEvent,
            onBrowse: () => _switchTab(0),
          ),
          ProfileTab(
            key: ValueKey(_resetCount),
            profile: _profile,
            events: _events,
            themeMode: widget.themeMode,
            onChanged: (profile) => setState(() => _profile = profile),
            onThemeChanged: widget.onThemeChanged,
          ),
        ],
      ),
      floatingActionButton: _tab == 2
          ? null
          : FloatingActionButton.extended(
              onPressed: _addEvent,
              icon: const Icon(Icons.add),
              label: const Text('New event'),
            ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: _switchTab,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.event_outlined),
            selectedIcon: Icon(Icons.event),
            label: 'Events',
          ),
          NavigationDestination(
            icon: Icon(Icons.favorite_border),
            selectedIcon: Icon(Icons.favorite),
            label: 'Favourites',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
