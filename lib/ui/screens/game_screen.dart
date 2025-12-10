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

import '../../core/models/game_mode.dart';
import '../../core/models/letter_status.dart';
import '../../core/services/custom_word_service.dart';
import '../../core/services/hint_service.dart';
import '../../core/services/progress_service.dart';
import '../../core/services/word_service.dart';
import '../logic/flutter_wordle_game.dart';
import '../messages/endgame_messages.dart';
import '../messages/retro_message.dart';
import '../overlays/keyboard_overlay.dart';
import '../theme/retro_theme.dart';
import '../widgets/board_widget.dart';

class GameScreen extends StatefulWidget {
  final GameMode mode;

  const GameScreen({super.key, this.mode = GameMode.classic});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  bool _endShown = false;

  Color _timerColor(FlutterWordleGame game) {
    if (!game.isTimed || game.secondsLeft == null)
      return RetroTheme.textPrimary;
    final s = game.secondsLeft!;
    if (s > 30) return RetroTheme.accent;
    if (s > 10) return const Color(0xFFC9B458);
    return Colors.redAccent;
  }

  @override
  Widget build(BuildContext context) {
    final wordService = Provider.of<WordService>(context, listen: false);
    final customService =
        Provider.of<CustomWordService>(context, listen: false);
    final progressService = ProgressService();

    // Picks the target word for the selected mode.
    Future<String> _resolveTarget() async {
      if (widget.mode == GameMode.customWord) {
        final w = await customService.getRandomWord(length: widget.mode.cols);
        if (w != null) return w;
        final normal = wordService.getRandomAnswer(length: widget.mode.cols);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          RetroMessage.show(
              context, 'Custom bank empty — using regular word list');
        });
        return normal;
      }
      return wordService.getRandomAnswer(length: widget.mode.cols);
    }

    return FutureBuilder<String>(
      future: _resolveTarget(),
      builder: (context, snap) {
        if (!snap.hasData) {
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
        }

        // Reset hint state for a fresh round.
        context.read<HintService>().resetForNewGame();

        final target = snap.data!;
        return ChangeNotifierProvider(
          key: ValueKey('game-${widget.mode.name}-$target'),
          create: (_) => FlutterWordleGame(
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
              iconTheme:
                  const IconThemeData(color: RetroTheme.textPrimary, size: 20),
              title: Text(widget.mode.label.toUpperCase(),
                  style: RetroTheme.title),
              actions: const [_HintButton()],
            ),
            body: Consumer<FlutterWordleGame>(
              builder: (context, game, _) {
                // Show end sheet only once and record progress.
                if (!_endShown && game.status != GameStatus.playing) {
                  _endShown = true;
                  final won = game.status == GameStatus.won;
                  progressService.recordGame(
                    win: won,
                    isDaily: widget.mode == GameMode.daily,
                  );
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    EndGameMessages.showEndSheet(
                      context: context,
                      won: won,
                      target: game.target,
                      attempts: game.lastRevealedRow + 1,
                      onPlayAgain: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (_) => GameScreen(mode: widget.mode)),
                        );
                      },
                    );
                  });
                }

                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 480),
                          child: Column(
                            children: [
                              if (game.isTimed && game.secondsLeft != null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4.0),
                                  child: Text(
                                    'TIME LEFT: ${game.formattedTime}',
                                    style: RetroTheme.section
                                        .copyWith(color: _timerColor(game)),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              const SizedBox(height: 2),
                              Container(
                                height: 1,
                                color: RetroTheme.border,
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 12),
                              ),
                              const SizedBox(height: 4),
                              if (game.showInvalidMessage)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: Text(
                                    'NOT IN WORD LIST',
                                    style: RetroTheme.section
                                        .copyWith(color: Colors.redAccent),
                                  ),
                                ),
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
                                  bounceRevealedRow:
                                      game.status == GameStatus.won,
                                  bounceTrigger: game.lastRevealedRow,
                                ),
                              ),
                              const Spacer(),
                              Align(
                                alignment: Alignment.bottomCenter,
                                child: HudOverlay(
                                  onKey: game.onKey,
                                  keyStatuses: Map<String, LetterStatus>.from(
                                    game.displayKeyStatuses,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const _HintsPanel(),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }
}

// Uses the raw feedback matrix and listens to game changes.
class _HintButton extends StatelessWidget {
  const _HintButton();

  @override
  Widget build(BuildContext context) {
    final hintSvc = context.watch<HintService>();
    // watch game so this rebuilds when feedback changes
    final game = context.watch<FlutterWordleGame>();
    final answer = game.target;

    // collect correct-position indexes from all rows
    final greens = <int>{};
    final fb = game.feedback;
    for (var r = 0; r < fb.length; r++) {
      final rowFb = fb[r];
      for (var c = 0; c < rowFb.length; c++) {
        if (rowFb[c] == LetterStatus.correct) {
          greens.add(c);
        }
      }
    }

    // enable only if there is an index that is not green and not hinted yet
    var canHint = hintSvc.hintsRemaining > 0;
    if (canHint) {
      canHint = false;
      for (var i = 0; i < answer.length; i++) {
        if (!greens.contains(i) && !hintSvc.hintedIndexes.contains(i)) {
          canHint = true;
          break;
        }
      }
    }

    return TextButton.icon(
      onPressed: canHint
          ? () {
              final msg = hintSvc.revealHint(
                answer: answer,
                greens: greens,
              );
              if (msg == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('All letters already known')),
                );
              }
            }
          : null,
      icon: const Icon(Icons.tips_and_updates_outlined),
      label: Text('Hint (${hintSvc.hintsRemaining})'),
    );
  }
}

// Simple right-side panel that lists given hints.
class _HintsPanel extends StatelessWidget {
  const _HintsPanel();

  @override
  Widget build(BuildContext context) {
    final hintSvc = context.watch<HintService>();
    return Container(
      width: 180,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: RetroTheme.surface,
        border: Border.all(color: RetroTheme.border, width: 2),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('HINTS', style: RetroTheme.section),
          const SizedBox(height: 6),
          if (hintSvc.history.isEmpty)
            const Text('Press “Hint” to reveal a letter.'),
          for (final h in hintSvc.history)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(h, style: RetroTheme.body),
            ),
        ],
      ),
    );
  }
}
