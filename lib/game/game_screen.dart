/// GAME SCREEN:
///   game screen that wires everything
///   - provides FlutterWordleGame
///   - centers board widget and anchors hudoverlay
///   - shows win/lose sheet

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../game/overlays/keyboard_overlay.dart';
import '../../core/models/letter_status.dart';
import '../../core/models/game_mode.dart';
import '../game/logic/flutter_wordle_game.dart';
import 'widgets/board_widget.dart';
import 'messages/endgame_messages.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});
  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  bool _endShown = false;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => FlutterWordleGame(
          target: 'MAGIC',
          mode: GameMode.classic,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFF121213),
        body: Consumer<FlutterWordleGame>(
          builder: (context, game, _) {
            // compute current visible attempt count (1-based)
            final attempts = (game.lastRevealedRow >= 0)
                ? game.lastRevealedRow + 1
                : game.currentRow + 1;

            // show win/lose once
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

            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                // keep UI tidy on wide screens
                child: Column(
                  children: [
                    const SizedBox(height: 20),

                    // title / mode
                    Text(
                      '${game.mode.label.toUpperCase()}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),

                    // status line
                    Padding(
                      padding: const EdgeInsets.only(top: 6, bottom: 10),
                      child: Text(
                        '${game.rows} Attempts, ${game.cols} Letters',
                        style: const TextStyle(
                          color: Color(0xFFBDBDBD),
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),

                    // subtle divider
                    Container(
                      height: 1,
                      color: const Color(0x22FFFFFF),
                      margin: const EdgeInsets.symmetric(horizontal: 12),
                    ),

                    const SizedBox(height: 12),

                    // centered board
                    Center(
                      child: BoardWidget(
                        letters: game.letters,
                        feedback: game.feedback,
                        tileSize: 64,
                        gap: 10,
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
                        keyStatuses: Map<String, LetterStatus>.from(game
                            .keyStatuses),
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
  }
}