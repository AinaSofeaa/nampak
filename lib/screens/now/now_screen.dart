import 'package:flutter/material.dart';

import '../../models/task.dart';
import '../../models/task_step.dart';
import '../../theme/nampak_theme.dart';
import '../../widgets/empty_sticky_slot.dart';
import '../../widgets/sticky_note_card.dart';

class NowScreen extends StatelessWidget {
  final List<Task> tasks;
  final VoidCallback onAdd;
  final void Function(Task task) onStartFocus;
  final void Function(Task task) onMarkDone;
  final void Function(Task task) onEdit;
  final void Function(Task task) onDelete;
  final void Function(Task task) onMoveToDump;
  final Future<void> Function(Task task, String title) onAddStep;
  final Future<void> Function(TaskStep step) onToggleStep;
  final Future<void> Function(TaskStep step) onDeleteStep;

  const NowScreen({
    super.key,
    required this.tasks,
    required this.onAdd,
    required this.onStartFocus,
    required this.onMarkDone,
    required this.onEdit,
    required this.onDelete,
    required this.onMoveToDump,
    required this.onAddStep,
    required this.onToggleStep,
    required this.onDeleteStep,
  });

  @override
  Widget build(BuildContext context) {
    final sorted = [...tasks]
      ..sort((a, b) {
        return (a.nowPosition ?? 99).compareTo(b.nowPosition ?? 99);
      });

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(22, 12, 22, 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'What needs your eyes right now?',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 18),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF3D6),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.visibility_outlined,
                  size: 20,
                  color: nampakPrimary,
                ),
                const SizedBox(width: 8),
                Text(
                  '${sorted.length}/3 Focus Slots Active',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          if (sorted.isEmpty) ...[
            const Text(
              'Your desk is clear.\nPick something from Brain Dump when you are ready.',
              style: TextStyle(color: nampakMutedText, height: 1.4),
            ),
            const SizedBox(height: 18),
          ],
          for (final task in sorted) ...[
            StickyNoteCard(
              task: task,
              onStartFocus: () => onStartFocus(task),
              onMarkDone: () => onMarkDone(task),
              onEdit: () => onEdit(task),
              onDelete: () => onDelete(task),
              onMoveToDump: () => onMoveToDump(task),
              onAddStep: (title) => onAddStep(task, title),
              onToggleStep: onToggleStep,
              onDeleteStep: onDeleteStep,
            ),
            const SizedBox(height: 14),
          ],
          for (var i = sorted.length; i < 3; i++) ...[
            EmptyStickySlot(onTap: onAdd),
            const SizedBox(height: 14),
          ],
          const SizedBox(height: 14),
          const Text(
            'Only three things deserve your attention at once.',
            style: TextStyle(fontSize: 13, color: nampakMutedText),
          ),
        ],
      ),
    );
  }
}
