import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/task.dart';
import '../models/task_step.dart';
import 'app_exception.dart';

class TaskService {
  final SupabaseClient _client = Supabase.instance.client;

  String get _userId {
    final id = _client.auth.currentUser?.id;
    if (id == null) throw const AppException('Please sign in again.');
    return id;
  }

  Future<List<Task>> fetchTasks() async {
    try {
      final taskRows = await _client
          .from('tasks')
          .select()
          .eq('user_id', _userId)
          .order('created_at', ascending: false);

      final stepRows = await _client
          .from('task_steps')
          .select()
          .eq('user_id', _userId)
          .order('position', ascending: true);

      final stepsByTask = <String, List<TaskStep>>{};
      for (final row in stepRows) {
        final step = TaskStep.fromMap(row);
        stepsByTask.putIfAbsent(step.taskId, () => []).add(step);
      }

      return [
        for (final row in taskRows)
          Task.fromMap(row, steps: stepsByTask[row['id'].toString()] ?? []),
      ];
    } on AppException {
      rethrow;
    } catch (_) {
      throw const AppException('Could not load your sticky notes.');
    }
  }

  Future<Task> createTask({
    required String title,
    String? notes,
    int? estimatedMinutes,
    required String color,
    required String icon,
    String? tag,
    required TaskStatus status,
  }) async {
    if (title.trim().isEmpty) {
      throw const AppException('Give the sticky note a title first.');
    }

    final nowPosition = status == TaskStatus.now
        ? await _nextAvailableNowPosition()
        : null;

    if (status == TaskStatus.now && nowPosition == null) {
      throw const AppException('Your desk is full. Clear a slot first.');
    }

    try {
      final row = await _client
          .from('tasks')
          .insert({
            'user_id': _userId,
            'title': title.trim(),
            'notes': _blankToNull(notes),
            'estimated_minutes': estimatedMinutes,
            'color': color,
            'icon': icon.trim().isEmpty ? 'pin' : icon.trim(),
            'tag': _blankToNull(tag),
            'status': status.name,
            'now_position': nowPosition,
          })
          .select()
          .single();

      return Task.fromMap(row);
    } catch (_) {
      throw const AppException('Could not save the sticky note.');
    }
  }

  Future<Task> updateTask(Task task) async {
    var nowPosition = task.status == TaskStatus.now ? task.nowPosition : null;

    if (task.status == TaskStatus.now) {
      nowPosition = await _validNowPositionForTask(task.id, nowPosition);
      if (nowPosition == null) {
        throw const AppException('Your desk is full. Clear a slot first.');
      }
    }

    final data = task.copyWith(nowPosition: nowPosition).toSaveMap();
    data['updated_at'] = DateTime.now().toUtc().toIso8601String();

    try {
      final row = await _client
          .from('tasks')
          .update(data)
          .eq('id', task.id)
          .eq('user_id', _userId)
          .select()
          .single();

      return Task.fromMap(row, steps: task.steps);
    } catch (_) {
      throw const AppException('Could not update the sticky note.');
    }
  }

  Future<void> markDone(Task task) async {
    try {
      await _client
          .from('tasks')
          .update({
            'status': TaskStatus.done.name,
            'now_position': null,
            'completed_at': DateTime.now().toUtc().toIso8601String(),
            'updated_at': DateTime.now().toUtc().toIso8601String(),
          })
          .eq('id', task.id)
          .eq('user_id', _userId);
    } catch (_) {
      throw const AppException('Could not mark that note done.');
    }
  }

  Future<void> restoreToDump(Task task) async {
    await updateTask(task.copyWith(status: TaskStatus.dump, nowPosition: null));
  }

  Future<void> moveToNow(Task task) async {
    await updateTask(task.copyWith(status: TaskStatus.now));
  }

  Future<void> moveToDump(Task task) async {
    await updateTask(task.copyWith(status: TaskStatus.dump, nowPosition: null));
  }

  Future<void> deleteTask(Task task) async {
    try {
      await _client
          .from('task_steps')
          .delete()
          .eq('task_id', task.id)
          .eq('user_id', _userId);
      await _client
          .from('tasks')
          .delete()
          .eq('id', task.id)
          .eq('user_id', _userId);
    } catch (_) {
      throw const AppException('Could not delete the sticky note.');
    }
  }

  Future<TaskStep> addStep(Task task, String title) async {
    if (title.trim().isEmpty) {
      throw const AppException('Write the tiny step first.');
    }

    final nextPosition = task.steps.isEmpty
        ? 1
        : task.steps
                  .map((step) => step.position)
                  .reduce((a, b) => a > b ? a : b) +
              1;

    try {
      final row = await _client
          .from('task_steps')
          .insert({
            'task_id': task.id,
            'user_id': _userId,
            'title': title.trim(),
            'position': nextPosition,
            'is_completed': false,
          })
          .select()
          .single();

      return TaskStep.fromMap(row);
    } catch (_) {
      throw const AppException('Could not add the tiny step.');
    }
  }

  Future<void> toggleStep(TaskStep step) async {
    try {
      final completed = !step.isCompleted;
      await _client
          .from('task_steps')
          .update({
            'is_completed': completed,
            'completed_at': completed
                ? DateTime.now().toUtc().toIso8601String()
                : null,
          })
          .eq('id', step.id)
          .eq('user_id', _userId);
    } catch (_) {
      throw const AppException('Could not update the tiny step.');
    }
  }

  Future<void> deleteStep(TaskStep step) async {
    try {
      await _client
          .from('task_steps')
          .delete()
          .eq('id', step.id)
          .eq('user_id', _userId);
    } catch (_) {
      throw const AppException('Could not delete the tiny step.');
    }
  }

  RealtimeChannel subscribeToTaskChanges({required void Function() onChange}) {
    return _client
        .channel('nampak-tasks-$_userId')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'tasks',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: _userId,
          ),
          callback: (_) => onChange(),
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'task_steps',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: _userId,
          ),
          callback: (_) => onChange(),
        )
        .subscribe();
  }

  Future<void> removeSubscription(RealtimeChannel channel) async {
    await _client.removeChannel(channel);
  }

  Future<int?> _validNowPositionForTask(String taskId, int? desired) async {
    final rows = await _client
        .from('tasks')
        .select('id, now_position')
        .eq('user_id', _userId)
        .eq('status', TaskStatus.now.name);

    final occupied = <int>{};
    for (final row in rows) {
      if (row['id'].toString() == taskId) continue;
      final position = row['now_position'] as int?;
      if (position != null) occupied.add(position);
    }

    if (desired != null &&
        desired >= 1 &&
        desired <= 3 &&
        !occupied.contains(desired)) {
      return desired;
    }

    for (var position = 1; position <= 3; position++) {
      if (!occupied.contains(position)) return position;
    }

    return null;
  }

  Future<int?> _nextAvailableNowPosition() async {
    return _validNowPositionForTask('', null);
  }
}

String? _blankToNull(String? value) {
  final trimmed = value?.trim();
  if (trimmed == null || trimmed.isEmpty) return null;
  return trimmed;
}
