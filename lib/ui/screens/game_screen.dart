/// GAME SCREEN:
///   game screen that wires everything
///   - provides FlutterWordleGame
///   - centers board widget and anchors hudoverlay
///   - shows win/lose sheet

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../ui/overlays/keyboard_overlay.dart';
import '../../../core/models/letter_status.dart';
import '../../../core/models/game_mode.dart';
import '../../ui/logic/flutter_wordle_game.dart';
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

  // simple target picker (5 letters for Classic)
  String _pickTarget(int len) {
    const words5 = ['MAGIC', 'ABOUT', 'SOUND', 'BRICK', 'LIGHT'];
    // ensure length matches len; expand for other lengths later
    return words5[DateTime.now().millisecond % words5.length];
  }

  @override
  Widget build(BuildContext context) {
    final target = _pickTarget(widget.mode.cols);

    return ChangeNotifierProvider(
      key: ValueKey('game-${widget.mode.name}-${target}'),
      create: (_) => FlutterWordleGame(
          target: target,
          mode: widget.mode,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFF121213),
        body: Consumer<FlutterWordleGame>(
          builder: (context, game, _) {
            // compute current visible attempt count (1-based)
            // final attempts = (game.lastRevealedRow >= 0)
            //     ? game.lastRevealedRow + 1
            //     : game.currentRow + 1;

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

            // back button
            return Stack(
              children: [
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

            // title, board, and keyboard
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                // keep UI tidy on wide screens
                child: Column(
                  children: [
                    // status line
                    // Padding(
                    //   padding: const EdgeInsets.only(top: 6, bottom: 10),
                      // child: Text(
                      //   '${game.rows} Attempts, ${game.cols} Letters',
                      //   style: const TextStyle(
                      //     color: Color(0xFFBDBDBD),
                      //     fontSize: 13,
                      //     fontWeight: FontWeight.w500,
                      //   ),
                      // ),
                    // ),
                    //
                    // // subtle divider
                    // Container(
                    //   height: 1,
                    //   color: const Color(0x22FFFFFF),
                    //   margin: const EdgeInsets.symmetric(horizontal: 12),
                    // ),

                    const SizedBox(height: 16),

                    // mode title
                    Text(
                      widget.mode.label.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 35,
                        fontWeight: FontWeight.w700,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 8),

                    Container(
                      height: 1,
                      color: const Color(0x22FFFFFF),
                      margin: const EdgeInsets.symmetric(horizontal: 12),
                    ),
                    const SizedBox(height: 8),

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
                      ]
                    )
                  ),
                ),
              ]
            );
          },
        ),
      )
    );
  }
}