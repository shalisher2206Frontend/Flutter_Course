# Practice 8 - A Little of Everything

A simple reading-list app using Flutter's built-in widgets. All app code is in six files under `lib`.

## Run

Use Flutter with Dart 3.9 or newer.

```sh
flutter pub get
flutter run
```

For a browser preview:

```sh
flutter run -d chrome
```

## Use

- Filter books with All, Unread and Read.
- Tick a checkbox to change a book's read status.
- Tap a book to view its details, change its status or delete it after confirmation.
- Tap + to add a book. Title and author are required, pages must be a positive whole number, and year can be empty.

## Six app files

- `lib/main.dart`: starts the app and prints the model checks.
- `lib/models/book.dart`: Book, seed books and collection functions, with no Flutter import.
- `lib/library_screen.dart`: owns books and the selected filter, updates totals and handles returned navigation results.
- `lib/widgets/book_tile.dart`: themed card with unread dot, two-line title and checkbox.
- `lib/detail_screen.dart`: details and confirmed actions returned to the list.
- `lib/add_book_screen.dart`: validated form that returns a new Book.

The library copies the seed books as well as the list, so toggling a read flag does not change the seed data. Data is kept in memory and resets when the app restarts.

## Verify

```sh
dart format .
flutter analyze
flutter test
```

Expected startup output:

```text
1220 pages, 4 unread
X — Y, 10 pp.
```

Formatting completed, analysis reported no issues, all five tests passed, and the browser build succeeded with Flutter 3.47.5.

Five tests cover the model, filters, navigation and delete confirmation, form validation, optional year, cancellation, portrait/landscape layout and reduced space for the keyboard.

## Screenshots and submission

- `screenshot_list.png`: Unread filter with the long title wrapped and shortened with an ellipsis.
- `screenshot_form.png`: the empty form showing its three validation errors.

Both images were captured from the actual Flutter widgets at 390 x 844 using Flutter's test renderer.

Upload this project, including both screenshots, to your GitHub repository. No repository upload has been made. The intentionally broken learning examples are not part of the final app.

