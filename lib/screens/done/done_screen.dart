import 'package:flutter/material.dart';

import '../../models/task.dart';
import '../../theme/nampak_theme.dart';
import '../../widgets/sticky_note_card.dart';

class DoneScreen extends StatelessWidget {
  final List<Task> tasks;
  final int focusSecondsToday;
  final void Function(Task task) onRestore;

  const DoneScreen({
    super.key,
    required this.tasks,
    required this.focusSecondsToday,
    required this.onRestore,
  });

  @override
  Widget build(BuildContext context) {
    final todayTasks = tasks.where(_completedToday).toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(22, 16, 22, 120),
      children: [
        const Text(
          'Done',
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 18),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFFDCFCE7),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: const Color(0xFFBBF7D0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Today',
                style: TextStyle(fontSize: 14, color: Color(0xFF666666)),
              ),
              const SizedBox(height: 8),
              Text(
                '${todayTasks.length} things cleared',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${(focusSecondsToday / 60).round()} focus minutes',
                style: const TextStyle(color: Color(0xFF666666)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        if (tasks.isEmpty)
          const Padding(
            padding: EdgeInsets.only(top: 40),
            child: Center(
              child: Text(
                'Nothing cleared yet today.',
                style: TextStyle(color: nampakMutedText),
              ),
            ),
          ),
        for (final task in tasks) ...[
          StickyNoteCard(
            task: task,
            compact: true,
            onRestore: () => onRestore(task),
          ),
          const SizedBox(height: 14),
        ],
      ],
    );
  }

  bool _completedToday(Task task) {
    final completedAt = task.completedAt;
    if (completedAt == null) return false;
    final now = DateTime.now();
    final local = completedAt.toLocal();
    return local.year == now.year &&
        local.month == now.month &&
        local.day == now.day;
  }
}
