import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/focus_session.dart';
import 'app_exception.dart';

class FocusService {
  final SupabaseClient _client = Supabase.instance.client;

  String get _userId {
    final id = _client.auth.currentUser?.id;
    if (id == null) throw const AppException('Please sign in again.');
    return id;
  }

  Future<FocusSession> startSession({
    required String taskId,
    String? ambientSound,
  }) async {
    final startedAt = DateTime.now().toUtc().toIso8601String();

    try {
      final row = await _client
          .from('focus_sessions')
          .insert({
            'user_id': _userId,
            'task_id': taskId,
            'started_at': startedAt,
            'focus_seconds': 0,
            'status': FocusSessionStatus.active.name,
            'ambient_sound': ambientSound,
          })
          .select()
          .single();

      return FocusSession.fromMap(row);
    } catch (_) {
      throw const AppException('Could not start focus mode.');
    }
  }

  Future<void> finishSession({
    required FocusSession session,
    required int focusSeconds,
    bool cancelled = false,
  }) async {
    try {
      await _client
          .from('focus_sessions')
          .update({
            'ended_at': DateTime.now().toUtc().toIso8601String(),
            'focus_seconds': focusSeconds < 0 ? 0 : focusSeconds,
            'status': cancelled
                ? FocusSessionStatus.cancelled.name
                : FocusSessionStatus.completed.name,
          })
          .eq('id', session.id)
          .eq('user_id', _userId);
    } catch (_) {
      throw const AppException('Could not save the focus session.');
    }
  }

  Future<int> todaysCompletedFocusSeconds() async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day).toUtc();

    try {
      final rows = await _client
          .from('focus_sessions')
          .select('focus_seconds')
          .eq('user_id', _userId)
          .eq('status', FocusSessionStatus.completed.name)
          .gte('started_at', startOfDay.toIso8601String());

      var total = 0;
      for (final row in rows) {
        total += (row['focus_seconds'] ?? 0) as int;
      }
      return total;
    } catch (_) {
      throw const AppException('Could not load focus minutes.');
    }
  }
}
