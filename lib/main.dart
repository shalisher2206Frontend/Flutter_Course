import 'models.dart';
import 'shelf_state.dart';
import 'data.dart';

void main() {
  final books = rawBooks.map(Book.fromJson).toList();

  print('Every title:');
  print(books.map((book) => book.title).toList());

  print('Books after 2010:');
  print(
    books
        .where((book) => book.year > 2010)
        .map((book) => book.title)
        .toList(),
  );

  final stats = statsOf(books);

  print('Stats:');
  print(stats);
  print('Count: ${stats.count}');
  print('Average pages: ${stats.avgPages}');

  print(describe(Empty()));
  print(describe(Ready(books)));
  print(describe(Broken('Could not load the shelf')));
}