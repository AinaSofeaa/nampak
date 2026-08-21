import 'dart:async';

import 'package:flutter/material.dart';

import '../../models/focus_session.dart';
import '../../models/task.dart';
import '../../models/task_step.dart';
import '../../services/app_exception.dart';
import '../../services/focus_service.dart';
import '../../theme/nampak_theme.dart';

class FocusScreen extends StatefulWidget {
  final Task task;
  final int defaultMinutes;
  final String? ambientSound;
  final Future<void> Function(TaskStep step) onToggleStep;
  final VoidCallback onFinished;

  const FocusScreen({
    super.key,
    required this.task,
    required this.defaultMinutes,
    required this.ambientSound,
    required this.onToggleStep,
    required this.onFinished,
  });

  @override
  State<FocusScreen> createState() => _FocusScreenState();
}

class _FocusScreenState extends State<FocusScreen> {
  final _focusService = FocusService();
  Timer? _ticker;
  FocusSession? _session;
  late Duration _intendedDuration;
  late DateTime _runningStartedAt;
  Duration _elapsedBeforeCurrentRun = Duration.zero;
  bool _isPaused = false;
  bool _isEnding = false;

  @override
  void initState() {
    super.initState();
    final minutes = widget.task.estimatedMinutes ?? widget.defaultMinutes;
    _intendedDuration = Duration(minutes: minutes);
    _runningStartedAt = DateTime.now();
    _startSession();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final elapsed = _elapsed;
    final remaining = _intendedDuration - elapsed;
    final displayRemaining = remaining.isNegative ? Duration.zero : remaining;

    return Scaffold(
      body: SafeArea(
        child: CenteredAppCanvas(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  onPressed: _isEnding ? null : _cancelAndClose,
                  tooltip: 'Close focus',
                  icon: const Icon(Icons.close_rounded),
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: Text(
                  widget.task.icon,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                widget.task.title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Just this one.',
                textAlign: TextAlign.center,
                style: TextStyle(color: nampakMutedText),
              ),
              const SizedBox(height: 46),
              Text(
                _formatDuration(displayRemaining),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 58,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 28),
              if (widget.task.steps.isNotEmpty) ...[
                for (final step in widget.task.steps)
                  CheckboxListTile(
                    value: step.isCompleted,
                    onChanged: (_) => widget.onToggleStep(step),
                    title: Text(step.title),
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                  ),
                const SizedBox(height: 16),
              ],
              FilledButton(
                onPressed: _isEnding ? null : _togglePause,
                child: Text(_isPaused ? 'Resume' : 'Pause'),
              ),
              const SizedBox(height: 10),
              OutlinedButton(
                onPressed: _isEnding
                    ? null
                    : () {
                        setState(() {
                          _intendedDuration += const Duration(minutes: 5);
                        });
                      },
                child: const Text('+5 min'),
              ),
              const SizedBox(height: 10),
              OutlinedButton(
                onPressed: _isEnding ? null : () => _finish(cancelled: false),
                child: Text(_isEnding ? 'Saving...' : 'End Focus'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Duration get _elapsed {
    if (_isPaused) return _elapsedBeforeCurrentRun;
    return _elapsedBeforeCurrentRun +
        DateTime.now().difference(_runningStartedAt);
  }

  Future<void> _startSession() async {
    try {
      final session = await _focusService.startSession(
        taskId: widget.task.id,
        ambientSound: widget.ambientSound,
      );
      if (mounted) setState(() => _session = session);
    } on AppException catch (error) {
      _showMessage(error.message);
      if (mounted) Navigator.pop(context);
    }
  }

  void _togglePause() {
    setState(() {
      if (_isPaused) {
        _runningStartedAt = DateTime.now();
        _isPaused = false;
      } else {
        _elapsedBeforeCurrentRun = _elapsed;
        _isPaused = true;
      }
    });
  }

  Future<void> _cancelAndClose() async {
    await _finish(cancelled: true);
  }

  Future<void> _finish({required bool cancelled}) async {
    if (_isEnding) return;
    setState(() => _isEnding = true);

    final session = _session;
    try {
      if (session != null) {
        await _focusService.finishSession(
          session: session,
          focusSeconds: _elapsed.inSeconds,
          cancelled: cancelled,
        );
      }
      widget.onFinished();
      if (mounted) Navigator.pop(context);
    } on AppException catch (error) {
      _showMessage(error.message);
      if (mounted) setState(() => _isEnding = false);
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }
}

String _formatDuration(Duration duration) {
  final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
  final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
  final hours = duration.inHours;
  if (hours > 0) {
    return '$hours:$minutes:$seconds';
  }
  return '$minutes:$seconds';
}
