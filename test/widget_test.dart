import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reading_list/main.dart';
import 'package:reading_list/detail_screen.dart';
import 'package:reading_list/models/book.dart';

Finder field(String label) => find.widgetWithText(TextFormField, label);
Finder chip(String label) => find.widgetWithText(ChoiceChip, label);

Future<void> tap(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

void main() {
  test('Plain Dart model, optional values, collections and author order', () {
    expect(totalPages(seed), 1220);
    expect(unread(seed).length, 4);
    final book = Book.fromMap({'title': 'X', 'author': 'Y', 'pages': 10});
    expect(book.year, isNull);
    expect(book.read, isFalse);
    expect(book.toString(), 'X — Y, 10 pp.');
    expect(
      seed[1].toString(),
      'Null Safety for Humans — B. Seitkali, 196 pp. (2022)',
    );
    expect(authors([seed[1], seed[0], seed[1]]), [
      'B. Seitkali',
      'A. Nurmagambetova',
    ]);
    expect(
      Book.fromMap({
        'title': 'Z',
        'author': 'Y',
        'pages': 1,
        'year': 2000,
        'read': true,
      }).read,
      isTrue,
    );
  });

  testWidgets('Filters, checkbox, header and seed isolation react correctly', (
    tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    await tap(tester, chip('Unread'));
    expect(find.text('Reading list (4)'), findsOneWidget);
    await tap(tester, find.byType(Checkbox).first);
    expect(find.text('Reading list (3)'), findsOneWidget);
    expect(seed[1].read, isFalse);
    await tap(tester, chip('Read'));
    expect(find.text('Reading list (2)'), findsOneWidget);
    await tap(tester, chip('All'));
    expect(find.text('Reading list (5)'), findsOneWidget);
    expect(
      tester
          .widgetList<Checkbox>(find.byType(Checkbox))
          .where((c) => c.value == true)
          .length,
      2,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'Detail returns actions, back and cancelled delete leave the list unchanged',
    (tester) async {
      await tester.pumpWidget(const MyApp());
      await tap(tester, find.text('Null Safety for Humans'));
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.text('Reading list (5)'), findsOneWidget);
      await tap(tester, find.text('Null Safety for Humans'));
      await tap(tester, find.text('Delete'));
      await tap(tester, find.text('Cancel'));
      expect(find.byType(DetailScreen), findsOneWidget);
      await tap(tester, find.text('Mark as read'));
      await tap(tester, chip('Read'));
      expect(find.text('Reading list (2)'), findsOneWidget);
      await tap(tester, find.text('Null Safety for Humans'));
      await tap(tester, find.text('Delete'));
      await tap(tester, find.widgetWithText(TextButton, 'Delete').last);
      expect(find.text('Reading list (1)'), findsOneWidget);
      await tap(tester, chip('All'));
      expect(find.text('Reading list (4)'), findsOneWidget);
      expect(find.text('Null Safety for Humans'), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'Add validates numbers, permits an empty year and cancels safely',
    (tester) async {
      await tester.pumpWidget(const MyApp());
      await tap(tester, find.byType(FloatingActionButton));
      await tap(tester, find.text('Save'));
      expect(find.text('At least 2 characters'), findsOneWidget);
      expect(find.text('Enter an author'), findsOneWidget);
      expect(find.text('A whole number above 0'), findsOneWidget);
      await tester.enterText(field('Title'), '  New Book  ');
      await tester.enterText(field('Author'), '  Writer  ');
      for (final invalidPages in ['abc', '0', '-2', '1.5']) {
        await tester.enterText(field('Pages'), invalidPages);
        await tester.pumpAndSettle();
        expect(find.text('A whole number above 0'), findsOneWidget);
      }
      await tester.enterText(field('Pages'), '100');
      for (final year in ['1449', '${DateTime.now().year + 1}', 'abc']) {
        await tester.enterText(field('Year (optional)'), year);
        await tester.pumpAndSettle();
        expect(
          find.text('Year from 1450 to ${DateTime.now().year}'),
          findsOneWidget,
        );
      }
      await tester.enterText(field('Year (optional)'), '');
      await tap(tester, find.text('Save'));
      expect(find.text('Reading list (6)'), findsOneWidget);
      await tester.scrollUntilVisible(find.text('New Book'), 150);
      await tap(tester, find.text('New Book'));
      expect(find.text('Year unknown'), findsOneWidget);
      expect(find.text('Author: Writer'), findsOneWidget);
      await tester.pageBack();
      await tester.pumpAndSettle();
      await tap(tester, find.byType(FloatingActionButton));
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.text('Reading list (6)'), findsOneWidget);
      expect(find.text('1320'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'Long titles and form survive portrait, landscape and keyboard space',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      for (final size in [const Size(320, 640), const Size(844, 390)]) {
        tester.view.physicalSize = size;
        await tester.pumpWidget(const MyApp());
        await tester.pumpAndSettle();
        await tap(tester, chip('Unread'));
        await tester.scrollUntilVisible(find.text(seed.last.title), 100);
        final tileTitle = tester.widget<Text>(find.text(seed.last.title));
        expect(tileTitle.maxLines, 2);
        expect(tileTitle.overflow, TextOverflow.ellipsis);
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox());
      }
      tester.view.physicalSize = const Size(390, 844);
      tester.view.viewInsets = const FakeViewPadding(bottom: 300);
      await tester.pumpWidget(const MyApp());
      await tap(tester, find.byType(FloatingActionButton));
      await tap(tester, field('Year (optional)'));
      await tester.ensureVisible(find.text('Save'));
      await tester.pumpAndSettle();
      expect(find.text('Save').hitTestable(), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
