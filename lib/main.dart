import 'package:flutter/material.dart';

import 'detail_screen.dart';
import 'edit_screen.dart';
import 'routes.dart';
import 'students.dart';
import 'students_screen.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    theme: ThemeData(colorSchemeSeed: Colors.indigo),
    initialRoute: Routes.students,
    routes: {Routes.students: (_) => const StudentsScreen()},
    onGenerateRoute: (settings) {
      if (settings.name == Routes.student) {
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => DetailScreen(student: settings.arguments as Student),
        );
      }
      if (settings.name == Routes.edit) {
        return MaterialPageRoute<String>(
          settings: settings,
          builder: (_) => EditScreen(student: settings.arguments as Student),
        );
      }
      return null;
    },
  );
}