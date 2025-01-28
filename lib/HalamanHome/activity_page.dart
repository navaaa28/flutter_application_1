import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Untuk format tanggal
import 'package:supabase_flutter/supabase_flutter.dart';

class ActivityPage extends StatefulWidget {
  @override
  _ActivityPageState createState() => _ActivityPageState();
}

class _ActivityPageState extends State<ActivityPage> {
  List<Map<String, dynamic>> attendanceList = [];

  @override
  void initState() {
    super.initState();
    fetchActivities();
  }

  Future<void> fetchActivities() async {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;

    if (user == null) {
      print('User not logged in');
      return;
    }

    try {
      final response = await supabase
          .from('absensi')
          .select()
          .eq('user_id', user.id)
          .order('tanggal', ascending: false);

      // Check if the response contains data
      print('Fetched attendance data: $response'); // Log the response

      if (response != null && response.isNotEmpty) {
        setState(() {
          attendanceList = List<Map<String, dynamic>>.from(response);
        });
      } else {
        setState(() {
          attendanceList = [];
        });
        print('No attendance data found.');
      }
    } catch (e) {
      print('Error fetching activities: $e');
    }
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
        middle: const Text('Aktivitas Absen'),
      ),
      child: SafeArea(
        child: attendanceList.isEmpty
            ? Center(child: Text("Tidak ada data absensi"))
            : ListView.builder(
                itemCount: attendanceList.length,
                itemBuilder: (context, index) {
                  final attendance = attendanceList[index];
                  return ListTile(
                    title: Text(attendance['jenis_absen'] ?? 'N/A'),
                    subtitle: Text(formatDate(attendance['tanggal'])),
                  );
                },
              ),
      ),
    );
  }
}
