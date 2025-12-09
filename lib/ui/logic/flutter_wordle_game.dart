/// FLUTTER WORDLE GAME:
///   Current gameplay state and rules with word validation
///   - Keeps letters feedback matrices
///   - Validates guesses using WordService
///   - Computes feedback
///   - Tracks animations and win/lose state

import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/models/game_mode.dart';
import '../../core/models/letter_status.dart';
import '../../core/services/word_service.dart';
import '../../core/services/custom_word_service.dart';

enum GameStatus {
  playing,
  won,
  lost
}

class FlutterWordleGame extends ChangeNotifier {
  final GameMode mode;
  final WordService wordService;
  final CustomWordService customService;

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

  /// timer fields
  static const int _timedModeSeconds = 120;
  Timer? _timer;
  int? secondsLeft;

  FlutterWordleGame({
    required this.target,
    required this.wordService,
    required this.customService,
    this.mode = GameMode.classic,
  }) {
    letters = List.generate(rows, (_) => List.filled(cols, ''));
    feedback = List.generate(rows, (_) => List.filled(cols, LetterStatus.unknown));

    // starting timer in timed mode
    if (mode == GameMode.timed) {
      secondsLeft = _timedModeSeconds;
      _startTimer();
    }
  }

  bool get isTimed => mode == GameMode.timed;

  /// ----- new for different feedback display in game modes!
  /// feedback matrix for display
  List<List<LetterStatus>> get displayFeedback {
    if (mode == GameMode.swap) {
      return [
        for (final row in feedback)
          [for (final s in row) _swapStatus(s)]
      ];
    }

    if (mode == GameMode.noYellowHints) {
      return [
        for (final row in feedback)
          [for (final s in row) _hideYellow(s)]
      ];
    }

    return feedback; // classic
  }

  /// keyboard key statuses for display
  Map<String, LetterStatus> get displayKeyStatuses {
    if (mode == GameMode.swap) {
      return {
        for (final e in keyStatuses.entries)
          e.key: _swapStatus(e.value),
      };
    }

    if (mode == GameMode.noYellowHints) {
      return {
        for (final e in keyStatuses.entries)
          e.key: _hideYellow(e.value),
      };
    }

    return keyStatuses;
  }

  /// swap meaning of colors:
  /// green = incorrect place, yellow = wrong, gray = correct
  LetterStatus _swapStatus(LetterStatus status) {
    switch (status) {
      case LetterStatus.correct:
        return LetterStatus.absent;   // show gray
      case LetterStatus.present:
        return LetterStatus.correct;  // show green
      case LetterStatus.absent:
        return LetterStatus.present;  // show yellow
      case LetterStatus.unknown:
        return LetterStatus.unknown;
    }
  }

  /// hiding yellow
  LetterStatus _hideYellow(LetterStatus status) {
    if (status == LetterStatus.present) {
      return LetterStatus.absent;
    }
    return status;
  }

  // input from keyboard overlay
  void onKey(String key) {
    if (status != GameStatus.playing) return;

    // hides invalid message when user starts typing again
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

  Future<void> _submitCurrent() async {
    // checks if word is complete
    if (_current.length != cols) {
      _triggerShake();
      return;
    }

    // validate word using wordService
    final isValid = wordService.isValidGuess(_current, length: cols) ||
        (await customService.getWords()).contains(_current.toUpperCase());

    if (!isValid) {
    _triggerShake();
    notifyListeners();
    return;
    }

    // computes feedback
    final fb = wordService.feedback(target, _current);

    for (var i = 0; i < cols; i++) {
      feedback[_row][i] = fb[i];
    }

    // updates keyboard colors
    for (var i = 0; i < cols; i++) {
      final ch = _current[i].toUpperCase();
      keyStatuses[ch] = _prefer(keyStatuses[ch]!, fb[i]);
    }

    lastRevealedRow = _row;

    // check win condition
    final won = fb.every((e) => e == LetterStatus.correct);
    if (won) {
      status = GameStatus.won;
      _timer?.cancel(); // stop timer when game ends
      notifyListeners();
      return;
    }

    // move to next row
    _row++;
    _current = '';

    // check lose condition
    if (_row >= rows) {
      status = GameStatus.lost;
      _timer?.cancel(); // stop timer when lost
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

  // prefer higher status (correct > present > absent > unknown)
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

  /// timer logic
  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (status != GameStatus.playing) {
        timer.cancel();
        return;
      }
      if (secondsLeft == null) {
        timer.cancel();
        return;
      }

      secondsLeft = secondsLeft! - 1;

      if (secondsLeft! <= 0) {
        secondsLeft = 0;
        status = GameStatus.lost;
        notifyListeners();
        timer.cancel();
      } else {
        notifyListeners();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String get formattedTime {
    if (secondsLeft == null) return '';

    final m = secondsLeft! ~/ 60;
    final s = secondsLeft! % 60;

    final mm = m.toString().padLeft(2, '0');
    final ss = s.toString().padLeft(2, '0');

    return '$mm:$ss';
  }
}