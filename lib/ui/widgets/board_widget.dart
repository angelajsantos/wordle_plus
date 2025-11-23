/// BOARD WIDGET:
///   flutter board renderer (better than flames ..)
///   - renders the tile grid and anims

import 'package:flutter/material.dart';
import '../../core/models/letter_status.dart';
import '../animations/flip_tile.dart';
import '../animations/row_effects.dart';

class BoardWidget extends StatelessWidget {
  final int rows;
  final int cols;
  final double tileSize;
  final double gap;
  final List<List<String>> letters;
  final List<List<LetterStatus>> feedback;

  /// which row to flip (reveal)
  final int revealRowIndex;

  /// shake current row trigger
  final int shakeTrigger;
  final int shakeRowIndex;

  /// bounce when won
  final bool bounceRevealedRow;
  final int bounceTrigger; // usually same as reveal row index

  const BoardWidget({
    super.key,
    this.rows = 6,
    this.cols = 5,
    this.tileSize = 64,
    this.gap = 10,
    required this.letters,
    required this.feedback,
    this.revealRowIndex = -1,
    this.shakeTrigger = 0,
    this.shakeRowIndex = -1,
    this.bounceRevealedRow = false,
    this.bounceTrigger = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(rows, (r) {
        final reveal = r == revealRowIndex;
        final shake = r == shakeRowIndex;
        final bounce = reveal && bounceRevealedRow;

        final row = Row(
          key: ValueKey('row-content-$r'),
          mainAxisSize: MainAxisSize.min,
          children: List.generate(cols, (c) {
            return Padding(
              padding: EdgeInsets.all(gap / 2),
              child: AnimatedFlipTile(
                key: ValueKey('tile-$r-$c'),
                letter: letters[r][c],
                status: feedback[r][c],
                size: tileSize,
                flipDelayMs: reveal ? c * 110 : 0,
              ),
            );
          }),
        );

        return RowEffects(
          key: ValueKey('row-effects-$r'),
          shake: shake,
          bounce: bounce,
          shakeTrigger: shake ? shakeTrigger : 0,
          bounceTrigger: bounce ? bounceTrigger : 0,
          child: row,
        );
      }),
    );
  }
}