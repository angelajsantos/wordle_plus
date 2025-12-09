/// GAME SCREEN:
///   Game screen that wires everything
///   - Provides FlutterWordleGame with WordService integration
///   - Centers board widget and anchors keyboard overlay
///   - Shows win/lose sheet
///   - Validates guesses using WordService
///   - Uses CustomWordService for custom mode
///   - Uses ProgressService to track stats & daily streaks

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/services/progress_service.dart';
import '../overlays/keyboard_overlay.dart';
import '../../core/models/letter_status.dart';
import '../../core/models/game_mode.dart';
import '../../core/services/word_service.dart';
import '../../core/services/custom_word_service.dart';
import '../logic/flutter_wordle_game.dart';
import '../widgets/board_widget.dart';
import '../messages/endgame_messages.dart';
import '../theme/retro_theme.dart';
import '../messages/retro_message.dart';

class GameScreen extends StatefulWidget {
  final GameMode mode;
  const GameScreen({super.key, this.mode = GameMode.classic});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  bool _endShown = false;

  Color _timerColor(FlutterWordleGame game) {
    if (!game.isTimed || game.secondsLeft == null) {
      return RetroTheme.textPrimary;
    }

    final s = game.secondsLeft!;

    if (s > 30) {
      // plenty of time left
      return RetroTheme.accent;
    } else if (s > 10) {
      // getting closer
      return Color(0xFFC9B458);
    } else {
      // danger zone
      return Colors.redAccent;
    }
  }

  @override
  Widget build(BuildContext context) {
    final wordService = Provider.of<WordService>(context, listen: false);
    final customService = Provider.of<CustomWordService>(context, listen: false);
    final progressService = ProgressService();

    // assigns target from correct word bank based on mode
    Future<String> _resolveTarget() async {
      if (widget.mode == GameMode.customWord) {
        final w = await customService.getRandomWord(length: widget.mode.cols);
        if (w != null) return w;
        // fallback if bank empty: pick a normal word and notify user
        final normal = wordService.getRandomAnswer(length: widget.mode.cols);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          RetroMessage.show(context, 'Custom bank empty — using regular word list');
        });
        return normal;
      } else {
        return wordService.getRandomAnswer(length: widget.mode.cols);
      }
    }
    return FutureBuilder<String>(
        future: _resolveTarget(),
        builder: (context, snap) {
          if (!snap.hasData) {
            return const Scaffold(
                body: Center(child: CircularProgressIndicator()));
          }
          final target = snap.data!;
          return ChangeNotifierProvider(
            key: ValueKey('game-${widget.mode.name}-$target'),
            create: (_) =>
                FlutterWordleGame(
                  target: target,
                  mode: widget.mode,
                  wordService: wordService,
                  customService: customService,
                ),
            child: Scaffold(
              backgroundColor: RetroTheme.bg,
              appBar: AppBar(
                backgroundColor: RetroTheme.bg,
                elevation: 0,
                centerTitle: true,
                iconTheme: const IconThemeData(
                  color: RetroTheme.textPrimary, // make arrow white/pixel-like
                  size: 20,
                ),
                title: Text(
                  widget.mode.label.toUpperCase(),
                  style: RetroTheme.title,
                ),
              ),
              body: Consumer<FlutterWordleGame>(
                builder: (context, game, _) {
                  // shows win/lose sheet once
                  if (!_endShown && game.status != GameStatus.playing) {
                    _endShown = true;

                    final won = game.status == GameStatus.won;
                    // saves progress (global + daily streak)
                    progressService.recordGame(
                      win: won,
                      isDaily: widget.mode == GameMode.daily,
                    );

                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      EndGameMessages.showEndSheet(
                        context: context,
                        won: game.status == GameStatus.won,
                        target: game.target,
                        attempts: game.lastRevealedRow + 1,
                      );
                    });
                  }

                  return Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 480),
                      child: Column(
                        children: [
                          // timer display for timed mode
                          if (game.isTimed && game.secondsLeft != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 4.0),
                              child: Text(
                                'TIME LEFT: ${game.formattedTime}',
                                style: RetroTheme.section.copyWith(
                                  color: _timerColor(game),
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),

                          const SizedBox(height: 2),

                          // divider
                          Container(
                            height: 1,
                            color: RetroTheme.border,
                            margin: const EdgeInsets.symmetric(horizontal: 12),
                          ),

                          const SizedBox(height: 4),

                          // invalid word message
                          if (game.showInvalidMessage)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Text(
                                'NOT IN WORD LIST',
                                style: RetroTheme.section.copyWith(
                                  color: Colors.redAccent,
                                ),
                              ),
                            ),

                          // centered board
                          Center(
                            child: BoardWidget(
                              rows: game.rows,
                              cols: game.cols,
                              letters: game.letters,
                              feedback: game.displayFeedback,
                              tileSize: 60,
                              gap: 8,
                              revealRowIndex: game.lastRevealedRow,
                              shakeRowIndex: game.shakeRowIndex,
                              shakeTrigger: game.shakeToken,
                              bounceRevealedRow: game.status == GameStatus.won,
                              bounceTrigger: game.lastRevealedRow,
                            ),
                          ),

                          const Spacer(),

                          // keyboard
                          Align(
                            alignment: Alignment.bottomCenter,
                            child: HudOverlay(
                              onKey: game.onKey,
                              keyStatuses: Map<String, LetterStatus>.from(
                                  game.displayKeyStatuses),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        },
    );
  }
}