/// Game Mode:
///   enum / config for available modes (classic, timed, hard, etc)
///   potential additions:
///   - per-mode rules

abstract class GameMode {
  String get id;        // ex: "classic"
  int get wordLength;
  int get maxGuesses;
  String pickTarget(DateTime now);
}