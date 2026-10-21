# Understanding Campus Events

This guide helps you read, change, and explain the app. The lab assesses your live defence, so practise changing the code yourself.

## The whole app in five steps

1. `main.dart` starts the app and owns the theme.
2. `app_shell.dart` owns the event list and profile.
3. The list and profile tabs receive that data through their constructors.
4. A detail page reports changes through callbacks to the shell.
5. A form returns a new Event when saved. Going back returns null.

There is one Navigator. Opening details or the form covers the bottom tabs. Switching tabs is handled by the shell.

## File map

| File inside lib | What to learn here |
| --- | --- |
| `main.dart` | MaterialApp, themes, top-level theme state |
| `routes.dart` | All route names, typed arguments, route creation |
| `models/event.dart` | Immutable event, copyWith, derived getters, record |
| `models/profile.dart` | Immutable name and group |
| `models/category.dart` | Enhanced enum, label, icon, exhaustive colour switch |
| `models/countdown.dart` | Sealed countdown types |
| `data/seed.dart` | Twelve original example events |
| `screens/app_shell.dart` | Shared state, three tabs, drawer, callbacks |
| `screens/event_list.dart` | Search, filters, copied sorting, phone list, grid |
| `screens/event_detail.dart` | Registration, countdown timer, details tabs, edit/delete |
| `screens/event_form.dart` | Controllers, focus, pickers, Save, PopScope |
| `screens/profile_tab.dart` | Saving fields on submit, membership count, theme chips |
| `widgets/event_card.dart` | Reusable card, Stack badge, two-line title |
| `widgets/empty_state.dart` | Shared empty-state widget |
| `utils/format.dart` | Date and time formatting without packages |
| `utils/validators.dart` | Short validation functions |
| `utils/confirm.dart` | A reusable confirmation dialog returning bool |

## The parts worth explaining

### Changing an event

Fields are final. Instead of assigning a new value to a field, call `copyWith`. The shell replaces the matching event by its id and calls `setState`. The constructor copies attendees into an unmodifiable list so a widget cannot add a name behind the shell's back. The private const constructor supports immutable construction; callers use the safe public factory.

### Displaying counts

The attendee list is the source of truth. `count`, `freePlaces`, `isFull`, and the `places` record are getters, so there is no separate counter to keep in sync. The card and detail page destructure the record with `final (:taken, :free) = event.places`.

### Saving the form

Save calls `validate()` once. Each field has its own validator. The button becomes disabled, shows a spinner, waits one second, checks `mounted`, and returns an Event with `Navigator.pop`. The caller checks both `mounted` and the returned value before changing shared state.

### Going back

The form stores its opening values as a record. `_dirty` compares that record with the current values. `PopScope` allows a clean form to close immediately and asks before discarding a dirty form. Save updates the accepted values and waits for the next frame before popping, so it does not show a discard dialog.

### Keeping the countdown safe

The timer starts in `initState` and stops in `dispose`. It refreshes `_now` once per minute. An exhaustive switch displays Upcoming, Started, or Ended. An event is in progress for one hour after its start.

## Form rules

- Title: 3 to 60 characters after trimming; a visible 60-character counter.
- Category: required; at least five enum values.
- Location: required. With Online on, its label changes to Meeting link and the value must contain `://`.
- Maximum people: whole number from 1 to 500; cannot go below the existing attendee count.
- Date and time: required; combined into one DateTime. A new event must be in the future. New forms start with tomorrow at 10:00, and cancelling a picker keeps the existing value.
- Description: optional; saving an empty description stores null.
- Profile name: required when submitted or used to register.
- Profile group: one to four letters, a hyphen, and two to four digits, for example `CS-101`.

## Requirement map

Use the original lab for the exact wording. This table points to each implementation.

