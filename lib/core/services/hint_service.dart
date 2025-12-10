import 'package:flutter/foundation.dart';

class HintService extends ChangeNotifier {
  static const int maxHintsPerGame = 3;

  int _hintsRemaining = maxHintsPerGame;
  final Set<int> _hintedIndexes = <int>{};
  final List<String> _history = <String>[];

  int get hintsRemaining => _hintsRemaining;

  List<String> get history => List.unmodifiable(_history);

  Set<int> get hintedIndexes => Set.unmodifiable(_hintedIndexes);

  void resetForNewGame() {
    _hintsRemaining = maxHintsPerGame;
    _hintedIndexes.clear();
    _history.clear();
    notifyListeners();
  }

  // chooses the left-most index that is not green and not hinted yet
  String? revealHint({
    required String answer,
    required Set<int> greens,
  }) {
    if (_hintsRemaining <= 0) return null;

    int? chosen;
    for (var i = 0; i < answer.length; i++) {
      if (!greens.contains(i) && !_hintedIndexes.contains(i)) {
        chosen = i;
        break;
      }
    }
    if (chosen == null) return null;

    final ch = answer[chosen].toUpperCase();
    final ord = _ordinal(chosen + 1);
    final hint = 'Hint: $ord letter is $ch';

    _hintedIndexes.add(chosen);
    _hintsRemaining -= 1;
    _history.add(hint);
    notifyListeners();
    return hint;
  }

  static String _ordinal(int n) {
    if (n % 100 >= 11 && n % 100 <= 13) return '${n}th';
    switch (n % 10) {
      case 1:
        return '${n}st';
      case 2:
        return '${n}nd';
      case 3:
        return '${n}rd';
      default:
        return '${n}th';
    }
  }
}
