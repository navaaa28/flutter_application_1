import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Library untuk format waktu dan tanggal

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
  final List<String> attendanceLogs = []; // Menyimpan log absen

  void addAttendanceLog(String log) {
    setState(() {
      attendanceLogs.add(log);
    });
  }

  // Metode _informasi dipindahkan ke dalam kelas _DashboardPageState
  void _informasi() {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('INFORMASI!'),
        content: const Text('Aplikasi Ini Dibuat Oleh Dany Faturrochman-22552011080'),
        actions: <Widget>[
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
            return _HomeTab(
              username: widget.username,
              attendanceLogs: attendanceLogs,
              informasi: _informasi,
            );
          case 1:
            return _MenuTab(
              addAttendanceLog: addAttendanceLog,
              informasi: _informasi,
            );
          case 2:
            return _ProfileTab(
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

class _HomeTab extends StatelessWidget {
  final String username;
  final List<String> attendanceLogs;
  final VoidCallback informasi;

  const _HomeTab({
    required this.username,
    required this.attendanceLogs,
    required this.informasi,
  });

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Halaman Utama'),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: informasi,
          child: const Icon(CupertinoIcons.info_circle, size: 28),
        ),
      ),
      child: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('images/dh.jpeg'),
              fit: BoxFit.cover,
            ),
          ),
          child: Column(
            children: [
              const SizedBox(height: 20),
              Text(
                'Welcome, $username!',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: CupertinoColors.white,
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: attendanceLogs.length,
                  itemBuilder: (context, index) {
                    return Card(
                      color: const Color.fromARGB(255, 76, 178, 229).withOpacity(0.4),
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          attendanceLogs[index],
                          style: const TextStyle(
                            fontSize: 16,
                            color: CupertinoColors.white,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuTab extends StatelessWidget {
  final Function(String) addAttendanceLog;
  final VoidCallback informasi;

  const _MenuTab({
    required this.addAttendanceLog,
    required this.informasi,
  });

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Halaman Menu'),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: informasi,
          child: const Icon(CupertinoIcons.info_circle, size: 28),
        ),
      ),
      child: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('images/dm.jpeg'),
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
                {'icon': CupertinoIcons.check_mark_circled, 'label': 'Absen Masuk'},
                {'icon': CupertinoIcons.clear_circled, 'label': 'Absen Keluar'},
                {'icon': CupertinoIcons.doc_text, 'label': 'Lembur'},
                {'icon': CupertinoIcons.settings, 'label': 'Pengaturan'},
              ];

              return GestureDetector(
                onTap: () {
                  if (index == 0 || index == 1) {
                    final now = DateTime.now();
                    final formattedDate =
                        DateFormat('yyyy-MM-dd HH:mm:ss').format(now);
                    final log = '${items[index]['label']} pada $formattedDate';
                    addAttendanceLog(log);
                    showCupertinoDialog(
                      context: context,
                      builder: (_) => CupertinoAlertDialog(
                        title: const Text('Sukses'),
                        content: Text('Logged: $log'),
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
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 76, 178, 229).withOpacity(0.4),
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
  final VoidCallback informasi;

  const _ProfileTab({
    required this.username,
    required this.password,
    required this.informasi,
  });

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Halaman Profil'),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: informasi,
          child: const Icon(CupertinoIcons.info_circle, size: 28),
        ),
      ),
      child: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('images/dp.jpeg'),
              fit: BoxFit.cover,
            ),
          ),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const SizedBox(height: 60),
              Center(
                child: ClipOval(
                  child: Image.asset(
                    'images/logo.png',
                    width: 120,
                    height: 120,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                username,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 254, 254, 255),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Password: $password',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 20,
                  color: Color.fromARGB(255, 254, 254, 255),
                ),
              ),
              const SizedBox(height: 30),
              CupertinoButton(
                color: CupertinoColors.systemRed,
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('KELUAR!'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
