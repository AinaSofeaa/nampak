import 'package:flutter/material.dart';

import '../../services/app_exception.dart';
import '../../services/auth_service.dart';
import '../../theme/nampak_theme.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  static const _demoPassword = 'NampakDemo123!';
  static const _demoAccounts = [
    _DemoAccount(name: 'Aina', email: 'aina.demo@example.com'),
    _DemoAccount(name: 'Syed', email: 'syed.demo@example.com'),
  ];

  final _authService = AuthService();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isBusy = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: CenteredAppCanvas(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(28, 28, 28, 36),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 36),
                const Text(
                  'Nampak',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 38,
                    fontWeight: FontWeight.w900,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Make work visible again.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: nampakMutedText, fontSize: 16),
                ),
                const SizedBox(height: 44),
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  autofillHints: const [AutofillHints.email],
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(labelText: 'Email'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  autofillHints: const [AutofillHints.password],
                  onSubmitted: (_) => _submitEmail(),
                  decoration: const InputDecoration(labelText: 'Password'),
                ),
                const SizedBox(height: 18),
                FilledButton(
                  onPressed: _isBusy ? null : _submitEmail,
                  child: Text(_isBusy ? 'Signing in...' : 'Sign In'),
                ),
                const SizedBox(height: 30),
                const Row(
                  children: [
                    Expanded(child: Divider()),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        'Demo accounts',
                        style: TextStyle(color: nampakMutedText),
                      ),
                    ),
                    Expanded(child: Divider()),
                  ],
                ),
                const SizedBox(height: 18),
                for (final account in _demoAccounts) ...[
                  OutlinedButton(
                    onPressed: _isBusy ? null : () => _fillDemo(account),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(50),
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(account.name),
                  ),
                  const SizedBox(height: 10),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submitEmail() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      _showMessage('Email and password are required.');
      return;
    }

    setState(() => _isBusy = true);
    try {
      await _authService.signIn(email: email, password: password);
    } on AppException catch (error) {
      _showMessage(error.message);
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  void _fillDemo(_DemoAccount account) {
    setState(() {
      _emailController.text = account.email;
      _passwordController.text = _demoPassword;
    });
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }
}

class _DemoAccount {
  final String name;
  final String email;

  const _DemoAccount({required this.name, required this.email});
}