| Requirements | Where to look |
| --- | --- |
| R1 R3 R4 R5 | Event and Profile models; record use in card and detail |
| R2 | EventCategory.color |
| R6 | Nullable description and collection if in detail; no null assertions |
| R7 | where and copied sort in list; map in form; fold in profile; any in model; collection for/if in shell and widgets |
| R8 | utils/format.dart |
| R9 R13 | Countdown model and detail timer lifecycle |
| R10 R12 R28 | Shell data, callbacks, single Navigator, small setState callbacks |
| R11 R22 | MyApp theme state and profile ChoiceChips |
| R14 R17 R27 | Mounted checks after awaits; delayed saving; awaiting typed form results |
| R15 R16 | Detail confirmation, profile snackbar, disabled full action, cancellation |
| R18 R19 | EventCard, Stack avatar, Positioned badge |
| R20 R21 | EventList Column and Expanded, filters, LayoutBuilder, list/grid |
| R23 | Shared EmptyState and shell New event FAB |
| R24 R29 | Asset header and detail DefaultTabController with live count |
| R25 R26 | Routes constants, route generation, typed arguments and Event result |
| R30 R33 R34 R35 R36 R37 | EventForm and Validators |
| R31 R32 | Automatic back arrows, event menu, drawer dialogs |
| R38 | ProfileTab controllers, submission, RegExp, computed count |
| R39 | pubspec, analysis options, formatting, analyzer |
| R40 | Local Git build history |
| R41 | README decisions and three actual screenshots |

The five required data cases are marked with comments in `data/seed.dart`. The first title is exactly 60 characters, Pottery is full, Welcome picnic is past, Design is online, and Chess has no description.

## Practise all 16 defence tasks

| Task | First place to change |
| --- | --- |
| 1 Add a sixth category | Add a value to EventCategory, then complete the colour switch; chips and dropdown iterate over values |
| 2 Sort by title with past last | Keep the past comparison in EventList, replace the date comparison with title.compareTo |
| 3 Search location too | Extend the final contains condition in EventList with a case-insensitive location match |
| 4 Add an online-only filter | Add local bool state, a FilterChip, and one condition in where |
| 5 Favourite destination badge | Count favourites from _events in AppShell and wrap the destination icon with Badge |
| 6 Breakpoint 720 and at most three columns | Change pageWidth comparison and clamp the calculated crossAxisCount |
| 7 Confirm cancellation | Already included; explain the joined branch in _register and the shared dialog |
| 8 Show Started N minutes ago for first hour | The model already returns Started for that hour; change its rendering to use elapsed.inMinutes |
| 9 Duplicate event | Add an EventDetail menu item, create a copy with a fresh id and empty attendees, and open the form as a new event; enforce the 60-character title limit after adding the suffix |
| 10 Online limit at most 100 | Pass online into Validators.limit and add that validation condition |
| 11 Drawer statistics | Iterate EventCategory.values and count matching _events; show one line per category in a dialog |
| 12 Clear profile | Add an AppShell callback that confirms, replaces Profile with Profile.empty, and increments _resetCount so controllers reset |
| 13 Clear all search filters | Already included in _clearFilters; explain the three assignments |
| 14 Move past filter into AppBar | Move the filter bool to shell state, pass it into EventList, and toggle it from an AppBar IconButton |
| 15 Description on card | Add a collection if inside the card's text column with maxLines 2; allow enough grid cell height |
| 16 You first and bold | Make a copied display list with the current name first, and style that person's title with FontWeight.bold |

For Duplicate, editing a copy as an existing event is not enough: the form must treat it as new so future-date validation and insertion both apply. A small optional draft parameter is one way to distinguish prefilled new data from an edit.

## Before your defence

- Choose names, places, and event descriptions you can explain and make them your own.
- Run the analyzer and formatter commands in README.
- Keep the `.git` folder when copying the project.
- Rehearse the random changes offline without AI.
- Explain why state belongs in the shell, how the form avoids accidental edits, and why the timer is cancelled.

There are no test files or testing dependencies in the submitted app. Temporary browser checks used while building are not part of this project. Android gesture and physical keyboard behaviour should also be tried on your emulator or phone before the defence.
