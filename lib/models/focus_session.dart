enum FocusSessionStatus { active, completed, cancelled }

class FocusSession {
  final String id;
  final String userId;
  final String taskId;
  final DateTime startedAt;
  final DateTime? endedAt;
  final int focusSeconds;
  final FocusSessionStatus status;
  final String? ambientSound;

  const FocusSession({
    required this.id,
    required this.userId,
    required this.taskId,
    required this.startedAt,
    this.endedAt,
    this.focusSeconds = 0,
    this.status = FocusSessionStatus.active,
    this.ambientSound,
  });

  factory FocusSession.fromMap(Map<String, dynamic> map) {
    return FocusSession(
      id: map['id'].toString(),
      userId: map['user_id'].toString(),
      taskId: map['task_id'].toString(),
      startedAt: DateTime.parse(map['started_at'].toString()),
      endedAt: map['ended_at'] == null
          ? null
          : DateTime.tryParse(map['ended_at'].toString()),
      focusSeconds: (map['focus_seconds'] ?? 0) as int,
      status: FocusSessionStatus.values.firstWhere(
        (status) => status.name == (map['status'] ?? 'active').toString(),
        orElse: () => FocusSessionStatus.active,
      ),
      ambientSound: map['ambient_sound'] as String?,
    );
  }
}
