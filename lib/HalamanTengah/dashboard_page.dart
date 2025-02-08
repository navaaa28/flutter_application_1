import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../HalamanHome/home_tab.dart';
import '../HalamanMenu/menu_tab.dart';
import '../HalamanProfil/profile_tab.dart';

class DashboardPage extends StatefulWidget {
  final String username;
  final String password;

  const DashboardPage({
    super.key,
    required this.username,
    required this.password,
  });

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final List<String> attendanceLogs = [];

  void addAttendanceLog(String log) {
    setState(() {
      attendanceLogs.add(log);
    });
  }

  void _informasi() {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('INFORMASI!'),
        content: const Text('Aplikasi Ini Dibuat Untuk JAWA'),
        actions: [
          CupertinoDialogAction(
            child: const Text('OK'),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    FloatingActionButton(
      onPressed: () {
        // Implement action for FAB
      },
      child: Icon(Icons.add),
    );
    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        backgroundColor: Color.fromARGB(255, 255, 255, 255),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home', // Ganti label sesuai keinginan
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu),
            label: 'Menu', // Ganti label sesuai keinginan
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profil', // Ganti label sesuai keinginan
          ),
        ],
        currentIndex: 0, // Ganti index sesuai yang aktif
        onTap: (index) {
          // Implementasikan logika navigasi di sini
        },
      ),
      tabBuilder: (context, index) {
        switch (index) {
          case 0:
            return HomeTab(
              username: widget.username, 
              informasi: () {  },
            );
          case 1:
            return MenuTab(
              informasi: _informasi,
              username: widget.username,
            );
          case 2:
            return ProfileTab(
              username: widget.username,
              password: widget.password,
              informasi: _informasi, departemen: '',
            );
          default:
            return Container();
        }
      },
    );
  }
}
