import 'package:flutter/material.dart';

import '../models/category.dart';
import '../models/event.dart';
import '../widgets/empty_state.dart';
import '../widgets/event_card.dart';

class EventList extends StatefulWidget {
  const EventList({
    super.key,
    required this.events,
    required this.onOpen,
    required this.onChanged,
    required this.onBrowse,
    this.favouritesOnly = false,
  });

  final List<Event> events;
  final ValueChanged<Event> onOpen;
  final ValueChanged<Event> onChanged;
  final VoidCallback onBrowse;
  final bool favouritesOnly;

  @override
  State<EventList> createState() => _EventListState();
}

class _EventListState extends State<EventList> {
  final _search = TextEditingController();
  EventCategory? _category;
  bool _showPast = false;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _clearFilters() {
    setState(() {
      _search.clear();
      _category = null;
      _showPast = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final query = _search.text.trim().toLowerCase();
    final favouritesExist = widget.events.any((event) => event.favourite);

    // toList creates a copy: sorting never changes the shell's state.
    final visible = widget.events.where((event) {
      return (!widget.favouritesOnly || event.favourite) &&
          (_showPast || !event.isPast) &&
          (_category == null || event.category == _category) &&
          event.title.toLowerCase().contains(query);
    }).toList();
    visible.sort((a, b) {
      if (a.isPast != b.isPast) return a.isPast ? 1 : -1;
      return a.when.compareTo(b.when);
    });

    Widget card(int index) => EventCard(
      event: visible[index],
      onOpen: () => widget.onOpen(visible[index]),
      onFavourite: () => widget.onChanged(
        visible[index].copyWith(favourite: !visible[index].favourite),
      ),
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _search,
            decoration: InputDecoration(
              hintText: 'Search events',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _search.text.isEmpty
                  ? null
                  : IconButton(
                      tooltip: 'Clear search',
                      onPressed: () => setState(_search.clear),
                      icon: const Icon(Icons.close),
                    ),
              border: const OutlineInputBorder(),
            ),
            onChanged: (_) => setState(() {}),
            onTapOutside: (_) => FocusScope.of(context).unfocus(),
          ),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                ChoiceChip(
                  label: const Text('All'),
                  selected: _category == null,
                  onSelected: (_) => setState(() => _category = null),
                ),
                for (final category in EventCategory.values) ...[
                  const SizedBox(width: 8),
                  ChoiceChip(
                    avatar: Icon(category.icon, size: 18),
                    label: Text(category.label),
                    selected: _category == category,
                    onSelected: (_) => setState(() => _category = category),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              FilterChip(
                label: const Text('Show past'),
                selected: _showPast,
                onSelected: (value) => setState(() => _showPast = value),
              ),
              const SizedBox(width: 12),
              Text(
                '${visible.length} events',
                style: Theme.of(context).textTheme.labelMedium,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: widget.favouritesOnly && !favouritesExist
                ? EmptyState(
                    icon: Icons.favorite_border,
                    message: 'Your favourite events will appear here.',
                    buttonLabel: 'Browse events',
                    onPressed: widget.onBrowse,
                  )
                : visible.isEmpty
                ? EmptyState(
                    icon: Icons.search_off,
                    message: 'No events match your filters.',
                    buttonLabel: 'Clear filters',
                    onPressed: _clearFilters,
                  )
                : LayoutBuilder(
                    builder: (context, constraints) {
                      // Account for the page's 16 px padding on both sides.
                      final pageWidth = constraints.maxWidth + 32;
                      if (pageWidth < 600) {
                        return ListView.separated(
                          padding: const EdgeInsets.only(bottom: 88),
                          itemCount: visible.length,
                          itemBuilder: (_, index) => card(index),
                          separatorBuilder: (_, index) =>
                              const SizedBox(height: 10),
                        );
                      }
                      return GridView.builder(
                        padding: const EdgeInsets.only(bottom: 88),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: (constraints.maxWidth / 360).ceil(),
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 1.55,
                        ),
                        itemCount: visible.length,
                        itemBuilder: (_, index) => card(index),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
