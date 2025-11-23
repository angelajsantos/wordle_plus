/// FLUTTER WORDLE GAME:
///   current gameplay state and rules
///   - keeps letters feedback matrices
///   - validates guesses, computes feedback
///   - tracks animations and win/lose state

import 'package:flutter/material.dart';
import '../../core/models/game_mode.dart';
import '../../core/models/letter_status.dart';

enum GameStatus {
  playing,
  won,
  lost
}

class FlutterWordleGame extends ChangeNotifier {
  // rows and cols in game mode
  final GameMode mode;
  int get rows => mode.rows;
  int get cols => mode.cols;

  final Map<String, LetterStatus> keyStatuses = {
    for (var c in 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'.split('')) c: LetterStatus.unknown,
  };

  final String target;
  GameStatus status = GameStatus.playing;

  late List<List<String>> letters;
  late List<List<LetterStatus>> feedback;

  String _current = '';
  int _row = 0;

  /// increment to trigger shake on short submit
  int invalidTick = 0;

  /// the row index that was just revealed
  int lastRevealedRow = -1;

  int get currentRow => _row;

  /// shake state (scoped to a specific row)
  int shakeRowIndex = -1;   // which row should shake
  int shakeToken = 0;       // bump to re-trigger the shake

  FlutterWordleGame({
    required this.target,
    this.mode = GameMode.classic,
  })
  {
    letters  = List.generate(rows, (_) => List.filled(cols, ''));
    feedback = List.generate(rows, (_) => List.filled(cols, LetterStatus.unknown));
  }

  // input from keyboard OVERLAY
  void onKey(String key) {
    if (status != GameStatus.playing) return;

    if (key == '>' && _current.isNotEmpty) {
      _current = _current.substring(0, _current.length - 1);
      _syncRowLetters();
      notifyListeners();
      return;
    }
    if (key == '<') {
      _submitCurrent();
      return;
    }
    if (RegExp(r'^[A-Z]$').hasMatch(key) && _current.length < cols) {
      _current += key;
      _syncRowLetters();
      notifyListeners();
    }
  }

  void _syncRowLetters() {
    for (var i = 0; i < cols; i++) {
      letters[_row][i] = i < _current.length ? _current[i] : '';
    }
  }

  void _submitCurrent() {
    if (_current.length != cols) {
      shakeRowIndex = _row;  // <-- important: not currentRow everywhere
      shakeToken++;          // bump so RowEffects runs again
      notifyListeners();
      return;
    }

    final fb = _computeFeedback(target, _current);
    for (var i = 0; i < cols; i++) {
      feedback[_row][i] = fb[i];
    }
    for (var i = 0; i < cols; i++) {
      final ch = _current[i].toUpperCase();
      keyStatuses[ch] = _prefer(keyStatuses[ch]!, fb[i]);
    }
    lastRevealedRow = _row;

    final won = fb.every((e) => e == LetterStatus.correct);
    if (won) {
      status = GameStatus.won;
      notifyListeners();
      return;
    }

    _row++;
    _current = '';
    if (_row >= rows) {
      status = GameStatus.lost;
      notifyListeners();
      return;
    }
    _syncRowLetters();
    notifyListeners();
  }

  // Highest wins: correct > present > absent > unknown
  LetterStatus _prefer(LetterStatus oldS, LetterStatus newS) {
    int rank(LetterStatus s) {
      switch (s) {
        case LetterStatus.unknown: return 0;
        case LetterStatus.absent:  return 1;
        case LetterStatus.present: return 2;
        case LetterStatus.correct: return 3;
      }
    }
    return rank(newS) >= rank(oldS) ? newS : oldS;
  }

  List<LetterStatus> _computeFeedback(String target, String guess) {
    final t = target.toUpperCase();
    final g = guess.toUpperCase();
    final res = List<LetterStatus>.filled(cols, LetterStatus.absent);
    final counts = <String, int>{};
    final unmatched = <int>[];

    for (var i = 0; i < cols; i++) {
      if (g[i] == t[i]) {
        res[i] = LetterStatus.correct;
      } else {
        unmatched.add(i);
        counts[t[i]] = (counts[t[i]] ?? 0) + 1;
      }
    }
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