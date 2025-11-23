/// GAME MODE:
///  - central place to define per-mode settings
///  - classic = 6 rows, 5 letters
///  - extend with hard/timed/etc. by adding cases + config

enum GameMode { classic /* , hard, timed */ }

extension GameModeConfig on GameMode {
  String get label {
    switch (this) {
      case GameMode.classic: return 'Classic';
    }
  }

  int get rows {
    switch (this) {
      case GameMode.classic: return 6;
    }
  }

  int get cols {
    switch (this) {
      case GameMode.classic: return 5;
    }
  }
}