# Practice 7 - A Form That Validates Itself

A simple final version of the lab. The app validates each field, manages keyboard focus, offers a group dropdown and birth date picker, and shows an adaptive summary.

## Run

Use Flutter 3.35 or newer with Dart 3.9 or newer.

```sh
flutter pub get
flutter run
```

For a browser preview: `flutter run -d chrome`.

## Files

- `lib/main.dart`: form, validators, focus, date picker, checkbox, submit and reset.
- `lib/summary_card.dart`: summary with one column below 600 pixels and two columns at 600 pixels or wider, based on the card's available width.
- `test/widget_test.dart`: four tests for validation/reset, focus, adaptive layout and scrolling.
- `tablet.png`: actual Flutter-rendered summary at 1024 x 768 from a widget test.

## Checks

```sh
dart format .
flutter analyze
flutter test
```

Formatting completed, analysis reported no issues, all four tests passed, and the web build succeeded with Flutter 3.47.5.

## Before submitting

1. Run the app on an Android emulator or phone. Tick the agreement checkbox when testing submission. The button is disabled until it is ticked.
2. Check Next from Name to Email to Password to Confirm, and Done to submit. Select the group and birth date before testing a successful submission.
3. Focus Confirm password with the keyboard open, check scrolling and save a real device screenshot as `keyboard_open.png`. The automated test simulates the reduced space; it does not photograph an Android keyboard.
4. The supplied `tablet.png` shows the actual widget layout. Capture a tablet emulator screenshot too if your instructor requires emulator evidence.
5. Upload this project and both required screenshots to your GitHub repository.

Android execution was blocked in the preparation environment, so a real keyboard screenshot and Android runtime verification remain to be done. No GitHub upload has been made.

## Notes

This implements the final working version after Levels 1-5. The temporary broken examples are learning exercises and are not included in the final code. The birth date has its own validator, so there are six validators: four text inputs, group and date.

The app displays a local success message and summary; it does not send data to a server.

