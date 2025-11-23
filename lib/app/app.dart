/// App Root:
///   builds
///   - Material App, global theme, and route table

import 'package:flutter/material.dart';
import '../game/game_screen.dart';

class WordleApp extends StatelessWidget {
  const WordleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(useMaterial3: true),
      home: const GameScreen(),
    );
  }
}