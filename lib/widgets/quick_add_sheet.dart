import 'package:flutter/material.dart';

import '../models/task.dart';
import '../services/app_exception.dart';
import '../services/preference_service.dart';
import '../theme/nampak_theme.dart';
import 'task_form_result.dart';

class QuickAddSheet extends StatefulWidget {
  final UserPreferences preferences;
  final Future<void> Function(TaskFormResult result) onSubmit;
  final TaskStatus initialDestination;

  const QuickAddSheet({
    super.key,
    required this.preferences,
    required this.onSubmit,
    this.initialDestination = TaskStatus.dump,
  });

  @override
  State<QuickAddSheet> createState() => _QuickAddSheetState();
}

class _QuickAddSheetState extends State<QuickAddSheet> {
  final _titleController = TextEditingController();
  final _notesController = TextEditingController();
  final _minutesController = TextEditingController();
  final _iconController = TextEditingController(text: 'pin');
  final _tagController = TextEditingController();

  late TaskStatus _destination = widget.initialDestination;
  late String _color = widget.preferences.defaultColor;
  bool _isSaving = false;

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
              'Add something',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 18),
            TextField(
              controller: _titleController,
              autofocus: true,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                hintText: 'What needs to be done?',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _notesController,
              minLines: 2,
              maxLines: 4,
              decoration: const InputDecoration(hintText: 'Optional note'),
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
            _ColorPicker(
              selectedColor: _color,
              onChanged: (value) => setState(() => _color = value),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _isSaving ? null : _save,
                child: Text(_isSaving ? 'Adding...' : 'Add Task'),
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

class _ColorPicker extends StatelessWidget {
  final String selectedColor;
  final ValueChanged<String> onChanged;

  const _ColorPicker({required this.selectedColor, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final color in stickyColors)
          Tooltip(
            message: color.label,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => onChanged(color.name),
              child: Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: color.background,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: selectedColor == color.name
                        ? nampakPrimary
                        : color.border,
                    width: selectedColor == color.name ? 2.5 : 1,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
