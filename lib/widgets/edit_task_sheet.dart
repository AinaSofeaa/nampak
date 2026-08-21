import 'package:flutter/material.dart';

import '../models/task.dart';
import '../services/app_exception.dart';
import '../theme/nampak_theme.dart';
import 'task_form_result.dart';

class EditTaskSheet extends StatefulWidget {
  final Task task;
  final Future<void> Function(TaskFormResult result) onSubmit;

  const EditTaskSheet({super.key, required this.task, required this.onSubmit});

  @override
  State<EditTaskSheet> createState() => _EditTaskSheetState();
}

class _EditTaskSheetState extends State<EditTaskSheet> {
  late final TextEditingController _titleController;
  late final TextEditingController _notesController;
  late final TextEditingController _minutesController;
  late final TextEditingController _iconController;
  late final TextEditingController _tagController;
  late TaskStatus _destination;
  late String _color;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task.title);
    _notesController = TextEditingController(text: widget.task.notes ?? '');
    _minutesController = TextEditingController(
      text: widget.task.estimatedMinutes?.toString() ?? '',
    );
    _iconController = TextEditingController(text: widget.task.icon);
    _tagController = TextEditingController(text: widget.task.tag ?? '');
    _destination = widget.task.status == TaskStatus.done
        ? TaskStatus.dump
        : widget.task.status;
    _color = widget.task.color;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    _minutesController.dispose();
    _iconController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          22,
          22,
          22,
          MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Edit sticky note',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 18),
            TextField(
              controller: _titleController,
              autofocus: true,
              decoration: const InputDecoration(hintText: 'Title'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _notesController,
              minLines: 2,
              maxLines: 4,
              decoration: const InputDecoration(hintText: 'Notes'),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _minutesController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(hintText: 'Minutes'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _iconController,
                    decoration: const InputDecoration(hintText: 'Icon text'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _tagController,
              decoration: const InputDecoration(hintText: 'Tag'),
            ),
            const SizedBox(height: 16),
            SegmentedButton<TaskStatus>(
              segments: const [
                ButtonSegment(value: TaskStatus.dump, label: Text('Dump')),
                ButtonSegment(value: TaskStatus.now, label: Text('Now')),
              ],
              selected: {_destination},
              onSelectionChanged: (value) {
                setState(() => _destination = value.first);
              },
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final color in stickyColors)
                  Tooltip(
                    message: color.label,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () => setState(() => _color = color.name),
                      child: Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: color.background,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: _color == color.name
                                ? nampakPrimary
                                : color.border,
                            width: _color == color.name ? 2.5 : 1,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _isSaving ? null : _save,
                child: Text(_isSaving ? 'Saving...' : 'Save Changes'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    setState(() => _isSaving = true);
    final result = TaskFormResult(
      title: _titleController.text,
      notes: _notesController.text,
      estimatedMinutes: int.tryParse(_minutesController.text),
      color: _color,
      icon: _iconController.text,
      tag: _tagController.text,
      status: _destination,
    );

    try {
      await widget.onSubmit(result);
      if (mounted) Navigator.pop(context);
    } on AppException catch (error) {
      _showMessage(error.message);
    } catch (_) {
      _showMessage('Could not save the sticky note.');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }
}
