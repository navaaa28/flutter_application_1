import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DashboardPage extends StatelessWidget {
  final String username;
  final String password;

  const DashboardPage({
    super.key,
    required this.username,
    required this.password,
  });

  @override
  Widget build(BuildContext context) {
    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        backgroundColor: CupertinoColors.systemGrey6,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.square_grid_2x2),
            label: 'Menu',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.person),
            label: 'Profile',
          ),
        ],
      ),
      tabBuilder: (context, index) {
        switch (index) {
          case 0:
            return _HomeTab(username: username);
          case 1:
            return const _MenuTab();
          case 2:
            return _ProfileTab(username: username, password: password);
          default:
            return Container();
        }
      },
    );
  }
}

class _HomeTab extends StatelessWidget {
  final String username;

  const _HomeTab({required this.username});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Home'),
      ),
      child: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('images/dh.jpeg'), // Gambar background untuk Home
              fit: BoxFit.cover,
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  CupertinoIcons.calendar,
                  size: 80,
                  color: CupertinoColors.systemGreen,
                ),
                const SizedBox(height: 20),
                Text(
                  'Welcome, $username!',
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Your attendance matters!',
                  style: TextStyle(fontSize: 16, color: CupertinoColors.systemGrey),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MenuTab extends StatelessWidget {
  const _MenuTab();

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Menu'),
      ),
      child: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('images/dm.jpeg'), // Gambar background untuk Menu
              fit: BoxFit.cover,
            ),
          ),
          child: GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: 4,
            itemBuilder: (context, index) {
              final items = [
                {'icon': CupertinoIcons.check_mark_circled, 'label': 'Check In'},
                {'icon': CupertinoIcons.clear_circled, 'label': 'Check Out'},
                {'icon': CupertinoIcons.doc_text, 'label': 'Attendance Report'},
                {'icon': CupertinoIcons.settings, 'label': 'Settings'},
              ];

              return Container(
                decoration: BoxDecoration(
                  color: CupertinoColors.systemGreen.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: CupertinoColors.black.withOpacity(0.2),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      items[index]['icon'] as IconData,
                      size: 50,
                      color: CupertinoColors.white,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      items[index]['label'] as String,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: CupertinoColors.white,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _ProfileTab extends StatelessWidget {
  final String username;
  final String password;

  const _ProfileTab({required this.username, required this.password});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Profile'),
      ),
      child: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('images/dp.jpeg'), // Gambar background untuk Profile
              fit: BoxFit.cover,
            ),
          ),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const CircleAvatar(
                radius: 50,
                backgroundColor: CupertinoColors.systemGrey4,
                child: Icon(
                  CupertinoIcons.person,
                  size: 50,
                  color: CupertinoColors.systemGrey,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                username,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Password: $password',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  color: CupertinoColors.systemGrey,
                ),
              ),
              const SizedBox(height: 30),
              CupertinoButton(
                color: CupertinoColors.systemRed,
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Logout'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
