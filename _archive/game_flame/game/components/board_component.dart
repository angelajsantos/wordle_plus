/// Board Components:
///   ARCHIVED: renders the grid as flame components
///   stopped using because centering was a pain in the ass

import 'package:flame/components.dart';
import '../../core/models/letter_status.dart';
import 'tile_component.dart';

class BoardComponent extends PositionComponent {
  final int rows;
  final int cols;
  final double tileSize;
  final double gap;
  late final List<TileComponent> tiles;

  BoardComponent({
    this.rows = 6,
    this.cols = 5,
    this.tileSize = 64,
    this.gap = 10,
  });

  @override
  Future<void> onLoad() async {
    tiles = [];

    // Physical size of the grid (used for centering math)
    size = Vector2(
      cols * tileSize + (cols - 1) * gap,
      rows * tileSize + (rows - 1) * gap,
    );

    // IMPORTANT: keep the board’s origin at its CENTER
    anchor = Anchor.center;

    // Start positions so that (0,0) is the exact center of the board
    final startX = -size.x / 2 + tileSize / 2;
    final startY = -size.y / 2 + tileSize / 2;

    for (var r = 0; r < rows; r++) {
      for (var c = 0; c < cols; c++) {
        final x = startX + c * (tileSize + gap);
        final y = startY + r * (tileSize + gap);
        final t = TileComponent(
          pos: Vector2(x, y),
          sizePx: Vector2(tileSize, tileSize),
        );
        tiles.add(t);
        add(t);
      }
    }
  }

  void setRowLetters(int row, String letters) {
    final padded = letters.padRight(cols).substring(0, cols);
    for (var i = 0; i < cols; i++) {
      tiles[row * cols + i].letter = padded[i];
    }
  }

  void setRowFeedback(int row, List<LetterStatus> statuses) {
    for (var i = 0; i < cols; i++) {
      tiles[row * cols + i].status = statuses[i];
    }
  }

  Future<void> flipRowTo(int row, List<LetterStatus> statuses) async {
    for (var i = 0; i < cols; i++) {
      await tiles[row * cols + i].flipTo(statuses[i]);
    }
  }

  Future<void> shakeRow(int row) async {
    for (var i = 0; i < cols; i++) {
      await tiles[row * cols + i].shake();
    }
  }

  Future<void> bounceRow(int row) async {
    for (var i = 0; i < cols; i++) {
      await tiles[row * cols + i].bounce();
    }
  }
}
