/// Word Service:
///   FIXME: provides target words and validation list.

import 'package:collection/collection.dart';
import '../models/letter_status.dart';

class WordService {
  final Set<String> allowed;
  final List<String> answers;

  WordService({required this.allowed, required this.answers});

  bool isValidGuess(String guess) =>
      guess.length == 5 && allowed.contains(guess.toUpperCase());

  List<LetterStatus> feedback(String target, String guess) {
    final t = target.toUpperCase();
    final g = guess.toUpperCase();
    final result = List<LetterStatus>.filled(5, LetterStatus.absent);

    // first pass: correct positions
    final unmatched = <int>[];
    final remainingCounts = <String, int>{};
    for (var i = 0; i < 5; i++) {
      if (g[i] == t[i]) {
        result[i] = LetterStatus.correct;
      }
      else {
        unmatched.add(i);
        remainingCounts[t[i]] = (remainingCounts[t[i]] ?? 0) + 1;
      }
    }

    // second pass: present letters
    for (final i in unmatched) {
      final c = g[i];
      final left = remainingCounts[c] ?? 0;
      if (left > 0) {
        result[i] = LetterStatus.present;
        remainingCounts[c] = left - 1;
      }
      else {
        result[i] = LetterStatus.absent;
      }
    }

    return result;
  }
}