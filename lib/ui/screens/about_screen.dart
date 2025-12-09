/// ABOUT SCREEN:
///   about screen that has
///   - creators
///   - how-to-play
///   TODO: fix ui styling

import 'package:flutter/material.dart';
import '../theme/retro_theme.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RetroTheme.bg,
      appBar: AppBar(
        backgroundColor: RetroTheme.bg,
        title: const Text('ABOUT', style: RetroTheme.title),
        centerTitle: true,
        elevation: 0,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 540),
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: const [
              Text('Wordle+', style: RetroTheme.logo),
              SizedBox(height: 8),
              Text(
                'WORDLE CLASSIC', style: RetroTheme.section),
              SizedBox(height: 24),
              Text('How to Play', style: RetroTheme.section),
              SizedBox(height: 8),
              Text(
                '- Guess the word in a limited number of tries.\n'
                    '- Each guess must be a valid word.\n'
                    '- Tiles change color to show how close your guess was.\n'
                    '  • Green: correct letter, correct spot\n'
                    '  • Yellow: letter is in the word, wrong spot\n'
                    '  • Gray: letter is not in the word',
                style: RetroTheme.body,
              ),

              SizedBox(height: 24),
              Text('Disclaimer', style: RetroTheme.section),
              SizedBox(height: 8),
              Text(
                'The word bank of words is limited to remove as many archaic or '
                    'uncommonly known words to prevent the game from being too difficult. '
                    'We apologize if some real five letter words are considered invalid by '
                    'the game. Thank you for understanding, and we hope you enjoy the game!',
                style: RetroTheme.body,
              ),

              SizedBox(height: 24),
              Text('Credits', style: RetroTheme.section),
              SizedBox(height: 8),
              Text(
                'Made by Angela Santos, Brandon Trieu, Samuel Ji, and Andy Wu\n'
                    'Built with Flutter\n'
                '\nThis game is a remake and spin-off project of the renowned '
                    'puzzle game, Wordle, created by Josh Wardle and released '
                    'to the public in 2021. It has since been acquired and is '
                    'now owned by The New York Times.',
                style: RetroTheme.body,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
