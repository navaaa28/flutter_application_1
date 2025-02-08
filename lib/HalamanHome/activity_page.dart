import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Untuk format tanggal
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

class ActivityPage extends StatefulWidget {
  @override
  _ActivityPageState createState() => _ActivityPageState();
}

class _ActivityPageState extends State<ActivityPage> {
  List<Map<String, dynamic>> attendanceList = [];
  List<Map<String, dynamic>> leaveList = [];
  final Color primaryColor = Color(0xFF2A2D7C);
  final Color accentColor = Color(0xFF00C2FF);

  @override
  void initState() {
    super.initState();
    fetchActivities();
    fetchLeaves();
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

      print('Fetched attendance data: $response');

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

  Future<void> fetchLeaves() async {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;

    if (user == null) {
      print('User not logged in');
      return;
    }

    try {
      final response = await supabase
          .from('izin_cuti')
          .select()
          .eq('user_id', user.id)
          .order('created_at', ascending: false);

      print('Fetched leave data: $response');

      if (response != null && response.isNotEmpty) {
        setState(() {
          leaveList = List<Map<String, dynamic>>.from(response);
        });
      } else {
        setState(() {
          leaveList = [];
        });
        print('No leave data found.');
      }
    } catch (e) {
      print('Error fetching leaves: $e');
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
        middle: Text(
          'Aktivitas Absen & Izin Cuti',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: primaryColor,
        border: null,
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  "Data Absensi",
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                    decoration: TextDecoration.none,
                  ),
                ),
              ),
              attendanceList.isEmpty
                  ? Center(
                      child: Text(
                        "Tidak ada data absensi",
                        style: GoogleFonts.poppins(
                          color: Colors.grey[600],
                          decoration: TextDecoration.none,
                        ),
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: attendanceList.length,
                      itemBuilder: (context, index) {
                        final attendance = attendanceList[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(
                            vertical: 8.0,
                            horizontal: 16.0,
                          ),
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.grey[200],
                              backgroundImage: attendance['foto_url'] != null &&
                                      attendance['foto_url'].isNotEmpty
                                  ? NetworkImage(
                                      'https://twthndrmrdkhtvgodqae.supabase.co/storage/v1/object/public/${attendance['foto_url']}')
                                  : null,
                              child: attendance['foto_url'] == null ||
                                      attendance['foto_url'].isEmpty
                                  ? Icon(Icons.person, color: Colors.grey)
                                  : null,
                            ),
                            title: Text(
                              attendance['jenis_absen']?.toUpperCase() ?? 'N/A',
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  formatDate(attendance['tanggal']),
                                  style: GoogleFonts.poppins(
                                    color: Colors.grey[600],
                                  ),
                                ),
                                Text(
                                  attendance['lokasi'] ?? 'Lokasi tidak tersedia',
                                  style: GoogleFonts.poppins(
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  "Data Izin Cuti",
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                    decoration: TextDecoration.none,
                  ),
                ),
              ),
              leaveList.isEmpty
                  ? Center(
                      child: Text(
                        "Tidak ada data izin cuti",
                        style: GoogleFonts.poppins(
                          color: Colors.grey[600],
                          decoration: TextDecoration.none,
                        ),
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: leaveList.length,
                      itemBuilder: (context, index) {
                        final leave = leaveList[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(
                            vertical: 8.0,
                            horizontal: 16.0,
                          ),
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            title: Text(
                              leave['display_name'] ?? 'N/A',
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Departemen: ${leave['departemen'] ?? 'N/A'}",
                                  style: GoogleFonts.poppins(
                                    color: Colors.grey[600],
                                  ),
                                ),
                                Text(
                                  "Tanggal Mulai: ${leave['tanggal_mulai'] ?? 'N/A'}",
                                  style: GoogleFonts.poppins(
                                    color: Colors.grey[600],
                                  ),
                                ),
                                Text(
                                  "Tanggal Selesai: ${leave['tanggal_selesai'] ?? 'N/A'}",
                                  style: GoogleFonts.poppins(
                                    color: Colors.grey[600],
                                  ),
                                ),
                                Text(
                                  "Alasan: ${leave['alasan'] ?? 'Tidak tersedia'}",
                                  style: GoogleFonts.poppins(
                                    color: Colors.grey[600],
                                  ),
                                ),
                                Text(
                                  "Kontak Darurat: ${leave['kontak_darurat'] ?? 'N/A'}",
                                  style: GoogleFonts.poppins(
                                    color: Colors.grey[600],
                                  ),
                                ),
                                Text(
                                  "Status: ${leave['status'] ?? 'N/A'}",
                                  style: GoogleFonts.poppins(
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ],
          ),
        ),
      ),
    );
  }
}