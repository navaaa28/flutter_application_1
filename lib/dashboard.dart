import 'package:flutter/cupertino.dart';

class DashboardPage extends StatelessWidget {
  final String username;

  const DashboardPage({super.key, required this.username});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Dashboard'),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Welcome message
              const Text(
                'Dashboard',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),

              // User greeting
              Text(
                'Selamat Datang, $username!',
                style: const TextStyle(
                  fontSize: 22,
                  color: CupertinoColors.activeGreen,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 30),

              // Additional options or actions (optional)
              CupertinoButton(
                color: CupertinoColors.systemPink,
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Logout', style: TextStyle(fontSize: 18)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
