/// Wordle Game:
///   ARCHIVED: flameGame scene: camera, board, keyboard, input routing

import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flame/camera.dart';
import '../core/models/letter_status.dart';
import '../core/models/game_state.dart';
import '../_archive/game_flame/event_bus.dart';
import 'components/board_component.dart';
import 'package:flame/events.dart';

class WordleGame extends FlameGame {
  late GameState state;
  final EventBus bus;

  late final BoardComponent board;

  WordleGame(this.bus, {required String target}) {
    state = GameState(target: target);
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Set a fixed logical coordinate system
    camera.viewport = FixedResolutionViewport(resolution: Vector2(360, 640));

    board = BoardComponent(rows: 6, cols: 5)
      ..anchor = Anchor.center;

    await add(board);
    board.position = Vector2(180, 320 - 40);
  }

  @override
  void onGameResize(Vector2 gameSize) {
    super.onGameResize(gameSize);
    if (isLoaded && children.contains(board)) {
      // Recenter when the viewport resizes
      board.position = Vector2(gameSize.x / 2, gameSize.y / 2);
    }
  }

  /// Wordle feedback with duplicate handling.
  List<LetterStatus> computeFeedback(String guess) {
    final t = state.target.toUpperCase();
    final g = guess.toUpperCase();
    final res = List<LetterStatus>.filled(5, LetterStatus.absent);

    final counts = <String, int>{};
    final unmatched = <int>[];

    // pass 1: mark corrects, count remaining letters
    for (var i = 0; i < 5; i++) {
      if (g[i] == t[i]) {
        res[i] = LetterStatus.correct;
      } else {
        unmatched.add(i);
        counts[t[i]] = (counts[t[i]] ?? 0) + 1;
      }
    }

    // pass 2: mark presents
    for (final i in unmatched) {
      final c = g[i];
      final left = counts[c] ?? 0;
      if (left > 0) {
        res[i] = LetterStatus.present;
        counts[c] = left - 1;
      } else {
        res[i] = LetterStatus.absent;
      }
    }
    return res;
  }
}
