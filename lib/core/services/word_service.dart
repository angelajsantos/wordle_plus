/// Word Service:
///   Provides target words and validation list.
///   Loads words from assets/words/words.txt for five-letter words
///   words_6.txt for six-letter words

import 'dart:math';
import 'package:flutter/services.dart';
import '../models/letter_status.dart';

class WordService {
  final Set<String> allowed5;
  final List<String> answers5;

  final Set<String> allowed6;
  final List<String> answers6;

  WordService({required this.allowed5, required this.answers5,
               required this.allowed6, required this.answers6});

  /// Factory constructor to load words from asset file
  static Future<WordService> loadFromAssets() async {
    try {
      // loads five letter words from single file
      final wordsText5 = await rootBundle.loadString('assets/words/words.txt');
      final words5 = wordsText5
          .split('\n')
          .map((w) => w.trim().toUpperCase())
          .where((w) => w.isNotEmpty && w.length == 5)
          .toList();

      // use all words as allowed guesses
      final allowed5 = words5.toSet();

      // use all words as potential answers
      final answers5 = words5;

      print(' Loaded ${allowed5.length} allowed words');
      print(' Loaded ${answers5.length} answer words');

      // load all six letter words from words_6.txt
      String wordsText6;
      try {
        wordsText6 = await rootBundle.loadString('assets/words/words_6.txt');
      } catch (_) {
        // if file not yet added, just starts with empty 6-letter sets
        wordsText6 = '';
      }

      final words6 = wordsText6
          .split('\n')
          .map((w) => w.trim().toUpperCase())
          .where((w) => w.isNotEmpty && w.length == 6)
          .toList();

      final allowed6 = words6.toSet();
      final answers6 = words6;

      print(' Loaded ${allowed6.length} allowed 6-letter words');
      print(' Loaded ${answers6.length} answer 6-letter words');

      return WordService(
        allowed5: allowed5,
        answers5: answers5,
        allowed6: allowed6,
        answers6: answers6,
      );
    } catch (e) {
      print(' Error loading word file: $e');
      print(' Make sure assets/words/words.txt exists!');

      // Fallback with minimal words
      final fallback5 = {'ABOUT', 'MAGIC', 'SOUND', 'BRICK', 'LIGHT', 'ROUND', 'HOUSE', 'WORLD'};
      final fallback6 = {'PLANET', 'SCHOOL', 'FRIEND', 'BUTTON', 'WINDOW'};

      return WordService(
        allowed5: fallback5,
        answers5: fallback5.toList(),
        allowed6: fallback6,
        answers6: fallback6.toList(),
      );
    }
  }

  /// Check if a guess is valid (5 letters)
  bool isValidGuess(String guess, {int length = 5}) {
    final g = guess.toUpperCase();

    if (length == 6) {
      return g.length == 6 && allowed6.contains(g);
    }
    else {
      // defaults to five-letter
      return g.length == 5 && allowed5.contains(g);
    }
  }

  /// Get a random answer word
  String getRandomAnswer({int length = 5, int? seed}) {
    List<String> pool;

    if (length == 6 && answers6.isNotEmpty) {
      pool = answers6;
    } else {
      // falls back to 5-letter
      pool = answers5;
    }

    if (pool.isEmpty) return 'MAGIC';
    final random = seed != null ? Random(seed) : Random();
    return pool[random.nextInt(pool.length)];
  }

  /// Get answer for a specific date (daily challenge style)
  String getDailyAnswer(DateTime date, {int length = 5}) {
    List<String> pool;

    if (length == 6 && answers6.isNotEmpty) {
      pool = answers6;
    } else {
      pool = answers5;
    }
    if (pool.isEmpty) return 'MAGIC';
    // uses days since epoch as seed for consistency
    final daysSinceEpoch = date.difference(DateTime(2024, 1, 1)).inDays;
    return pool[daysSinceEpoch % pool.length];
  }

  /// Compute feedback for a guess against target
  List<LetterStatus> feedback(String target, String guess) {
    final t = target.toUpperCase();
    final g = guess.toUpperCase();

    final len = t.length;
    final result = List<LetterStatus>.filled(len, LetterStatus.absent);

    // first pass: marks correct positions
    final unmatched = <int>[];
    final remainingCounts = <String, int>{};
    for (var i = 0; i < len; i++) {
      if (g[i] == t[i]) {
        result[i] = LetterStatus.correct;
      } else {
        unmatched.add(i);
        remainingCounts[t[i]] = (remainingCounts[t[i]] ?? 0) + 1;
      }
    }

    // second pass: marks present letters
    for (final i in unmatched) {
      final c = g[i];
      final left = remainingCounts[c] ?? 0;
      if (left > 0) {
        result[i] = LetterStatus.present;
        remainingCounts[c] = left - 1;
      } else {
        result[i] = LetterStatus.absent;
      }
    }

    return result;
  }
}