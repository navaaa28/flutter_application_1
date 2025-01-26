import 'package:flutter/cupertino.dart';
import 'home_tab.dart';
import 'menu_tab.dart';
import 'profile_tab.dart';

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
    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        backgroundColor: const Color.fromARGB(255, 131, 199, 248),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.home),
            label: 'Utama',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.square_grid_2x2),
            label: 'Menu',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.person),
            label: 'Profil',
          ),
        ],
      ),
      tabBuilder: (context, index) {
        switch (index) {
          case 0:
            return HomeTab(
              username: widget.username,
              attendanceLogs: attendanceLogs,
              informasi: _informasi,
            );
          case 1:
            return MenuTab(
              addAttendanceLog: addAttendanceLog,
              informasi: _informasi, username: '',
            );
          case 2:
            return ProfileTab(
              username: widget.username,
              password: widget.password,
              informasi: _informasi,
            );
          default:
            return Container();
        }
      },
    );
  }
}
