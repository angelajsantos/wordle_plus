/// App Root:
///   builds
///   - Material App, global theme, and route table

import 'package:flutter/material.dart';
import '../ui/screens/about_screen.dart';
import '../ui/screens/game_screen.dart';
import '../ui/screens/home_screen.dart';
import '../ui/screens/modes_screen.dart';

class WordleApp extends StatelessWidget {
  const WordleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wordle+',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF121213),
        useMaterial3: true,
        colorScheme: const ColorScheme.dark(
          primary: Colors.white,
          secondary: Colors.white70,
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (_) => const HomeScreen(),
        '/modes': (_) => const ModesScreen(),
        '/about': (_) => const AboutScreen(),
        // later: '/play/:mode' or a named route to GameScreen
      },
    );
  }
}