import 'package:supabase_flutter/supabase_flutter.dart';

import 'app_exception.dart';

class UserPreferences {
  final bool soundEnabled;
  final int defaultFocusMinutes;
  final String defaultColor;
  final String? defaultAmbientSound;
  final bool reducedMotion;

  const UserPreferences({
    this.soundEnabled = true,
    this.defaultFocusMinutes = 25,
    this.defaultColor = 'butter',
    this.defaultAmbientSound,
    this.reducedMotion = false,
  });

  factory UserPreferences.fromMap(Map<String, dynamic>? map) {
    if (map == null) return const UserPreferences();

    return UserPreferences(
      soundEnabled: (map['sound_enabled'] ?? true) as bool,
      defaultFocusMinutes: (map['default_focus_minutes'] ?? 25) as int,
      defaultColor: (map['default_color'] ?? 'butter').toString(),
      defaultAmbientSound: map['default_ambient_sound'] as String?,
      reducedMotion: (map['reduced_motion'] ?? false) as bool,
    );
  }

  UserPreferences copyWith({
    bool? soundEnabled,
    int? defaultFocusMinutes,
    String? defaultColor,
    String? defaultAmbientSound,
    bool? reducedMotion,
  }) {
    return UserPreferences(
      soundEnabled: soundEnabled ?? this.soundEnabled,
      defaultFocusMinutes: defaultFocusMinutes ?? this.defaultFocusMinutes,
      defaultColor: defaultColor ?? this.defaultColor,
      defaultAmbientSound: defaultAmbientSound ?? this.defaultAmbientSound,
      reducedMotion: reducedMotion ?? this.reducedMotion,
    );
  }

  Map<String, dynamic> toMap(String userId) {
    return {
      'user_id': userId,
      'sound_enabled': soundEnabled,
      'default_focus_minutes': defaultFocusMinutes,
      'default_color': defaultColor,
      'default_ambient_sound': defaultAmbientSound,
      'reduced_motion': reducedMotion,
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    };
  }
}

class PreferenceService {
  final SupabaseClient _client = Supabase.instance.client;

  String get _userId {
    final id = _client.auth.currentUser?.id;
    if (id == null) throw const AppException('Please sign in again.');
    return id;
  }

  Future<UserPreferences> fetchPreferences() async {
    try {
      final row = await _client
          .from('user_preferences')
          .select()
          .eq('user_id', _userId)
          .maybeSingle();

      return UserPreferences.fromMap(row);
    } catch (_) {
      throw const AppException('Could not load settings.');
    }
  }

  Future<UserPreferences> savePreferences(UserPreferences preferences) async {
    try {
      final data = preferences.toMap(_userId);
      data['created_at'] = DateTime.now().toUtc().toIso8601String();

      final row = await _client
          .from('user_preferences')
          .upsert(data, onConflict: 'user_id')
          .select()
          .single();

      return UserPreferences.fromMap(row);
    } catch (_) {
      throw const AppException('Could not save settings.');
    }
  }
}
