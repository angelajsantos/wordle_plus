import 'dart:math';

import 'package:shared_preferences/shared_preferences.dart';

class CustomWordService {
  static const _prefsKey = 'custom_word_bank_v1';

  Future<List<String>> getWords() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_prefsKey) ?? [];
    return list.map((e) => e.toUpperCase()).toList();
  }

  Future<void> setWords(List<String> words) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
        _prefsKey, words.map((e) => e.toUpperCase()).toList());
  }

  Future<void> addWord(String word) async {
    final w = word.toUpperCase();
    if (!_isValidWordFormat(w)) {
      throw FormatException('Word must be 5 letters A–Z');
    }
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_prefsKey) ?? [];
    final normalized = list.map((e) => e.toUpperCase()).toList();
    if (!normalized.contains(w)) {
      normalized.add(w);
      await prefs.setStringList(_prefsKey, normalized);
    }
  }

  Future<void> removeWord(String word) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_prefsKey) ?? [];
    final normalized = list.map((e) => e.toUpperCase()).toList();
    normalized.remove(word.toUpperCase());
    await prefs.setStringList(_prefsKey, normalized);
  }

  Future<String?> getRandomWord({int length = 5}) async {
    final words = (await getWords()).where((w) => w.length == length).toList();
    if (words.isEmpty) return null;
    final idx = Random().nextInt(words.length);
    return words[idx];
  }

  bool _isValidWordFormat(String w) {
    final regex = RegExp(r'^[A-Z]{5}$');
    return regex.hasMatch(w);
  }
}
