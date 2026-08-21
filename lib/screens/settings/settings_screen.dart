import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../services/preference_service.dart';
import '../../theme/nampak_theme.dart';

class SettingsScreen extends StatefulWidget {
  final User user;
  final UserPreferences preferences;
  final Future<void> Function(UserPreferences preferences) onSave;
  final Future<void> Function() onSignOut;

  const SettingsScreen({
    super.key,
    required this.user,
    required this.preferences,
    required this.onSave,
    required this.onSignOut,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late UserPreferences _preferences = widget.preferences;
  bool _isSaving = false;

  @override
  void didUpdateWidget(covariant SettingsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.preferences != widget.preferences) {
      _preferences = widget.preferences;
    }
  }

  @override
  Widget build(BuildContext context) {
    final displayName =
        widget.user.userMetadata?['full_name']?.toString() ?? widget.user.email;

    return ListView(
      padding: const EdgeInsets.fromLTRB(22, 16, 22, 120),
      children: [
        const Text(
          'Settings',
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 18),
        _SettingsPanel(
          children: [
            Text(
              displayName ?? 'Signed in',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 4),
            Text(
              widget.user.email ?? '',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: nampakMutedText),
            ),
          ],
        ),
        const SizedBox(height: 14),
        _SettingsPanel(
          children: [
            const Text(
              'Default focus minutes',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            Slider(
              value: _preferences.defaultFocusMinutes.toDouble(),
              min: 5,
              max: 60,
              divisions: 11,
              label: '${_preferences.defaultFocusMinutes} min',
              onChanged: (value) {
                setState(() {
                  _preferences = _preferences.copyWith(
                    defaultFocusMinutes: value.round(),
                  );
                });
                _save();
              },
            ),
            Text('${_preferences.defaultFocusMinutes} minutes'),
            const SizedBox(height: 14),
            const Text(
              'Default sticky color',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final color in stickyColors)
                  Tooltip(
                    message: color.label,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () {
                        setState(() {
                          _preferences = _preferences.copyWith(
                            defaultColor: color.name,
                          );
                        });
                        _save();
                      },
                      child: Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: color.background,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: _preferences.defaultColor == color.name
                                ? nampakPrimary
                                : color.border,
                            width: _preferences.defaultColor == color.name
                                ? 2.5
                                : 1,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 14),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Sound'),
              value: _preferences.soundEnabled,
              onChanged: (value) {
                setState(() {
                  _preferences = _preferences.copyWith(soundEnabled: value);
                });
                _save();
              },
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Reduced motion'),
              value: _preferences.reducedMotion,
              onChanged: (value) {
                setState(() {
                  _preferences = _preferences.copyWith(reducedMotion: value);
                });
                _save();
              },
            ),
            if (_isSaving)
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text(
                  'Saving...',
                  style: TextStyle(color: nampakMutedText),
                ),
              ),
          ],
        ),
        const SizedBox(height: 18),
        OutlinedButton.icon(
          onPressed: widget.onSignOut,
          icon: const Icon(Icons.logout_rounded),
          label: const Text('Sign Out'),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(50),
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _save() async {
    setState(() => _isSaving = true);
    try {
      await widget.onSave(_preferences);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }
}

class _SettingsPanel extends StatelessWidget {
  final List<Widget> children;

  const _SettingsPanel({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE8E3D8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }
}
