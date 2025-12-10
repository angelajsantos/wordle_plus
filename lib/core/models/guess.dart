/// Guess Model:
///   holds letters and per-life LetterStatus for a row
///   useful for analytics/history or replays

import 'letter_status.dart';

class Guess {
  final String word;
  final List<LetterStatus> feedback;

  Guess(this.word, this.feedback);
}
