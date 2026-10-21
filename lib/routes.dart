import 'package:flutter/material.dart';

import 'models/event.dart';
import 'models/profile.dart';
import 'screens/event_detail.dart';
import 'screens/event_form.dart';

class Routes {
  static const home = '/';
  static const detail = '/event';
  static const form = '/event-form';

  static Route<dynamic>? generate(RouteSettings settings) {
    final arguments = settings.arguments;
    if (settings.name == detail && arguments is DetailArguments) {
      return MaterialPageRoute<void>(
        settings: settings,
        builder: (_) => EventDetail(arguments: arguments),
      );
    }
    if (settings.name == form && arguments is FormArguments) {
      return MaterialPageRoute<Event>(
        settings: settings,
        builder: (_) => EventForm(event: arguments.event),
      );
    }
    return null;
  }
}

class DetailArguments {
  const DetailArguments({
    required this.event,
    required this.profile,
    required this.onChanged,
    required this.onDelete,
    required this.onProfile,
  });

  final Event event;
  final Profile profile;
  final ValueChanged<Event> onChanged;
  final VoidCallback onDelete;
  final VoidCallback onProfile;
}

class FormArguments {
  const FormArguments({this.event});
  final Event? event;
}
