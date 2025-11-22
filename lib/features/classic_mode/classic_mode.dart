/// Classic Mode:
///   FIXME: feature entry for classic mode

import '../../core/models/game_mode.dart';


class ClassicMode implements GameMode {
  @override
  String get id => 'classic';
  @override
  int get wordLength => 5;
  @override
  int get maxGuesses => 6;


  @override
  String pickTarget(DateTime now) {
    // Simple deterministic daily index.
    final epoch = DateTime.utc(2021, 6, 19);
    final days = now.toUtc().difference(epoch).inDays;
    // You’ll inject the `answers` list via WordService instead in production.
    // Return a placeholder for now; wire it up in Game init.
    return 'ABOUT';
  }
}