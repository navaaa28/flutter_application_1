import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_application_1/HalamanHome/kalender_page.dart';
import 'package:flutter_application_1/HalamanHome/activity_page.dart';
import 'package:flutter_application_1/HalamanMenu/lembur_page.dart';

class HomeTab extends StatefulWidget {
  final String username;
  final VoidCallback informasi;

  const HomeTab({
    super.key,
    required this.username,
    required this.informasi,
  });

  @override
  _HomeTabState createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  String? checkInTime;
  String? checkOutTime;
  String? profileImageUrl;
  bool isDarkMode = false;

  final Color lightBlue = Color.fromARGB(255, 0, 0, 0);

  @override
  void initState() {
    super.initState();
    fetchUserProfile();
    fetchAttendanceData();
    setupRealtimeListener();
  }

  Future<void> fetchUserProfile() async {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;

    if (user == null) {
      print('User not logged in');
      return;
    }

    try {
      final response = await supabase
          .from('users')
          .select('profile_url')
          .eq('id', user.id)
          .single();

      setState(() {
        profileImageUrl = response['profile_url'];
      });
    } catch (e) {
      print('Error fetching profile image: $e');
    }
  }

  Future<void> fetchAttendanceData() async {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;

    if (user == null) {
      print('User not logged in');
      return;
    }

    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = DateTime(today.year, today.month, today.day, 23, 59, 59);

    try {
      final response = await supabase
          .from('absensi')
          .select()
          .eq('user_id', user.id)
          .gte('tanggal', startOfDay.toIso8601String())
          .lte('tanggal', endOfDay.toIso8601String());

      if (response.isNotEmpty) {
        setState(() {
          checkInTime = response
              .firstWhere(
                (record) => record['jenis_absen'] == 'masuk',
                orElse: () => {},
              )['tanggal']?.toString();
          checkOutTime = response
              .firstWhere(
                (record) => record['jenis_absen'] == 'keluar',
                orElse: () => {},
              )['tanggal']?.toString();
        });
      } else {
        setState(() {
          checkInTime = null;
          checkOutTime = null;
        });
      }
    } catch (e) {
      print('Error fetching attendance data: $e');
    }
  }

  void setupRealtimeListener() {
    final supabase = Supabase.instance.client;
    final userId = supabase.auth.currentUser?.id;

    if (userId == null) {
      print('User not logged in, skipping realtime listener setup.');
      return;
    }

    supabase
        .from('absensi')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .listen((event) {
      print('Realtime event: $event');
      fetchAttendanceData();
    });
  }

  String formatDate(String? dateString) {
    if (dateString == null) return 'Belum Absen';
    final date = DateTime.parse(dateString);
    return DateFormat('HH:mm, dd MMM yyyy').format(date);
  }

  void toggleDarkMode() {
    setState(() {
      isDarkMode = !isDarkMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = isDarkMode ? ThemeData.dark() : ThemeData.light();

    return MaterialApp(
      theme: theme,
      home: Scaffold(
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
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
                // Profile Card Section
                Container(
                  margin: const EdgeInsets.all(16.0),
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
                            const Color.fromARGB(255, 79, 79, 79),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 30,
                              backgroundImage: profileImageUrl != null
                                  ? NetworkImage(profileImageUrl!)
                                  : AssetImage('images/logo.png') as ImageProvider,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.username,
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // Attendance Card Section
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16.0),
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
                            const Color.fromARGB(255, 79, 79, 79),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Masuk',
                                    style: TextStyle(color: Colors.black54)),
                                Text(
                                  formatDate(checkInTime),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Selesai',
                                    style: TextStyle(color: Colors.black54)),
                                Text(
                                  formatDate(checkOutTime),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // Grid Menu Section
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: GridView.count(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    crossAxisCount: 3,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    children: [
                      _buildMenuItem(CupertinoIcons.calendar, 'Kalender', onTap: _showKalenderPage),
                      _buildMenuItem(CupertinoIcons.square_list, 'Aktivitas', onTap: _showActivityPage),
                      _buildMenuItem(CupertinoIcons.clock, 'Lembur', onTap: _showLemburPage),
                      _buildMenuItem(CupertinoIcons.doc, 'Izin / Cuti'),
                    ],
                  ),
                ),
              ]),
            ),
          ],
        ),
      ),
    );
  }

  void _showActivityPage() {
    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) => ActivityPage(),
      ),
    );
  }

  void _showKalenderPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => KalenderPage(),
      ),
    );
  }

  void _showLemburPage() {
    // Implement navigation to LemburPage
  }

  Widget _buildMenuItem(IconData icon, String label, {VoidCallback? onTap}) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Card(
          elevation: 4,
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
                Icon(icon, size: 32, color: CupertinoColors.activeBlue),
                const SizedBox(height: 8),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}