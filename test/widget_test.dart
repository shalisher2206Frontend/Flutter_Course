import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:signup_form/main.dart';
import 'package:signup_form/summary_card.dart';

Finder field(String label) => find.widgetWithText(TextFormField, label);

Future<void> tapVisible(WidgetTester tester, Finder target) async {
  await tester.ensureVisible(target);
  await tester.tap(target);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('Validation, date cancellation, submission and start over', (
    tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    expect(
      tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
      isNull,
    );
    expect(find.text('Name is too short'), findsNothing);
    await tapVisible(tester, find.byType(CheckboxListTile));
    await tapVisible(tester, find.byType(FilledButton));
    for (final message in [
      'Name is too short',
      'Email looks wrong',
      'Password is too short',
      'Confirm your password',
      'Choose a group',
      'Choose a birth date',
    ]) {
      expect(find.text(message), findsOneWidget);
    }
    await tester.enterText(field('Name'), '  Alex  ');
    await tester.enterText(field('Email'), 'alex@kbtu.kz');
    await tester.enterText(field('Password'), 'password123');
    await tester.enterText(field('Confirm password'), 'different');
    await tester.pumpAndSettle();
    expect(find.text('Passwords do not match'), findsOneWidget);
    expect(find.text('Name is too short'), findsNothing);
    await tester.enterText(field('Confirm password'), 'password123');
    await tapVisible(tester, find.byType(DropdownButtonFormField<String>));
    await tester.tap(find.text('IT-2301').last);
    await tester.pumpAndSettle();
    await tapVisible(tester, field('Date of birth'));
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    final selectedDate = tester
        .widget<TextFormField>(field('Date of birth'))
        .controller
        ?.text;
    expect(selectedDate, '01.01.2005');
    await tapVisible(tester, field('Date of birth'));
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(
      tester.widget<TextFormField>(field('Date of birth')).controller?.text,
      selectedDate,
    );
    await tapVisible(tester, find.byType(FilledButton));
    expect(find.byType(SummaryCard), findsOneWidget);
    expect(find.text('Alex'), findsOneWidget);
    await tapVisible(tester, find.text('Start over'));
    expect(find.byType(SummaryCard), findsNothing);
    expect(
      tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
      isNull,
    );
    expect(find.text('0 of 8'), findsOneWidget);
    expect(find.text('Name is too short'), findsNothing);
    for (final textField in tester.widgetList<TextFormField>(
      find.byType(TextFormField),
    )) {
      expect(textField.controller?.text, isEmpty);
    }
    expect(
      tester.widget<CheckboxListTile>(find.byType(CheckboxListTile)).value,
      isFalse,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('Keyboard actions move focus and submit the same form', (
    tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    await tapVisible(tester, field('Name'));
    await tester.enterText(field('Name'), 'Alex');
    await tester.testTextInput.receiveAction(TextInputAction.next);
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<EditableText>(
            find.descendant(
              of: field('Email'),
              matching: find.byType(EditableText),
            ),
          )
          .focusNode
          .hasFocus,
      isTrue,
    );
    await tester.enterText(field('Email'), 'alex@kbtu.kz');
    await tester.testTextInput.receiveAction(TextInputAction.next);
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<EditableText>(
            find.descendant(
              of: field('Password'),
              matching: find.byType(EditableText),
            ),
          )
          .focusNode
          .hasFocus,
      isTrue,
    );
    await tester.enterText(field('Password'), 'password123');
    await tester.testTextInput.receiveAction(TextInputAction.next);
    await tester.pumpAndSettle();
    await tester.enterText(field('Confirm password'), 'password123');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    expect(find.byType(SummaryCard), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Summary changes columns at its own 600 pixel constraint', (
    tester,
  ) async {
    for (final width in [599.0, 600.0]) {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Align(
              alignment: Alignment.topLeft,
              child: SizedBox(
                width: width + 8,
                child: const SummaryCard(
                  name: 'Alex',
                  email: 'alex@kbtu.kz',
                  group: 'IT-2301',
                  birthDate: '01.01.2005',
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        find.byType(GridView),
        width < 600 ? findsNothing : findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('Form scrolls when the keyboard reduces the available height', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    tester.view.viewInsets = const FakeViewPadding(bottom: 300);
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const MyApp());
    await tapVisible(tester, field('Confirm password'));
    await tester.ensureVisible(find.byType(FilledButton));
    await tester.pumpAndSettle();
    expect(find.byType(FilledButton).hitTestable(), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
