/// ENDGAME MESSAGES:
///   centralized win/lose bottom-sheet ui

import 'package:flutter/material.dart';

class EndGameMessages {
  static Future<void> showEndSheet({
    required BuildContext context,
    required bool won,
    required String target,
    required int attempts, // 1-based
  }) {
    final msg = won
        ? 'You won in $attempts!'
        : 'Out of guesses! The word was $target.';

    return showModalBottomSheet(
      context: context,
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(msg, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      ),
    );
  }
}