import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../domain/assessment_history.dart';

/// Repository for managing assessment history persistence
abstract class HistoryRepository {
  Future<List<AssessmentHistory>> getAll();
  Future<void> save(AssessmentHistory history);
  Future<void> delete(String id);
  Future<void> clear();
}

class LocalHistoryRepository implements HistoryRepository {
  static const _key = 'assessment_history';
  final SharedPreferences _prefs;

  LocalHistoryRepository(this._prefs);

  @override
  Future<List<AssessmentHistory>> getAll() async {
    final json = _prefs.getString(_key);
    if (json == null || json.isEmpty) return [];

    try {
      final list = jsonDecode(json) as List<dynamic>;
      return list
          .whereType<Map<String, dynamic>>()
          .map((e) => AssessmentHistory.fromJson(e))
          .toList()
        ..sort((a, b) => b.timestamp.compareTo(a.timestamp)); // newest first
    } catch (e) {
      print('❌ Failed to decode history: $e');
      return [];
    }
  }

  @override
  Future<void> save(AssessmentHistory history) async {
    final current = await getAll();
    current.insert(0, history); // Add to front

    // Keep only recent 50 entries
    final toSave = current.take(50).toList();

    final json = jsonEncode(toSave.map((e) => e.toJson()).toList());
    await _prefs.setString(_key, json);
  }

  @override
  Future<void> delete(String id) async {
    final current = await getAll();
    final filtered = current.where((e) => e.id != id).toList();

    final json = jsonEncode(filtered.map((e) => e.toJson()).toList());
    await _prefs.setString(_key, json);
  }

  @override
  Future<void> clear() async {
    await _prefs.remove(_key);
  }
}
