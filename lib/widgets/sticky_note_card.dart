import 'package:flutter/material.dart';

import '../models/task.dart';
import '../models/task_step.dart';
import '../theme/nampak_theme.dart';

class StickyNoteCard extends StatelessWidget {
  final Task task;
  final bool compact;
  final VoidCallback? onStartFocus;
  final VoidCallback? onMarkDone;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onMoveToNow;
  final VoidCallback? onMoveToDump;
  final VoidCallback? onRestore;
  final Future<void> Function(String title)? onAddStep;
  final Future<void> Function(TaskStep step)? onToggleStep;
  final Future<void> Function(TaskStep step)? onDeleteStep;

  const StickyNoteCard({
    super.key,
    required this.task,
    this.compact = false,
    this.onStartFocus,
    this.onMarkDone,
    this.onEdit,
    this.onDelete,
    this.onMoveToNow,
    this.onMoveToDump,
    this.onRestore,
    this.onAddStep,
    this.onToggleStep,
    this.onDeleteStep,
  });

  @override
  Widget build(BuildContext context) {
    final stickyColor = stickyColorFor(task.color);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: stickyColor.background,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: stickyColor.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _IconChip(icon: task.icon),
              const Spacer(),
              if (task.estimatedMinutes != null)
                _Pill(text: '${task.estimatedMinutes} min'),
              if (task.tag != null && task.tag!.isNotEmpty) ...[
                const SizedBox(width: 6),
                Flexible(child: _Pill(text: task.tag!)),
              ],
            ],
          ),
          const SizedBox(height: 12),
          Text(
            task.title,
            maxLines: compact ? 3 : null,
            overflow: compact ? TextOverflow.ellipsis : null,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
          ),
          if (task.notes != null && task.notes!.trim().isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              task.notes!,
              maxLines: compact ? 3 : null,
              overflow: compact ? TextOverflow.ellipsis : null,
              style: const TextStyle(
                fontSize: 13,
                height: 1.4,
                color: Color(0xFF666666),
              ),
            ),
          ],
          if (task.steps.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              '${task.completedStepCount}/${task.steps.length} tiny steps',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: nampakMutedText,
              ),
            ),
            const SizedBox(height: 6),
            for (final step in compact ? task.steps.take(2) : task.steps)
              _StepRow(
                step: step,
                onToggle: onToggleStep == null
                    ? null
                    : () => onToggleStep!(step),
                onDelete: onDeleteStep == null
                    ? null
                    : () => onDeleteStep!(step),
              ),
          ],
          if (!compact && onAddStep != null) ...[
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: () => _showAddStepDialog(context),
                icon: const Icon(Icons.add_rounded),
                label: const Text('Add tiny step'),
              ),
            ),
          ],
          if (!compact) ...[
            const SizedBox(height: 12),
            _ActionWrap(
              task: task,
              onStartFocus: onStartFocus,
              onMarkDone: onMarkDone,
              onEdit: onEdit,
              onDelete: onDelete,
              onMoveToNow: onMoveToNow,
              onMoveToDump: onMoveToDump,
              onRestore: onRestore,
              onCalmMode: () => _showCalmMode(context),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _showAddStepDialog(BuildContext context) async {
    final controller = TextEditingController();
    final title = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add one tiny step'),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(hintText: 'Tiny step'),
            onSubmitted: (value) => Navigator.pop(context, value),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, controller.text),
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
    controller.dispose();

    if (title != null) {
      await onAddStep?.call(title);
    }
  }

  Future<void> _showCalmMode(BuildContext context) async {
    final unfinished = task.firstUnfinishedStep;
    if (unfinished == null) {
      await _showAddStepDialog(context);
      return;
    }

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return CenteredSheetCanvas(
          child: DecoratedBox(
            decoration: const BoxDecoration(
              color: nampakBackground,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: SafeArea(
              top: false,
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Not the whole task.',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text('Just this:'),
                    const SizedBox(height: 18),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Text(
                        unfinished.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: () async {
                          await onToggleStep?.call(unfinished);
                          if (context.mounted) Navigator.pop(context);
                        },
                        child: const Text('Done'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _IconChip extends StatelessWidget {
  final String icon;

  const _IconChip({required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(
        minWidth: 40,
        minHeight: 36,
        maxWidth: 96,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        icon.trim().isEmpty ? 'pin' : icon.trim(),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontWeight: FontWeight.w800),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final String text;

  const _Pill({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _StepRow extends StatelessWidget {
  final TaskStep step;
  final VoidCallback? onToggle;
  final VoidCallback? onDelete;

  const _StepRow({required this.step, this.onToggle, this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Checkbox(
          value: step.isCompleted,
          onChanged: onToggle == null ? null : (_) => onToggle!(),
        ),
        Expanded(
          child: Text(
            step.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              decoration: step.isCompleted ? TextDecoration.lineThrough : null,
              color: step.isCompleted ? nampakMutedText : nampakText,
            ),
          ),
        ),
        if (onDelete != null)
          IconButton(
            onPressed: onDelete,
            tooltip: 'Delete step',
            icon: const Icon(Icons.close_rounded, size: 18),
          ),
      ],
    );
  }
}

class _ActionWrap extends StatelessWidget {
  final Task task;
  final VoidCallback? onStartFocus;
  final VoidCallback? onMarkDone;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onMoveToNow;
  final VoidCallback? onMoveToDump;
  final VoidCallback? onRestore;
  final VoidCallback onCalmMode;

  const _ActionWrap({
    required this.task,
    required this.onStartFocus,
    required this.onMarkDone,
    required this.onEdit,
    required this.onDelete,
    required this.onMoveToNow,
    required this.onMoveToDump,
    required this.onRestore,
    required this.onCalmMode,
  });

  @override
  Widget build(BuildContext context) {
    if (task.status == TaskStatus.done) {
      return Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          OutlinedButton.icon(
            onPressed: onRestore,
            icon: const Icon(Icons.restore_rounded),
            label: const Text('Restore'),
          ),
        ],
      );
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        if (task.status == TaskStatus.now)
          FilledButton.icon(
            onPressed: onStartFocus,
            icon: const Icon(Icons.play_arrow_rounded, color: nampakGold),
            label: const Text('Start Focus'),
          ),
        if (task.status == TaskStatus.dump)
          FilledButton.icon(
            onPressed: onMoveToNow,
            icon: const Icon(Icons.north_east_rounded, color: nampakGold),
            label: const Text('Put on Desk'),
          ),
        OutlinedButton.icon(
          onPressed: onMarkDone,
          icon: const Icon(Icons.check_rounded),
          label: const Text('Done'),
        ),
        IconButton.filledTonal(
          onPressed: onCalmMode,
          tooltip: 'Too much',
          icon: const Icon(Icons.visibility_outlined),
        ),
        IconButton.filledTonal(
          onPressed: onEdit,
          tooltip: 'Edit',
          icon: const Icon(Icons.edit_outlined),
        ),
        if (task.status == TaskStatus.now)
          IconButton.filledTonal(
            onPressed: onMoveToDump,
            tooltip: 'Move to Brain Dump',
            icon: const Icon(Icons.inbox_outlined),
          ),
        IconButton.filledTonal(
          onPressed: onDelete,
          tooltip: 'Delete',
          icon: const Icon(Icons.delete_outline_rounded),
        ),
      ],
    );
  }
}
