/// HOME SCREEN:
///   home screen is the first screen users should see, includes:
///   - play button -> modes screen
///   - about button -> about screen
///   TODO: fix ui styling

import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Wordle+',
                style: TextStyle(
                  fontSize: 42,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'A fun Wordle remake',
                style: TextStyle(
                  color: Color(0xFFBDBDBD),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 32),

              // play → modes list
              TextButton(
                onPressed: () => Navigator.pushNamed(context, '/modes'),
                child: const Text('Play', style: TextStyle(fontSize: 18)),
              ),

              const SizedBox(height: 8),

              // About → credits & how to play
              TextButton(
                onPressed: () => Navigator.pushNamed(context, '/about'),
                child: const Text('About', style: TextStyle(fontSize: 18)),
              ),

              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }
}
