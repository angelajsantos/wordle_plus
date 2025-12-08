/// ENDGAME MESSAGES:
///   centralized win/lose bottom-sheet ui

import 'package:flutter/material.dart';
import '../theme/retro_theme.dart';
import 'package:confetti/confetti.dart';

class EndGameMessages {
  static Future<void> showEndSheet({
    required BuildContext context,
    required bool won,
    required String target,
    required int attempts, // 1-based
  }) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => _EndGameDialog(
        won: won,
        target: target,
        attempts: attempts,
      ),
    );
  }
}

class _EndGameDialog extends StatefulWidget {
  final bool won;
  final String target;
  final int attempts;

  const _EndGameDialog({
    required this.won,
    required this.target,
    required this.attempts,
  });

  @override
  State<_EndGameDialog> createState() => _EndGameDialogState();
}

class _EndGameDialogState extends State<_EndGameDialog> {
  late final ConfettiController _confetti;

  @override
  void initState() {
    super.initState();
    _confetti = ConfettiController(duration: const Duration(seconds: 2));

    // only celebrate on win
    if (widget.won) {
      _confetti.play();
    }
  }

  @override
  void dispose() {
    _confetti.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final msg = widget.won
        ? 'YOU WON IN ${widget.attempts}!'
        : 'OUT OF GUESSES!\nWORD WAS ${widget.target.toUpperCase()}';

    return Center(
      child: Material(
        color: Colors.transparent,
        child: Stack(
          alignment: Alignment.topCenter,
            children: [
              // confetti layer
              ConfettiWidget(
                confettiController: _confetti,
                blastDirectionality: BlastDirectionality.explosive,
                shouldLoop: false,
                emissionFrequency: 0.05,
                numberOfParticles: 12,
                maxBlastForce: 20,
                minBlastForce: 8,
                gravity: 0.4,
            ),
            // dialog content
            Container(
              width: 300,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: RetroTheme.surface,
                border: Border.all(color: RetroTheme.border, width: 3),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    msg,
                    textAlign: TextAlign.center,
                    style: RetroTheme.title.copyWith(
                      fontSize: 20,
                      color: widget.won ? RetroTheme.accentAlt : RetroTheme.accent,
                    ),
                  ),

                  const SizedBox(height: 16),
                  if (!widget.won)
                    Text(
                      'Better luck next time!',
                      textAlign: TextAlign.center,
                      style: RetroTheme.body,
                    ),
                  const SizedBox(height: 20),
                  PixelButton(
                    label: 'OK',
                    padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}