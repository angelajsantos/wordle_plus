/// Game State:
///   intended to use with flame
///   bundles target word and runtime state for flame game
///   ARCHIVED: flutter board uses flutter_wordle_game.dart instead

import '../core/models/guess.dart';

class GameState {
  final String target;
  final List<Guess> guesses;
  final int maxGuesses;
  final bool isComplete;
  final bool didWin;

  const GameState ({
    required this.target,
    this.guesses = const [],
    this.maxGuesses = 6,
    this.isComplete = false,
    this.didWin = false,
  });

  GameState copyWith ({
    String? target,
    List<Guess>? guesses,
    int? maxGuesses,
    bool? isComplete,
    bool? didWin,
  }) => GameState (
        target: target ?? this.target,
        guesses: guesses ?? this.guesses,
        maxGuesses: maxGuesses ?? this.maxGuesses,
        isComplete: isComplete ?? this.isComplete,
        didWin: didWin ?? this.didWin,
      );
}