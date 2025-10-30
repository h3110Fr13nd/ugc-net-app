import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import '../ui/ui.dart';
import '../services/auth_service.dart';
import '../models/app_state.dart';
import 'registration_page.dart';

class AuthenticationPage extends StatefulWidget {
  const AuthenticationPage({super.key});

  @override
  State<AuthenticationPage> createState() => _AuthenticationPageState();
}

class _AuthenticationPageState extends State<AuthenticationPage> {
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _navigateToHome() {
    Navigator.of(context).pushReplacementNamed('/home');
  }

  Future<void> _login() async {
    final scaffold = ScaffoldMessenger.of(context);
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      scaffold.showSnackBar(
        const SnackBar(content: Text('Please enter email and password')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final appState = context.read<MyAppState>();
      final auth = AuthService();
      final res = await auth.login(_emailController.text, _passwordController.text);

      if (res.containsKey('access_token')) {
        final token = res['access_token'] as String;
        final user = res['user'] as Map<String, dynamic>?;
        await appState.setAuth(token, user ?? {});
        scaffold.showSnackBar(const SnackBar(content: Text('Signed in successfully')));
        _navigateToHome();
      } else {
        final detail = res['detail'] ?? 'Sign-in failed';
        scaffold.showSnackBar(SnackBar(content: Text('Error: $detail')));
      }
    } catch (e) {
      scaffold.showSnackBar(SnackBar(content: Text('Sign-in exception: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _googleSignIn() async {
    setState(() => _isLoading = true);
    final scaffold = ScaffoldMessenger.of(context);
    final appState = context.read<MyAppState>();
    scaffold.showSnackBar(const SnackBar(content: Text('Starting Google sign in...')));
    final auth = AuthService();
    
    try {
      final res = await auth.signInWithGoogle();
      
      if (res.containsKey('access_token')) {
        final token = res['access_token'] as String;
        final user = res['user'] as Map<String, dynamic>?;
        await appState.setAuth(token, user ?? {});
        scaffold.showSnackBar(const SnackBar(content: Text('Signed in successfully')));
        _navigateToHome();
      } else if (res['error'] == 'sign_in_cancelled') {
        scaffold.showSnackBar(const SnackBar(content: Text('Sign-in cancelled')));
      } else {
        final error = res['error'] ?? 'unknown';
        final message = res['message'] ?? res['detail'] ?? json.encode(res);
        scaffold.showSnackBar(SnackBar(content: Text('Sign-in failed: $error - $message')));
      }
    } catch (e) {
      scaffold.showSnackBar(SnackBar(content: Text('Sign-in exception: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign In'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 32),
              const Text(
                'Welcome to UGC Net App',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Email / Password Sign In', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _emailController,
                        enabled: !_isLoading,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _passwordController,
                        enabled: !_isLoading,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'Password',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: PrimaryButton(
                              onPressed: _isLoading ? null : _login,
                              child: _isLoading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                      ),
                                    )
                                  : const Text('Sign In'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton(
                              onPressed: _isLoading
                                  ? null
                                  : () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(builder: (_) => const RegistrationPage()),
                                      );
                                    },
                              child: const Text('Register'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 24),
              PrimaryButton(
                onPressed: _isLoading ? null : _googleSignIn,
                child: const Text('Sign in with Google'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
