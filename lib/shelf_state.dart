import 'models.dart';

sealed class ShelfState {}

class Empty extends ShelfState {}

class Ready extends ShelfState {
  final List<Book> books;

  Ready(this.books);
}

class Broken extends ShelfState {
  final String message;

  Broken(this.message);
}

String describe(ShelfState state) => switch (state) {
  Empty() => 'The shelf is empty',
  Ready(:final books) => 'The shelf is ready with ${books.length} books',
  Broken(:final message) => 'The shelf is broken: $message',
};

({int count, double avgPages}) statsOf(List<Book> books) {
  final totalPages = books.fold<int>(
    0,
        (sum, book) => sum + (book.pages ?? 0),
  );

  final count = books.length;
  final avgPages = count == 0 ? 0.0 : totalPages / count;

  return (
  count: count,
  avgPages: avgPages,
  );
}