/// FLUTTER WORDLE GAME:
///   Current gameplay state and rules with word validation
///   - Keeps letters feedback matrices
///   - Validates guesses using WordService
///   - Computes feedback
///   - Tracks animations and win/lose state

import 'package:flutter/material.dart';
import '../../core/models/game_mode.dart';
import '../../core/models/letter_status.dart';
import '../../core/services/word_service.dart';

enum GameStatus {
  playing,
  won,
  lost
}

class FlutterWordleGame extends ChangeNotifier {
  final GameMode mode;
  final WordService wordService;

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

  /// Increment to trigger shake on invalid submit
  int invalidTick = 0;

  /// The row index that was just revealed
  int lastRevealedRow = -1;

  int get currentRow => _row;

  /// Shake state
  int shakeRowIndex = -1;
  int shakeToken = 0;

  /// Show "not in word list" message
  bool showInvalidMessage = false;

  FlutterWordleGame({
    required this.target,
    required this.wordService,
    this.mode = GameMode.classic,
  }) {
    letters = List.generate(rows, (_) => List.filled(cols, ''));
    feedback = List.generate(rows, (_) => List.filled(cols, LetterStatus.unknown));
  }

  // Input from keyboard overlay
  void onKey(String key) {
    if (status != GameStatus.playing) return;

    // Hide invalid message when user starts typing again
    if (showInvalidMessage) {
      showInvalidMessage = false;
      notifyListeners();
    }

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
    // Check if word is complete
    if (_current.length != cols) {
      _triggerShake();
      return;
    }

    // Validate word using WordService
    if (!wordService.isValidGuess(_current, length: cols)) {
      showInvalidMessage = true;
      _triggerShake();
      return;
    }

    // Compute feedback
    final fb = wordService.feedback(target, _current);

    for (var i = 0; i < cols; i++) {
      feedback[_row][i] = fb[i];
    }

    // Update keyboard colors
    for (var i = 0; i < cols; i++) {
      final ch = _current[i].toUpperCase();
      keyStatuses[ch] = _prefer(keyStatuses[ch]!, fb[i]);
    }

    lastRevealedRow = _row;

    // Check win condition
    final won = fb.every((e) => e == LetterStatus.correct);
    if (won) {
      status = GameStatus.won;
      notifyListeners();
      return;
    }

    // Move to next row
    _row++;
    _current = '';

    // Check lose condition
    if (_row >= rows) {
      status = GameStatus.lost;
      notifyListeners();
      return;
    }

    _syncRowLetters();
    notifyListeners();
  }

  void _triggerShake() {
    shakeRowIndex = _row;
    shakeToken++;
    notifyListeners();
  }

  // Prefer higher status (correct > present > absent > unknown)
  LetterStatus _prefer(LetterStatus oldS, LetterStatus newS) {
    int rank(LetterStatus s) {
      switch (s) {
        case LetterStatus.unknown: return 0;
        case LetterStatus.absent: return 1;
        case LetterStatus.present: return 2;
        case LetterStatus.correct: return 3;
      }
    }
    return rank(newS) >= rank(oldS) ? newS : oldS;
  }
}