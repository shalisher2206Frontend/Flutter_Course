import 'package:flutter/material.dart';

enum EventCategory {
  tech('Technology', Icons.computer_outlined),
  arts('Arts', Icons.palette_outlined),
  sport('Sport', Icons.sports_basketball_outlined),
  study('Study', Icons.menu_book_outlined),
  social('Social', Icons.groups_outlined);

  const EventCategory(this.label, this.icon);

  final String label;
  final IconData icon;

  // An exhaustive switch makes the compiler catch a missing new category.
  Color color(ColorScheme scheme) => switch (this) {
    EventCategory.tech => scheme.primary,
    EventCategory.arts => scheme.tertiary,
    EventCategory.sport => scheme.secondary,
    EventCategory.study => scheme.onSurfaceVariant,
    EventCategory.social => scheme.onPrimaryContainer,
  };
}
