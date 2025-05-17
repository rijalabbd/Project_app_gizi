// lib/services/history_service.dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:apk_gizi/data/models/history_entry.dart';

class HistoryService {
  static const _key = 'history_entries';

  static Future<void> addEntry(HistoryEntry entry) async {
    final prefs = await SharedPreferences.getInstance();
    final rawList = prefs.getStringList(_key) ?? [];
    rawList.insert(0, jsonEncode(entry.toJson()));
    await prefs.setStringList(_key, rawList);
  }

  static Future<List<HistoryEntry>> loadEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final rawList = prefs.getStringList(_key) ?? [];
    return rawList
        .map((s) =>
            HistoryEntry.fromJson(jsonDecode(s) as Map<String, dynamic>))
        .toList();
  }

  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
