/// Word Service:
///   Provides target words and validation list.
///   Loads words from assets/words/words.txt

import 'dart:math';
import 'package:flutter/services.dart';
import '../models/letter_status.dart';

class WordService {
  final Set<String> allowed;
  final List<String> answers;

  WordService({required this.allowed, required this.answers});

  /// Factory constructor to load words from asset file
  static Future<WordService> loadFromAssets() async {
    try {
      // Load all words from single file
      final wordsText = await rootBundle.loadString('assets/words/words.txt');
      final allWords = wordsText
          .split('\n')
          .map((w) => w.trim().toUpperCase())
          .where((w) => w.isNotEmpty && w.length == 5)
          .toList();

      // Use all words as allowed guesses
      final allowedWords = allWords.toSet();

      // Use all words as potential answers
      final answerWords = allWords;

      print(' Loaded ${allowedWords.length} allowed words');
      print(' Loaded ${answerWords.length} answer words');

      return WordService(
        allowed: allowedWords,
        answers: answerWords,
      );
    } catch (e) {
      print(' Error loading word file: $e');
      print(' Make sure assets/words/words.txt exists!');

      // Fallback with minimal words
      return WordService(
        allowed: {'ABOUT', 'MAGIC', 'SOUND', 'BRICK', 'LIGHT', 'ROUND', 'HOUSE', 'WORLD'},
        answers: ['ABOUT', 'MAGIC', 'SOUND', 'BRICK', 'LIGHT', 'ROUND', 'HOUSE', 'WORLD'],
      );
    }
  }

  /// Check if a guess is valid (5 letters)
  bool isValidGuess(String guess, {int length = 5}) =>
      guess.length == length && allowed.contains(guess.toUpperCase());

  /// Get a random answer word
  String getRandomAnswer({int? seed}) {
    if (answers.isEmpty) return 'MAGIC';
    final random = seed != null ? Random(seed) : Random();
    return answers[random.nextInt(answers.length)];
  }

  /// Get answer for a specific date (daily challenge style)
  String getDailyAnswer(DateTime date) {
    if (answers.isEmpty) return 'MAGIC';
    // Use days since epoch as seed for consistency
    final daysSinceEpoch = date.difference(DateTime(2024, 1, 1)).inDays;
    return answers[daysSinceEpoch % answers.length];
  }

  /// Compute feedback for a guess against target
  List<LetterStatus> feedback(String target, String guess) {
    final t = target.toUpperCase();
    final g = guess.toUpperCase();
    final result = List<LetterStatus>.filled(5, LetterStatus.absent);

    // First pass: mark correct positions
    final unmatched = <int>[];
    final remainingCounts = <String, int>{};
    for (var i = 0; i < 5; i++) {
      if (g[i] == t[i]) {
        result[i] = LetterStatus.correct;
      } else {
        unmatched.add(i);
        remainingCounts[t[i]] = (remainingCounts[t[i]] ?? 0) + 1;
      }
    }

    // Second pass: mark present letters
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