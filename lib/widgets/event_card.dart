import 'package:flutter/material.dart';

import '../models/event.dart';
import '../utils/format.dart';

class EventCard extends StatelessWidget {
  const EventCard({
    super.key,
    required this.event,
    required this.onOpen,
    required this.onFavourite,
  });

  final Event event;
  final VoidCallback onOpen;
  final VoidCallback onFavourite;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final (:taken, :free) = event.places;

    return Card.filled(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onOpen,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 18),
          child: Row(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  CircleAvatar(
                    radius: 25,
                    backgroundColor: scheme.surfaceContainerHighest,
                    child: Icon(
                      event.category.icon,
                      color: event.category.color(scheme),
                    ),
                  ),
                  if (event.isFull || free <= 5)
                    Positioned(
                      bottom: -8,
                      left: -5,
                      right: -5,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: event.isFull
                              ? scheme.errorContainer
                              : scheme.secondaryContainer,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 3),
                          child: Text(
                            event.isFull ? 'FULL' : '$free left',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: event.isFull
                                  ? scheme.onErrorContainer
                                  : scheme.onSecondaryContainer,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      formatDateTime(event.when),
                      style: theme.textTheme.bodySmall,
                    ),
                    Text(
                      event.online ? 'Online event' : event.location,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                    Text(
                      '$taken of ${event.limit} registered',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: event.favourite ? 'Remove favourite' : 'Add favourite',
                onPressed: onFavourite,
                icon: Icon(
                  event.favourite ? Icons.favorite : Icons.favorite_border,
                  color: event.favourite ? scheme.primary : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
