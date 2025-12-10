/// MODES SCREEN:
///   modes screen that has
///   - list of all modes

import 'package:flutter/material.dart';
import 'package:wordle_plus/ui/screens/custom_word_add_screen.dart';

import '../../core/models/game_mode.dart';
import '../../core/services/progress_service.dart';
import '../messages/retro_message.dart';
import '../theme/retro_theme.dart';
import 'game_screen.dart';

class ModesScreen extends StatelessWidget {
  const ModesScreen({super.key});

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
              return Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
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
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 10),
                          onPressed: () async {
                            // gates daily mode
                            if (mode == GameMode.daily) {
                              final progress = ProgressService();
                              final already =
                                  await progress.hasPlayedDailyToday();
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
                  ),
                  if (mode.hasCustomWordManagement)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const CustomWordAddScreen(),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(4),
                            border:
                                Border.all(color: RetroTheme.accent, width: 2),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.edit,
                                color: RetroTheme.accent,
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'MANAGE CUSTOM WORDS',
                                style: RetroTheme.section.copyWith(
                                  color: RetroTheme.accent,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
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
