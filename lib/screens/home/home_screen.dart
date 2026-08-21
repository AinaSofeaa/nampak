import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../models/task.dart';
import '../../models/task_step.dart';
import '../../screens/done/done_screen.dart';
import '../../screens/dump/dump_screen.dart';
import '../../screens/focus/focus_screen.dart';
import '../../screens/now/now_screen.dart';
import '../../screens/settings/settings_screen.dart';
import '../../services/app_exception.dart';
import '../../services/auth_service.dart';
import '../../services/focus_service.dart';
import '../../services/preference_service.dart';
import '../../services/task_service.dart';
import '../../theme/nampak_theme.dart';
import '../../widgets/bottom_nav.dart';
import '../../widgets/edit_task_sheet.dart';
import '../../widgets/nampak_header.dart';
import '../../widgets/quick_add_sheet.dart';
import '../../widgets/task_form_result.dart';

class HomeScreen extends StatefulWidget {
  final User user;

  const HomeScreen({super.key, required this.user});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _authService = AuthService();
  final _taskService = TaskService();
  final _focusService = FocusService();
  final _preferenceService = PreferenceService();

  int _selectedIndex = 0;
  bool _isLoading = true;
  List<Task> _tasks = [];
  UserPreferences _preferences = const UserPreferences();
  int _focusSecondsToday = 0;
  RealtimeChannel? _taskChannel;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
    _taskChannel = _taskService.subscribeToTaskChanges(onChange: _refreshData);
  }

  @override
  void dispose() {
    final channel = _taskChannel;
    if (channel != null) {
      _taskService.removeSubscription(channel);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final nowTasks = _tasks
        .where((task) => task.status == TaskStatus.now)
        .toList();
    final dumpTasks = _tasks
        .where((task) => task.status == TaskStatus.dump)
        .toList();
    final doneTasks = _tasks
        .where((task) => task.status == TaskStatus.done)
        .toList();

    return Scaffold(
      body: SafeArea(
        child: CenteredAppCanvas(
          child: Stack(
            children: [
              Column(
                children: [
                  NampakHeader(
                    soundEnabled: _preferences.soundEnabled,
                    onSoundPressed: () {
                      _savePreferences(
                        _preferences.copyWith(
                          soundEnabled: !_preferences.soundEnabled,
                        ),
                      );
                    },
                  ),
                  Expanded(
                    child: _isLoading
                        ? const Center(child: Text('Setting the desk...'))
                        : IndexedStack(
                            index: _selectedIndex,
                            children: [
                              NowScreen(
                                tasks: nowTasks,
                                onAdd: () => _openQuickAdd(TaskStatus.now),
                                onStartFocus: _openFocus,
                                onMarkDone: _markDone,
                                onEdit: _openEdit,
                                onDelete: _deleteTask,
                                onMoveToDump: _moveToDump,
                                onAddStep: _addStep,
                                onToggleStep: _toggleStep,
                                onDeleteStep: _deleteStep,
                              ),
                              DumpScreen(
                                tasks: dumpTasks,
                                onQuickDump: _quickDump,
                                onMoveToNow: _moveToNow,
                                onMarkDone: _markDone,
                                onEdit: _openEdit,
                                onDelete: _deleteTask,
                                onAddStep: _addStep,
                                onToggleStep: _toggleStep,
                                onDeleteStep: _deleteStep,
                              ),
                              DoneScreen(
                                tasks: doneTasks,
                                focusSecondsToday: _focusSecondsToday,
                                onRestore: _restoreTask,
                              ),
                              SettingsScreen(
                                user: widget.user,
                                preferences: _preferences,
                                onSave: _savePreferences,
                                onSignOut: _signOut,
                              ),
                            ],
                          ),
                  ),
                ],
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: BottomNav(
                  selectedIndex: _selectedIndex,
                  onChanged: (index) => setState(() => _selectedIndex = index),
                ),
              ),
              Positioned(
                bottom: 36,
                left: 0,
                right: 0,
                child: Center(
                  child: FloatingActionButton(
                    onPressed: _isLoading
                        ? null
                        : () => _openQuickAdd(TaskStatus.dump),
                    backgroundColor: nampakPrimary,
                    foregroundColor: Colors.white,
                    elevation: 4,
                    child: const Icon(Icons.add_rounded, size: 30),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _loadInitialData() async {
    setState(() => _isLoading = true);
    await _loadData(showLoading: false);
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _refreshData() async {
    await _loadData(showLoading: false);
  }

  Future<void> _loadData({required bool showLoading}) async {
    if (showLoading && mounted) setState(() => _isLoading = true);
    try {
      final results = await Future.wait([
        _taskService.fetchTasks(),
        _preferenceService.fetchPreferences(),
        _focusService.todaysCompletedFocusSeconds(),
      ]);

      if (!mounted) return;
      setState(() {
        _tasks = results[0] as List<Task>;
        _preferences = results[1] as UserPreferences;
        _focusSecondsToday = results[2] as int;
      });
    } on AppException catch (error) {
      _showMessage(error.message);
    } finally {
      if (showLoading && mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _openQuickAdd(TaskStatus destination) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return _BottomSheetFrame(
          child: QuickAddSheet(
            preferences: _preferences,
            initialDestination: destination,
            onSubmit: (result) async {
              await _taskService.createTask(
                title: result.title,
                notes: result.notes,
                estimatedMinutes: result.estimatedMinutes,
                color: result.color,
                icon: result.icon,
                tag: result.tag,
                status: result.status,
              );
              await _refreshData();
            },
          ),
        );
      },
    );
  }

  Future<void> _openEdit(Task task) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return _BottomSheetFrame(
          child: EditTaskSheet(
            task: task,
            onSubmit: (result) async {
              final updated = _taskFromForm(task, result);
              await _taskService.updateTask(updated);
              await _refreshData();
            },
          ),
        );
      },
    );
  }

  Future<void> _quickDump(String title) async {
    await _runTaskAction(() async {
      await _taskService.createTask(
        title: title,
        color: _preferences.defaultColor,
        icon: 'pin',
        status: TaskStatus.dump,
      );
      await _refreshData();
    });
  }

  Future<void> _moveToNow(Task task) async {
    await _runTaskAction(() async {
      await _taskService.moveToNow(task);
      await _refreshData();
    });
  }

  Future<void> _moveToDump(Task task) async {
    await _runTaskAction(() async {
      await _taskService.moveToDump(task);
      await _refreshData();
    });
  }

  Future<void> _markDone(Task task) async {
    await _runTaskAction(() async {
      await _taskService.markDone(task);
      await _refreshData();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Cleared.'),
          action: SnackBarAction(
            label: 'Undo',
            onPressed: () => _restoreTask(task),
          ),
        ),
      );
    });
  }

  Future<void> _restoreTask(Task task) async {
    await _runTaskAction(() async {
      await _taskService.restoreToDump(task);
      await _refreshData();
    });
  }

  Future<void> _deleteTask(Task task) async {
    await _runTaskAction(() async {
      await _taskService.deleteTask(task);
      await _refreshData();
    });
  }

  Future<void> _addStep(Task task, String title) async {
    await _runTaskAction(() async {
      await _taskService.addStep(task, title);
      await _refreshData();
    });
  }

  Future<void> _toggleStep(TaskStep step) async {
    await _runTaskAction(() async {
      await _taskService.toggleStep(step);
      await _refreshData();
    });
  }

  Future<void> _deleteStep(TaskStep step) async {
    await _runTaskAction(() async {
      await _taskService.deleteStep(step);
      await _refreshData();
    });
  }

  Future<void> _savePreferences(UserPreferences preferences) async {
    await _runTaskAction(() async {
      final saved = await _preferenceService.savePreferences(preferences);
      if (mounted) setState(() => _preferences = saved);
    });
  }

  Future<void> _signOut() async {
    await _runTaskAction(_authService.signOut);
  }

  Future<void> _openFocus(Task task) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) {
          return FocusScreen(
            task: task,
            defaultMinutes: _preferences.defaultFocusMinutes,
            ambientSound: _preferences.defaultAmbientSound,
            onToggleStep: _toggleStep,
            onFinished: _refreshData,
          );
        },
      ),
    );
  }

  Future<void> _runTaskAction(Future<void> Function() action) async {
    try {
      await action();
    } on AppException catch (error) {
      _showMessage(error.message);
    }
  }

  Task _taskFromForm(Task task, TaskFormResult result) {
    return Task(
      id: task.id,
      userId: task.userId,
      title: result.title,
      notes: result.notes,
      estimatedMinutes: result.estimatedMinutes,
      color: result.color,
      icon: result.icon,
      tag: result.tag,
      status: result.status,
      nowPosition: task.status == result.status ? task.nowPosition : null,
      createdAt: task.createdAt,
      updatedAt: task.updatedAt,
      completedAt: task.completedAt,
      steps: task.steps,
    );
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }
}

class _BottomSheetFrame extends StatelessWidget {
  final Widget child;

  const _BottomSheetFrame({required this.child});

  @override
  Widget build(BuildContext context) {
    return CenteredSheetCanvas(
      child: DecoratedBox(
        decoration: const BoxDecoration(
          color: nampakBackground,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: child,
      ),
    );
  }
}
