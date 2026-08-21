class TaskStep {
  final String id;
  final String taskId;
  final String userId;
  final String title;
  final int position;
  final bool isCompleted;
  final DateTime? createdAt;
  final DateTime? completedAt;

  const TaskStep({
    required this.id,
    required this.taskId,
    required this.userId,
    required this.title,
    required this.position,
    required this.isCompleted,
    this.createdAt,
    this.completedAt,
  });

  factory TaskStep.fromMap(Map<String, dynamic> map) {
    return TaskStep(
      id: map['id'].toString(),
      taskId: map['task_id'].toString(),
      userId: map['user_id'].toString(),
      title: (map['title'] ?? '').toString(),
      position: (map['position'] ?? 0) as int,
      isCompleted: (map['is_completed'] ?? false) as bool,
      createdAt: _date(map['created_at']),
      completedAt: _date(map['completed_at']),
    );
  }
}

DateTime? _date(dynamic value) {
  if (value == null) return null;
  return DateTime.tryParse(value.toString());
}
