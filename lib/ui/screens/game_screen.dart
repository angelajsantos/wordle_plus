/// GAME SCREEN:
///   Game screen that wires everything
///   - Provides FlutterWordleGame with WordService integration
///   - Centers board widget and anchors keyboard overlay
///   - Shows win/lose sheet
///   - Validates guesses using WordService

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../overlays/keyboard_overlay.dart';
import '../../core/models/letter_status.dart';
import '../../core/models/game_mode.dart';
import '../../core/services/word_service.dart';
import '../logic/flutter_wordle_game.dart';
import '../widgets/board_widget.dart';
import '../messages/endgame_messages.dart';

class GameScreen extends StatefulWidget {
  final GameMode mode;
  const GameScreen({super.key, this.mode = GameMode.classic});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  bool _endShown = false;

  @override
  Widget build(BuildContext context) {
    // Get WordService from Provider
    final wordService = Provider.of<WordService>(context, listen: false);

    // Get target word from WordService (random)
    final target = wordService.getRandomAnswer();

    return ChangeNotifierProvider(
      key: ValueKey('game-${widget.mode.name}-$target'),
      create: (_) => FlutterWordleGame(
        target: target,
        mode: widget.mode,
        wordService: wordService,  // Pass WordService
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFF121213),
        body: Consumer<FlutterWordleGame>(
          builder: (context, game, _) {
            // Show win/lose sheet once
            if (!_endShown && game.status != GameStatus.playing) {
              _endShown = true;
              WidgetsBinding.instance.addPostFrameCallback((_) {
                EndGameMessages.showEndSheet(
                  context: context,
                  won: game.status == GameStatus.won,
                  target: game.target,
                  attempts: game.lastRevealedRow + 1,
                );
              });
            }

            return Stack(
              children: [
                // Back button
                SafeArea(
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8, top: 8),
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          minimumSize: const Size(48, 28),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          foregroundColor: Colors.white70,
                        ),
                        child: const Text('Back'),
                      ),
                    ),
                  ),
                ),

                // Main content: title, board, and keyboard
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 480),
                    child: Column(
                      children: [
                        const SizedBox(height: 16),

                        // Mode title
                        Text(
                          widget.mode.label.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 35,
                            fontWeight: FontWeight.w700,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 8),

                        // Divider
                        Container(
                          height: 1,
                          color: const Color(0x22FFFFFF),
                          margin: const EdgeInsets.symmetric(horizontal: 12),
                        ),

                        const SizedBox(height: 8),

                        // Invalid word message
                        if (game.showInvalidMessage)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Text(
                              'Not in word list',
                              style: TextStyle(
                                color: Colors.red.shade400,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),

                        // Centered board
                        Center(
                          child: BoardWidget(
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

                        // Keyboard
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: HudOverlay(
                            onKey: game.onKey,
                            keyStatuses: Map<String, LetterStatus>.from(game.displayKeyStatuses),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}