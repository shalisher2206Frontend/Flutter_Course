class Validators {
  static String? requiredText(String? value) =>
      (value ?? '').trim().isEmpty ? 'This field is required.' : null;

  static String? title(String? value) {
    final length = (value ?? '').trim().length;
    return length < 3 || length > 60 ? 'Use 3 to 60 characters.' : null;
  }

  static String? location(String? value, {required bool online}) {
    final text = (value ?? '').trim();
    if (text.isEmpty) {
      return online ? 'Enter a meeting link.' : 'Enter a location.';
    }
    if (online && !text.contains('://')) {
      return 'Include a scheme such as https://.';
    }
    return null;
  }

  static String? limit(String? value, {required int taken}) {
    final number = int.tryParse((value ?? '').trim());
    if (number == null || number < 1 || number > 500) {
      return 'Enter a whole number from 1 to 500.';
    }
    if (number < taken) return 'At least $taken people are already registered.';
    return null;
  }

  static String? date(
    String? value, {
    required DateTime when,
    required bool isNew,
  }) {
    if ((value ?? '').isEmpty) return 'Choose a date.';
    if (isNew && !when.isAfter(DateTime.now())) return 'Choose a future time.';
    return null;
  }

  static String? group(String? value) =>
      RegExp(r'^[A-Za-z]{1,4}-\d{2,4}$').hasMatch((value ?? '').trim())
      ? null
      : 'Use a group such as CS-101.';
}
