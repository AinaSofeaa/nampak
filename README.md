# Nampak

Nampak is a calm, mobile-first productivity app inspired by physical sticky notes.

## Supabase configuration

The Flutter app reads Supabase configuration from Dart environment variables:

- `SUPABASE_URL`
- `SUPABASE_KEY`

Use only your Supabase public publishable or anon key. Do not put a service role key or database password in Flutter code.

PowerShell one-line run command:

```powershell
flutter run -d chrome --dart-define=SUPABASE_URL="https://YOUR_PROJECT.supabase.co" --dart-define=SUPABASE_KEY="YOUR_PUBLIC_ANON_OR_PUBLISHABLE_KEY"
```

Production web build:

```powershell
flutter build web --dart-define=SUPABASE_URL="https://YOUR_PROJECT.supabase.co" --dart-define=SUPABASE_KEY="YOUR_PUBLIC_ANON_OR_PUBLISHABLE_KEY"
```

## Supabase tables used

Nampak uses the existing tables only:

- `profiles`
- `tasks`
- `task_steps`
- `focus_sessions`
- `user_preferences`

No migrations or table changes are included in this app.

## Demo accounts

The login screen includes two public demo account fillers:

```text
Aina
aina.demo@example.com
NampakDemo123!

Syed
syed.demo@example.com
NampakDemo123!
```

Create these users in Supabase Auth before using the demo buttons. The buttons fill the email and password fields; the user still presses Sign In.
