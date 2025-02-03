import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/HalamanMenu/absensikeluar_page.dart';
import 'package:flutter_application_1/HalamanMenu/izincuti_page.dart';
import 'package:flutter_application_1/HalamanMenu/lembur_page.dart';
import 'absensimasuk_page.dart';

class MenuTab extends StatefulWidget {
  final VoidCallback informasi;
  final String username;

  const MenuTab({
    super.key,
    required this.informasi,
    required this.username,
  });

  @override
  _MenuTabState createState() => _MenuTabState();
}

class _MenuTabState extends State<MenuTab> {
  bool isDarkMode = false;

  void toggleDarkMode() {
    setState(() {
      isDarkMode = !isDarkMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    final items = [
      {'icon': CupertinoIcons.check_mark_circled, 'label': 'Absen Masuk'},
      {'icon': CupertinoIcons.clear_circled, 'label': 'Absen Keluar'},
      {'icon': CupertinoIcons.doc_text, 'label': 'Lembur'},
      {'icon': CupertinoIcons.calendar_badge_minus, 'label': 'Izin / Cuti'},
      {'icon': CupertinoIcons.exclamationmark_triangle, 'label': 'Coming Soon'},
    ];

    final theme = isDarkMode ? ThemeData.dark() : ThemeData.light();

    return MaterialApp(
      theme: theme,
      home: Scaffold(
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 200.0,
              floating: false,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                title: Text('Dashboard'),
                background: Image.asset(
                  'images/WP.jpg',
                  fit: BoxFit.cover,
                ),
              ),
              actions: [
                IconButton(
                  icon: Icon(isDarkMode ? Icons.light_mode : Icons.dark_mode),
                  onPressed: toggleDarkMode,
                ),
              ],
            ),
            SliverList(
              delegate: SliverChildListDelegate([
                // Header Section with Avatar and Greeting
                Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [const Color.fromARGB(255, 158, 211, 255), const Color.fromARGB(255, 105, 178, 241)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        radius: 30,
                        backgroundImage: AssetImage('images/logo.png'),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Selamat Datang',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              widget.username,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w500,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Menu Grid Section
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: GridView.count(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    crossAxisCount: 3,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    children: items.map((item) {
                      return GestureDetector(
                        onTap: () {
                          if (item['label'] == 'Absen Masuk') {
                            Navigator.push(
                              context,
                              CupertinoPageRoute(
                                builder: (context) => AbsenMasukPage(username: widget.username),
                              ),
                            );
                          } else if (item['label'] == 'Absen Keluar') {
                            Navigator.push(
                              context,
                              CupertinoPageRoute(
                                builder: (context) => AbsenKeluarPage(username: widget.username),
                              ),
                            );
                          } else if (item['label'] == 'Lembur') {
                            Navigator.push(
                              context,
                              CupertinoPageRoute(
                                builder: (context) => LemburPage(),
                              ),
                            );
                          } else if (item['label'] == 'Izin / Cuti') {
                            Navigator.push(
                              context,
                              CupertinoPageRoute(
                                builder: (context) => IzinCutiPage(),
                              ),
                            );
                          } else {
                            _showComingSoonDialog(context);
                          }
                        },
                        child: Card(
                          elevation: 8,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20.0),
                              gradient: LinearGradient(
                                colors: [
                                  Colors.blue.shade100,
                                  Colors.blue.shade200,
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(item['icon'] as IconData, size: 32, color: CupertinoColors.activeBlue),
                                const SizedBox(height: 8),
                                Text(
                                  item['label'] as String,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ]),
            ),
          ],
        ),
      ),
    );
  }

  void _showComingSoonDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Coming Soon'),
        content: const Text('This feature will be available soon.'),
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
}
