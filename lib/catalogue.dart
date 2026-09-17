import 'models.dart';

class Library {
  final List<LibraryItem> items;
  late final DateTime openedAt;
  String? _cachedReport;

  Library(this.items);

  void add(LibraryItem item) {
    items.add(item);
  }

  void open() {
    openedAt = DateTime.now();
  }

  Book? findByTitle(String title) {
    for (LibraryItem item in items) {
      if (item.title == title && item is Book) return item;
    }
    return null;
  }

  String countryOf(String title) {
    return findByTitle(title)?.author.country ?? "unknown";
  }

  String buildReport() {
    return _cachedReport ??= items.map((item) => item.title).join('\n');
  }

  // All books in the library
  List<Book> get books => items.whereType<Book>().toList();

  // Every title
  List<String> get get_titles =>
      items.map((item) => item.title).toList();

  // Books published after 2010
  List<Book> get booksAfter2010 =>
      items.whereType<Book>().where((book) => book.year > 2010).toList();

  // Average page count
  // We don't use reduce because reduce throws an error if there are no books.
  double get averagePages =>
      books.isEmpty ? 0 : books.fold(0, (sum, book) => sum + book.pages) / books.length;

  // Author name -> number of books
  Map<String, int> get authorBookCounts =>
      books.fold<Map<String, int>>(
        {},
            (map, book) => {
          ...map,
          book.author.name: (map[book.author.name] ?? 0) + 1,
        },
      );

  // Distinct author names
  Set<String> get get_all_authors =>
      books.map((book) => book.author.name).toSet();

  // Every genre present in the library
  Set<Genre> get get_all_genres =>
      books.map((book) => book.genre).toSet();

  // One display list using collection-for, spread, and collection-if
  late final displayList = [
    'CATALOGUE',

    for (final book in books)
      '${book.title} (${book.year})',

    ...books.map((book) => book.author.name),

    if (books.any((book) => book.pages == 0))
      '(incomplete data)',
  ];
}