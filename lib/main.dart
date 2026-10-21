import 'package:flutter/material.dart';

import 'routes.dart';
import 'screens/app_shell.dart';

void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.system;

  @override
  Widget build(BuildContext context) {
    final seed = ThemeData().colorScheme.primary;
    return MaterialApp(
      title: 'Campus Events',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: seed),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: seed,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      themeMode: _themeMode,
      initialRoute: Routes.home,
      routes: {
        Routes.home: (_) => AppShell(
          themeMode: _themeMode,
          onThemeChanged: (mode) => setState(() => _themeMode = mode),
        ),
      },
      onGenerateRoute: Routes.generate,
      onUnknownRoute: (_) => MaterialPageRoute<void>(
        builder: (_) => Scaffold(
          appBar: AppBar(title: const Text('Not found')),
          body: const Center(child: Text('This page does not exist.')),
        ),
      ),
    );
  }
}
