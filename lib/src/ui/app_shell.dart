import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/app_state.dart';

class AppShell extends StatelessWidget {
  final Widget child;
  final String title;
  final int currentIndex;
  final ValueChanged<int>? onNavItemSelected;

  const AppShell({
    super.key,
    required this.child,
    this.title = 'UGC Net',
    this.currentIndex = 0,
    this.onNavItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<MyAppState>();
    final userName = appState.user?['name'] ?? appState.user?['email'] ?? 'User';

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Center(child: Text(userName)),
          ),
        ],
      ),
      drawer: Drawer(
        child: SafeArea(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      userName,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      appState.user?['email'] ?? '',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
              ListTile(
                leading: const Icon(Icons.dashboard),
                title: const Text('Dashboard'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/pages/dashboard');
                },
              ),
              ListTile(
                leading: const Icon(Icons.quiz),
                title: const Text('Quizzes'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/pages/quizzes');
                },
              ),
              ListTile(
                leading: const Icon(Icons.category),
                title: const Text('Topics'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/pages/topics');
                },
              ),
              ListTile(
                leading: const Icon(Icons.shuffle),
                title: const Text('Random Questions'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/pages/random-questions');
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.settings),
                title: const Text('Settings'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/settings');
                },
              ),
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Sign Out'),
                onTap: () async {
                  Navigator.pop(context);
                  await appState.clearAuth();
                  if (context.mounted) {
                    Navigator.of(context).pushReplacementNamed('/pages/authentication');
                  }
                },
              ),
            ],
          ),
        ),
      ),
      body: SafeArea(child: Padding(padding: const EdgeInsets.all(16.0), child: child)),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Theme.of(context).colorScheme.surface,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
        currentIndex: currentIndex,
        onTap: (index) {
          onNavItemSelected?.call(index);
          switch (index) {
            case 0:
              Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
            case 1:
              Navigator.pushNamed(context, '/stats');
            case 2:
              Navigator.pushNamed(context, '/import');
            case _:
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Stats',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.upload_file),
            label: 'Import',
          ),
        ],
      ),
    );
  }
}

