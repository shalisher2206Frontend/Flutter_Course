sealed class Countdown {
  const Countdown();

  // Events last one hour. Registration closes when the start time passes.
  factory Countdown.forEvent(DateTime start, DateTime now) {
    final difference = start.difference(now);
    if (difference > Duration.zero) return Upcoming(difference);
    final elapsed = now.difference(start);
    if (elapsed < const Duration(hours: 1)) return Started(elapsed);
    return const Ended();
  }
}

class Upcoming extends Countdown {
  const Upcoming(this.remaining);
  final Duration remaining;
}

class Started extends Countdown {
  const Started(this.elapsed);
  final Duration elapsed;
}

class Ended extends Countdown {
  const Ended();
}
