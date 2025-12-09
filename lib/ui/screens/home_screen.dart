/// HOME SCREEN:
///   home screen is the first screen users should see, includes:
///   - play button -> modes screen
///   - about button -> about screen

import 'package:flutter/material.dart';
import '../theme/retro_theme.dart';
import '../../core/services/progress_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ProgressService _progress = ProgressService();

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
                'A small Wordle-inspired game\nwith extra modes',
                style: RetroTheme.body,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),

              // play → modes list
              PixelButton(
                label: 'Play',
                onPressed: () {
                  Navigator.pushNamed(context, '/modes').then((_) {
                    setState(() {});
                  });
                },
              ),

              const SizedBox(height: 12),

              // about → credits & how to play
              PixelButton(
                label: 'About',
                primary: false,
                onPressed: () => Navigator.pushNamed(context, '/about'),
              ),

              const SizedBox(height: 24),

              // stats panel
              FutureBuilder<Map<String, int>>(
                future: _progress.stats(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const SizedBox.shrink();
                  }
                  final stats = snapshot.data!;
                  final games = stats['gamesPlayed'] ?? 0;
                  final wins = stats['wins'] ?? 0;
                  final dailyStreak = stats['currentStreak'] ?? 0;
                  final highestStreak = stats['highestStreak'] ?? 0;

                  return Column(
                    children: [
                      const Text(
                        'YOUR STATS',
                        style: RetroTheme.title,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Games played: $games   Wins: $wins',
                        style: RetroTheme.body,
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        'Daily streak: $dailyStreak\nHighest Streak: $highestStreak',
                        style: RetroTheme.body,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 32),

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
