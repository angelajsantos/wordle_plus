/// MODES SCREEN:
///   modes screen that has
///   - list of all modes

import 'package:flutter/material.dart';
import 'package:wordle_plus/ui/screens/custom_word_add_screen.dart';
import '../../core/models/game_mode.dart';
import 'game_screen.dart';
import '../theme/retro_theme.dart';
import '../../core/services/progress_service.dart';
import '../messages/retro_message.dart';

class ModesScreen extends StatelessWidget {
  const ModesScreen({
    super.key
  });

  @override
  Widget build(BuildContext context) {
    final modes = GameMode.values;

    return Scaffold(
      backgroundColor: RetroTheme.bg,
      appBar: AppBar(
        backgroundColor: RetroTheme.bg,
        elevation: 0,
        title: const Text('MODES', style: RetroTheme.title),
        centerTitle: true,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 540),
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemBuilder: (_, i) {
              final mode = modes[i];
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: RetroTheme.surface,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: RetroTheme.border, width: 2),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            mode.label.toUpperCase(),
                            style: RetroTheme.title.copyWith(
                              fontSize: 14,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(mode.description, style: RetroTheme.body),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    PixelButton(
                      label: 'GO!',
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      onPressed: () async {
                        // handles custom-word-add separately
                        if (mode == GameMode.customWordAdd) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const CustomWordAddScreen(),
                            ),
                          );
                          return;
                        }

                        // gates daily mode
                        if (mode == GameMode.daily) {
                          final progress = ProgressService();
                          final already = await progress.hasPlayedDailyToday();

                          if (already) {
                            RetroMessage.show(
                              context,
                              "You've already completed today's daily.\nCome back tomorrow!",
                            );
                            return;
                          }
                        }

                        // all other modes go to game screen
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => GameScreen(mode: mode),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              );
            },
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemCount: modes.length,
          ),
        ),
      ),
    );
  }
}