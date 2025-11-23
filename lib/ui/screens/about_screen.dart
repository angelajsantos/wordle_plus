/// ABOUT SCREEN:
///   about screen that has
///   - creators
///   - how-to-play
///   TODO: fix ui styling

import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About'),
        centerTitle: true,
        backgroundColor: const Color(0xFF121213),
        elevation: 0,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 540),
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: const [
              Text(
                'Wordle+',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
              ),
              SizedBox(height: 8),
              Text(
                'ABOUT',
                style: TextStyle(color: Color(0xFFBDBDBD)),
              ),
              SizedBox(height: 24),
              Text(
                'How to Play',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              ),
              SizedBox(height: 8),
              Text('TODO: ADD HOW TO PLAY STUFF'),
            ],
          ),
        ),
      ),
    );
  }
}
