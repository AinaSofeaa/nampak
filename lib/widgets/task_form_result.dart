import '../models/task.dart';

class TaskFormResult {
  final String title;
  final String? notes;
  final int? estimatedMinutes;
  final String color;
  final String icon;
  final String? tag;
  final TaskStatus status;

  const TaskFormResult({
    required this.title,
    required this.notes,
    required this.estimatedMinutes,
    required this.color,
    required this.icon,
    required this.tag,
    required this.status,
  });
}
