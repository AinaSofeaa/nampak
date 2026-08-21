import 'task_step.dart';

enum TaskStatus { dump, now, done }

TaskStatus taskStatusFromText(String value) {
  return TaskStatus.values.firstWhere(
    (status) => status.name == value,
    orElse: () => TaskStatus.dump,
  );
}

class Task {
  final String id;
  final String userId;
  final String title;
  final String? notes;
  final int? estimatedMinutes;
  final String color;
  final String icon;
  final String? tag;
  final TaskStatus status;
  final int? nowPosition;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? completedAt;
  final List<TaskStep> steps;

  const Task({
    required this.id,
    required this.userId,
    required this.title,
    this.notes,
    this.estimatedMinutes,
    this.color = 'butter',
    this.icon = 'pin',
    this.tag,
    this.status = TaskStatus.dump,
    this.nowPosition,
    this.createdAt,
    this.updatedAt,
    this.completedAt,
    this.steps = const [],
  });

  factory Task.fromMap(
    Map<String, dynamic> map, {
    List<TaskStep> steps = const [],
  }) {
    return Task(
      id: map['id'].toString(),
      userId: map['user_id'].toString(),
      title: (map['title'] ?? '').toString(),
      notes: map['notes'] as String?,
      estimatedMinutes: map['estimated_minutes'] as int?,
      color: (map['color'] ?? 'butter').toString(),
      icon: (map['icon'] ?? 'pin').toString(),
      tag: map['tag'] as String?,
      status: taskStatusFromText((map['status'] ?? 'dump').toString()),
      nowPosition: map['now_position'] as int?,
      createdAt: _date(map['created_at']),
      updatedAt: _date(map['updated_at']),
      completedAt: _date(map['completed_at']),
      steps: steps,
    );
  }

  Task copyWith({
    String? title,
    String? notes,
    int? estimatedMinutes,
    String? color,
    String? icon,
    String? tag,
    TaskStatus? status,
    int? nowPosition,
    DateTime? completedAt,
    List<TaskStep>? steps,
  }) {
    return Task(
      id: id,
      userId: userId,
      title: title ?? this.title,
      notes: notes ?? this.notes,
      estimatedMinutes: estimatedMinutes ?? this.estimatedMinutes,
      color: color ?? this.color,
      icon: icon ?? this.icon,
      tag: tag ?? this.tag,
      status: status ?? this.status,
      nowPosition: nowPosition ?? this.nowPosition,
      createdAt: createdAt,
      updatedAt: updatedAt,
      completedAt: completedAt ?? this.completedAt,
      steps: steps ?? this.steps,
    );
  }

  int get completedStepCount {
    return steps.where((step) => step.isCompleted).length;
  }

  TaskStep? get firstUnfinishedStep {
    for (final step in steps) {
      if (!step.isCompleted) return step;
    }
    return null;
  }

  Map<String, dynamic> toSaveMap() {
    return {
      'title': title.trim(),
      'notes': _blankToNull(notes),
      'estimated_minutes': estimatedMinutes,
      'color': color,
      'icon': icon.trim().isEmpty ? 'pin' : icon.trim(),
      'tag': _blankToNull(tag),
      'status': status.name,
      'now_position': status == TaskStatus.now ? nowPosition : null,
    };
  }
}

DateTime? _date(dynamic value) {
  if (value == null) return null;
  return DateTime.tryParse(value.toString());
}

String? _blankToNull(String? value) {
  final trimmed = value?.trim();
  if (trimmed == null || trimmed.isEmpty) return null;
  return trimmed;
}
