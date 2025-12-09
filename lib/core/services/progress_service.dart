/// Progress Service:
///   track stats, streaks, and completion history.
///   persist with shared_preferences.

import 'package:shared_preferences/shared_preferences.dart';

class ProgressService {
  static const _gamesPlayed = 'games_played';
  static const _wins = 'wins';

  // daily fields
  static const _dailyGamesPlayed = 'daily_games_played';
  static const _dailyWins = 'daily_wins';
  static const _currentStreak = 'current_streak';
  static const _highestStreak = 'highest_streak';
  static const _lastDailyDate = 'last_daily_date';

  /// records the result of the game
  Future<void> recordGame({required bool win, bool isDaily = false}) async {
    final p = await SharedPreferences.getInstance();

    // global stats
    final gp = (p.getInt(_gamesPlayed) ?? 0) + 1;
    final w = (p.getInt(_wins) ?? 0) + (win ? 1: 0);
    await p.setInt(_gamesPlayed, gp);
    await p.setInt(_wins, w);

    // daily stats and streaks
    if (!isDaily) return;

    final today = DateTime.now();
    final todayKey = _dateKey(today);

    final lastDateStr = p.getString(_lastDailyDate);
    var currentStreak = p.getInt(_currentStreak) ?? 0;
    var highestStreak = p.getInt(_highestStreak) ?? 0;
    var dailyGames = p.getInt(_dailyGamesPlayed) ?? 0;
    var dailyWins = p.getInt(_dailyWins) ?? 0;

    // don't double-count daily record
    if (lastDateStr == todayKey) {
      return;
    }

    dailyGames += 1;
    if (win) dailyWins += 1;

    if (lastDateStr == null) {
      // first daily ever
      currentStreak = win ? 1 : 0;
    } else {
      final last = DateTime.parse(lastDateStr);
      final lastDateOnly = DateTime(last.year, last.month, last.day);
      final todayDateOnly = DateTime(today.year, today.month, today.day);
      final diffDays = todayDateOnly.difference(lastDateOnly).inDays;

      if (diffDays == 1 && win) {
        // consecutive day & win → increase streak
        currentStreak += 1;
      } else if (diffDays == 1 && !win) {
        // consecutive day but lost → streak breaks
        currentStreak = 0;
      } else if (diffDays > 1) {
        // gap → streak resets, start from 1 if win, 0 if lose
        currentStreak = win ? 1 : 0;
      } else {
        // same day case is already returned above; diffDays < 0 won't happen in normal use
      }
    }

    if (currentStreak > highestStreak) {
      highestStreak = currentStreak;
    }

    await p.setString(_lastDailyDate, todayKey);
    await p.setInt(_currentStreak, currentStreak);
    await p.setInt(_highestStreak, highestStreak);
    await p.setInt(_dailyGamesPlayed, dailyGames);
    await p.setInt(_dailyWins, dailyWins);
  }

  /// overall stats
  Future<Map<String, int>> stats() async {
    final p = await SharedPreferences.getInstance();
    return {
      'gamesPlayed': p.getInt(_gamesPlayed) ?? 0,
      'wins': p.getInt(_wins) ?? 0,
      'dailyGamesPlayed': p.getInt(_dailyGamesPlayed) ?? 0,
      'dailyWins': p.getInt(_dailyWins) ?? 0,
      'currentStreak': p.getInt(_currentStreak) ?? 0,
      'highestStreak': p.getInt(_highestStreak) ?? 0,
    };
  }

  Future<String?> lastDailyDate() async {
    final p = await SharedPreferences.getInstance();
    return p.getString(_lastDailyDate);
  }

  // checks if the player already has daily recorded
  Future<bool> hasPlayedDailyToday() async {
    final p = await SharedPreferences.getInstance();
    final last = p.getString(_lastDailyDate);
    if (last == null) return false;

    final todayKey = _dateKey(DateTime.now());
    return last == todayKey;
  }

  String _dateKey(DateTime d) {
    final y = d.year.toString().padLeft(4, '0');
    final m = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return '$y-$m-$day';
  }
}