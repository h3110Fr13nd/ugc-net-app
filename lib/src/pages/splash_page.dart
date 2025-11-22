import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/api_client.dart';
import '../models/app_state.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  String _status = 'Checking backend...';

  @override
  void initState() {
    super.initState();
    _checkHealth();
  }

  Future<void> _checkHealth() async {
    final client = ApiClient();
    final appState = context.read<MyAppState>();
    try {
      final res = await client.get('/health');
      if (res.statusCode == 200) {
        // Try silent refresh if not signed in
        if (!appState.isSignedIn) {
          final ok = await appState.tryRefresh();
          if (ok) {
            if (!mounted) return;
            _navigateNext();
            return;
          }
        }
        if (!mounted) return;
        _navigateNext();
        return;
      }
      setState(() => _status = 'Backend returned ${res.statusCode}');
    } catch (e) {
      setState(() => _status = 'Backend unreachable: $e');
    }
    // Attempt silent refresh even if backend check failed (maybe cookie endpoint reachable)
    try {
      if (!appState.isSignedIn) {
        final ok = await appState.tryRefresh();
        if (ok) {
          if (!mounted) return;
          _navigateNext();
          return;
        }
      }
    } catch (_) {}

    // Allow user to continue to auth offline, but show message
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      _navigateNext();
    });
  }

  void _navigateNext() {
    final appState = context.read<MyAppState>();
    if (appState.isSignedIn) {
      Navigator.of(context).pushReplacementNamed('/home');
    } else {
      Navigator.of(context).pushReplacementNamed('/pages/authentication');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(_status),
          ],
        ),
      ),
    );
  }
}
