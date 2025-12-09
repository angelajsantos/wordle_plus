/// HOME SCREEN:
///   home screen is the first screen users should see, includes:
///   - play button -> modes screen
///   - about button -> about screen
///   TODO: fix ui styling

import 'package:flutter/material.dart';
import '../theme/retro_theme.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RetroTheme.bg,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Wordle+', style: RetroTheme.logo),
              const SizedBox(height: 12),
              const Text(
                'RETRO EDITION',
                style: RetroTheme.section),
              const SizedBox(height: 24),
              const Text(
                'A small Wordle-inspired game\nwith extra modes and chaos',
                style: RetroTheme.body,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),

              // play → modes list
              PixelButton(
                label: 'Play',
                onPressed: () => Navigator.pushNamed(context, '/modes'),
              ),

              const SizedBox(height: 12),

              // about → credits & how to play
              PixelButton(
                label: 'About',
                primary: false,
                onPressed: () => Navigator.pushNamed(context, '/about'),
              ),

              const SizedBox(height: 48),
              const Text(
                'Developed for CS 4750 by Team 16',
                style: RetroTheme.caption,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
