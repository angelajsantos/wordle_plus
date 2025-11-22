/// Progress Service:
///   FIXME: track stats, streaks, and completion history.
///   persist with shared_preferences.

import 'package:shared_preferences/shared_preferences.dart';


class ProgressService {
  static const _gamesPlayed = 'games_played';
  static const _wins = 'wins';


  Future<void> recordGame({required bool win}) async {
    final p = await SharedPreferences.getInstance();
    final gp = p.getInt(_gamesPlayed) ?? 0;
    final w = p.getInt(_wins) ?? 0;
    await p.setInt(_gamesPlayed, gp + 1);
    if (win) await p.setInt(_wins, w + 1);
  }


  Future<Map<String, int>> stats() async {
    final p = await SharedPreferences.getInstance();
    return {
      'gamesPlayed': p.getInt(_gamesPlayed) ?? 0,
      'wins': p.getInt(_wins) ?? 0,
    };
  }
}