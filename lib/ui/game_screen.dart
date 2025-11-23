/// GAME SCREEN:
///   game screen that wires everything
///   - provides FlutterWordleGame
///   - centers board widget and anchors hudoverlay
///   - shows win/lose sheet

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../ui/overlays/hud_overlay.dart';
import '../core/models/letter_status.dart';
import 'logic/flutter_wordle_game.dart';
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
      create: (_) => FlutterWordleGame(target: 'MAGIC'),
      child: Scaffold(
        backgroundColor: const Color(0xFF121213),
        body: Consumer<FlutterWordleGame>(
          builder: (context, game, _) {
            // Show win/lose once
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

            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(
                  child: BoardWidget(
                    letters: game.letters,
                    feedback: game.feedback,
                    tileSize: 64,
                    gap: 10,
                    // animations:
                    revealRowIndex: game.lastRevealedRow,
                    shakeRowIndex: game.shakeRowIndex,
                    shakeTrigger: game.shakeToken,
                    bounceRevealedRow: game.status == GameStatus.won,
                    bounceTrigger: game.lastRevealedRow,
                  ),
                ),
                const Spacer(),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: HudOverlay(
                    onKey: game.onKey,
                    keyStatuses: Map<String, LetterStatus>.from(game.keyStatuses),
                  )
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}