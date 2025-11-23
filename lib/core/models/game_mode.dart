/// GAME MODE:
///  - central place to define per-mode settings
///  - classic = 6 rows, 5 letters
///  - extend with hard/timed/etc. by adding cases + config
///
/// HOW TO ADD A MODE
/// 1) Add enum value (e.g., hard, timed)
/// 2) Provide label/rows/cols in the extension
/// 3) Pass mode to GameScreen: GameScreen(mode: GameMode.hard)

enum GameMode {
  classic,
  // swap,           // swap meaning of colors (display only)
  // sixLetter,      // 6 letters, 6 rows
  // noYellowHints,  // show green/gray, hide yellow hints (display only)
  // timed,          // timer
}

extension GameModeConfig on GameMode {
  String get label {
    switch (this) {
      case GameMode.classic:        return 'Classic';
      // case GameMode.swap:           return 'Swap';
      // case GameMode.sixLetter:      return '6-Letter';
      // case GameMode.noYellowHints:  return 'No-Yellow Hints';
      // case GameMode.timed:          return 'Timed';
    }
  }

  int get rows {
    switch (this) {
      case GameMode.classic: return 6;
      default: return 6;
    }
  }

  int get cols {
    switch (this) {
      // case GameMode.sixLetter: return 6;
      default: return 5;
    }
  }

  /// short blurb for the modes list
  String get description {
    switch (this) {
      case GameMode.classic:        return '6 rows • 5 letters';
      // case GameMode.swap:           return 'Color meanings are shuffled (for fun)';
      // case GameMode.sixLetter:      return '6 rows • 6 letters';
      // case GameMode.noYellowHints:  return 'Only green/gray shown — no yellow hints';
      // case GameMode.timed:          return 'Solve under a time limit';
    }
  }
}