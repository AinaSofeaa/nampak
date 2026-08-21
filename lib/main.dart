import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app.dart';
import 'theme/nampak_theme.dart';

const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
const supabaseKey = String.fromEnvironment('SUPABASE_KEY');

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (supabaseUrl.isEmpty || supabaseKey.isEmpty) {
    runApp(const MissingSupabaseConfigApp());
    return;
  }

  await Supabase.initialize(url: supabaseUrl, publishableKey: supabaseKey);
  runApp(const NampakApp());
}

class MissingSupabaseConfigApp extends StatelessWidget {
  const MissingSupabaseConfigApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nampak',
      debugShowCheckedModeBanner: false,
      theme: buildNampakTheme(),
      home: const Scaffold(
        body: CenteredAppCanvas(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Nampak',
                  style: TextStyle(fontSize: 34, fontWeight: FontWeight.w800),
                ),
                SizedBox(height: 12),
                Text(
                  'Supabase is not configured yet.',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
                SizedBox(height: 8),
                Text(
                  'Run Flutter with SUPABASE_URL and SUPABASE_KEY dart defines.',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
