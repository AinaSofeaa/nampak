import 'package:flutter/material.dart';

import '../../models/task.dart';
import '../../models/task_step.dart';
import '../../theme/nampak_theme.dart';
import '../../widgets/sticky_note_card.dart';

enum DumpFilter { all, quick, deep, hasSteps }

class DumpScreen extends StatefulWidget {
  final List<Task> tasks;
  final Future<void> Function(String title) onQuickDump;
  final void Function(Task task) onMoveToNow;
  final void Function(Task task) onMarkDone;
  final void Function(Task task) onEdit;
  final void Function(Task task) onDelete;
  final Future<void> Function(Task task, String title) onAddStep;
  final Future<void> Function(TaskStep step) onToggleStep;
  final Future<void> Function(TaskStep step) onDeleteStep;

  const DumpScreen({
    super.key,
    required this.tasks,
    required this.onQuickDump,
    required this.onMoveToNow,
    required this.onMarkDone,
    required this.onEdit,
    required this.onDelete,
    required this.onAddStep,
    required this.onToggleStep,
    required this.onDeleteStep,
  });

  @override
  State<DumpScreen> createState() => _DumpScreenState();
}

class _DumpScreenState extends State<DumpScreen> {
  final _quickController = TextEditingController();
  final _searchController = TextEditingController();
  DumpFilter _filter = DumpFilter.all;

  @override
  void dispose() {
    _quickController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = widget.tasks.where(_matchesFilter).toList();

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(22, 16, 22, 120),
            children: [
              const Text(
                'Brain Dump',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 6),
              const Text(
                'Get it out of your head. Organise later.',
                style: TextStyle(color: nampakMutedText),
              ),
              const SizedBox(height: 22),
              TextField(
                controller: _quickController,
                textInputAction: TextInputAction.done,
                onSubmitted: _submitQuickDump,
                decoration: const InputDecoration(
                  hintText: 'Type anything...',
                  prefixIcon: Icon(Icons.add_circle_outline),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _searchController,
                onChanged: (_) => setState(() {}),
                decoration: const InputDecoration(
                  hintText: 'Search',
                  prefixIcon: Icon(Icons.search_rounded),
                ),
              ),
              const SizedBox(height: 12),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SegmentedButton<DumpFilter>(
                  segments: const [
                    ButtonSegment(value: DumpFilter.all, label: Text('All')),
                    ButtonSegment(
                      value: DumpFilter.quick,
                      label: Text('Quick <=15m'),
                    ),
                    ButtonSegment(
                      value: DumpFilter.deep,
                      label: Text('Deep >=25m'),
                    ),
                    ButtonSegment(
                      value: DumpFilter.hasSteps,
                      label: Text('Has Steps'),
                    ),
                  ],
                  selected: {_filter},
                  onSelectionChanged: (value) {
                    setState(() => _filter = value.first);
                  },
                ),
              ),
              const SizedBox(height: 18),
              if (filtered.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(top: 40),
                  child: Center(
                    child: Text(
                      'Nothing floating around.\nAdd anything that comes to mind.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: nampakMutedText, height: 1.4),
                    ),
                  ),
                ),
              for (final task in filtered) ...[
                StickyNoteCard(
                  task: task,
                  onMoveToNow: () => widget.onMoveToNow(task),
                  onMarkDone: () => widget.onMarkDone(task),
                  onEdit: () => widget.onEdit(task),
                  onDelete: () => widget.onDelete(task),
                  onAddStep: (title) => widget.onAddStep(task, title),
                  onToggleStep: widget.onToggleStep,
                  onDeleteStep: widget.onDeleteStep,
                ),
                const SizedBox(height: 14),
              ],
            ],
          ),
        ),
      ],
    );
  }

  bool _matchesFilter(Task task) {
    final search = _searchController.text.trim().toLowerCase();
    final matchesSearch =
        search.isEmpty ||
        task.title.toLowerCase().contains(search) ||
        (task.notes ?? '').toLowerCase().contains(search) ||
        (task.tag ?? '').toLowerCase().contains(search);

    if (!matchesSearch) return false;

    return switch (_filter) {
      DumpFilter.all => true,
      DumpFilter.quick => (task.estimatedMinutes ?? 9999) <= 15,
      DumpFilter.deep => (task.estimatedMinutes ?? 0) >= 25,
      DumpFilter.hasSteps => task.steps.isNotEmpty,
    };
  }

  Future<void> _submitQuickDump(String value) async {
    if (value.trim().isEmpty) return;
    await widget.onQuickDump(value);
    _quickController.clear();
  }
}
