import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/HalamanHome/kalender_page.dart';
import 'package:intl/intl.dart'; // Untuk format tanggal
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_application_1/HalamanHome/activity_page.dart'; // Import ActivityPage
import 'package:flutter_application_1/HalamanMenu/lembur_page.dart'; // Import LemburPage

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

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Dashboard'),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Header Section
            Container(
              color: const Color.fromARGB(255, 76, 178, 229),
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
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              color: const Color.fromARGB(255, 200, 230, 255),
              padding: const EdgeInsets.all(16.0),
              margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
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

            // Grid Menu Section
            Expanded(
              child: GridView.count(
                padding: const EdgeInsets.all(16.0),
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
          ],
        ),
      ),
    );
  }

  

  void _showActivityPage() {

    Navigator.push(
      context,
      CupertinoPageRoute(
      builder: (context) =>
      ActivityPage(),
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
  }
  }



  Widget _buildMenuItem(IconData icon, String label, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: CupertinoColors.systemGrey.withOpacity(0.1),
          border: Border.all(color: CupertinoColors.systemGrey, width: 1),
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 28, color: CupertinoColors.activeBlue),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  