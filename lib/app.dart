import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'screens/auth/auth_screen.dart';
import 'screens/home/home_screen.dart';
import 'theme/nampak_theme.dart';

class NampakApp extends StatelessWidget {
  const NampakApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nampak',
      debugShowCheckedModeBanner: false,
      theme: buildNampakTheme(),
      home: const AuthGate(),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Supabase.instance.client.auth;

    return StreamBuilder<AuthState>(
      stream: auth.onAuthStateChange,
      builder: (context, snapshot) {
        final session = snapshot.data?.session ?? auth.currentSession;

        if (snapshot.connectionState == ConnectionState.waiting &&
            auth.currentSession == null) {
          return const LoadingDeskScreen();
        }

        if (session == null) {
          return const AuthScreen();
        }

        return HomeScreen(user: session.user);
      },
    );
  }
}

class LoadingDeskScreen extends StatelessWidget {
  const LoadingDeskScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: CenteredAppCanvas(
        child: Center(
          child: Text(
            'Setting the desk...',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
      ),
    );
  }
}
