import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

class ActivityPage extends StatefulWidget {
  @override
  _ActivityPageState createState() => _ActivityPageState();
}

class _ActivityPageState extends State<ActivityPage> {
  List<Map<String, dynamic>> attendanceList = [];
  List<Map<String, dynamic>> leaveList = [];
  List<Map<String, dynamic>> overtimeList = [];
  final Color primaryColor = Color(0xFF2A2D7C); // Warna utama (biru tua)
  final Color accentColor = Color(0xFF00C2FF); // Warna aksen (biru muda)
  final Color backgroundColor = Color(0xFFF5F7FA); // Warna latar belakang
  final Color cardColor = Colors.white; // Warna card
  final Color textColor = Color(0xFF333333); // Warna teks utama
  final Color secondaryTextColor = Color(0xFF666666); // Warna teks sekunder
  int _selectedTabIndex = 0; // 0: Absensi, 1: Izin, 2: Lembur

  @override
  void initState() {
    super.initState();
    fetchActivities();
    fetchLeaves();
    fetchLembur();
  }

  Future<void> fetchLembur() async {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;

    if (user == null) {
      print('User not logged in');
      return;
    }

    try {
      final response = await supabase
          .from('lembur')
          .select()
          .eq('user_id', user.id)
          .order('created_at', ascending: false);

      if (response != null && response.isNotEmpty) {
        setState(() {
          overtimeList = List<Map<String, dynamic>>.from(response);
        });
      } else {
        setState(() {
          overtimeList = [];
        });
      }
    } catch (e) {
      print('Error fetching overtime: $e');
    }
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

      if (response != null && response.isNotEmpty) {
        setState(() {
          attendanceList = List<Map<String, dynamic>>.from(response);
        });
      } else {
        setState(() {
          attendanceList = [];
        });
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

      if (response != null && response.isNotEmpty) {
        setState(() {
          leaveList = List<Map<String, dynamic>>.from(response);
        });
      } else {
        setState(() {
          leaveList = [];
        });
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
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(
          'Aktivitas',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 20,
            decoration: TextDecoration.none,
          ),
        ),
        backgroundColor: primaryColor,
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Tab Bar
          Container(
            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildTabButton(0, 'Absensi'),
                _buildTabButton(1, 'Izin'),
                _buildTabButton(2, 'Lembur'),
              ],
            ),
          ),
          // Konten berdasarkan tab yang dipilih
          Expanded(
            child: IndexedStack(
              index: _selectedTabIndex,
              children: [
                _buildAttendanceList(),
                _buildLeaveList(),
                _buildOvertimeList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(int index, String label) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTabIndex = index;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: _selectedTabIndex == index ? primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            color: _selectedTabIndex == index ? Colors.white : textColor,
            fontWeight: FontWeight.w500,
            fontSize: 14,
            decoration: TextDecoration.none,
          ),
        ),
      ),
    );
  }

  Widget _buildAttendanceList() {
    return attendanceList.isEmpty
        ? Center(
            child: Text(
              "Tidak ada data absensi",
              style: GoogleFonts.poppins(
                color: secondaryTextColor,
                fontSize: 16,
                decoration: TextDecoration.none,
              ),
            ),
          )
        : ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: attendanceList.length,
            itemBuilder: (context, index) {
              final attendance = attendanceList[index];
              return Card(
                margin: EdgeInsets.only(bottom: 16),
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
                      color: textColor,
                      decoration: TextDecoration.none,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        formatDate(attendance['tanggal']),
                        style: GoogleFonts.poppins(
                          color: secondaryTextColor,
                          decoration: TextDecoration.none,
                        ),
                      ),
                      Text(
                        attendance['lokasi'] ?? 'Lokasi tidak tersedia',
                        style: GoogleFonts.poppins(
                          color: secondaryTextColor,
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
  }

  Widget _buildLeaveList() {
    return leaveList.isEmpty
        ? Center(
            child: Text(
              "Tidak ada data izin cuti",
              style: GoogleFonts.poppins(
                color: secondaryTextColor,
                fontSize: 16,
                decoration: TextDecoration.none,
              ),
            ),
          )
        : ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: leaveList.length,
            itemBuilder: (context, index) {
              final leave = leaveList[index];
              return Card(
                margin: EdgeInsets.only(bottom: 16),
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  title: Text(
                    leave['display_name'] ?? 'N/A',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      color: textColor,
                      decoration: TextDecoration.none,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Departemen: ${leave['departemen'] ?? 'N/A'}",
                        style: GoogleFonts.poppins(
                          color: secondaryTextColor,
                          decoration: TextDecoration.none,
                        ),
                      ),
                      Text(
                        "Tanggal Mulai: ${leave['tanggal_mulai'] ?? 'N/A'}",
                        style: GoogleFonts.poppins(
                          color: secondaryTextColor,
                          decoration: TextDecoration.none,
                        ),
                      ),
                      Text(
                        "Tanggal Selesai: ${leave['tanggal_selesai'] ?? 'N/A'}",
                        style: GoogleFonts.poppins(
                          color: secondaryTextColor,
                          decoration: TextDecoration.none,
                        ),
                      ),
                      Text(
                        "Alasan: ${leave['alasan'] ?? 'Tidak tersedia'}",
                        style: GoogleFonts.poppins(
                          color: secondaryTextColor,
                          decoration: TextDecoration.none,
                        ),
                      ),
                      Text(
                        "Kontak Darurat: ${leave['kontak_darurat'] ?? 'N/A'}",
                        style: GoogleFonts.poppins(
                          color: secondaryTextColor,
                          decoration: TextDecoration.none,
                        ),
                      ),
                      Text(
                        "Status: ${leave['status'] ?? 'N/A'}",
                        style: GoogleFonts.poppins(
                          color: secondaryTextColor,
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
  }

  Widget _buildOvertimeList() {
    return overtimeList.isEmpty
        ? Center(
            child: Text(
              "Tidak ada data lembur",
              style: GoogleFonts.poppins(
                color: secondaryTextColor,
                fontSize: 16,
                decoration: TextDecoration.none,
              ),
            ),
          )
        : ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: overtimeList.length,
            itemBuilder: (context, index) {
              final overtime = overtimeList[index];
              return Card(
                margin: EdgeInsets.only(bottom: 16),
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  title: Text(
                    overtime['display_name'] ?? 'N/A',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      color: textColor,
                      decoration: TextDecoration.none,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Waktu Mulai: ${overtime['waktu_mulai'] ?? 'N/A'}",
                        style: GoogleFonts.poppins(
                          color: secondaryTextColor,
                          decoration: TextDecoration.none,
                        ),
                      ),
                      Text(
                        "Waktu Selesai: ${overtime['waktu_selesai'] ?? 'N/A'}",
                        style: GoogleFonts.poppins(
                          color: secondaryTextColor,
                          decoration: TextDecoration.none,
                        ),
                      ),
                      Text(
                        "Durasi: ${overtime['durasi'] ?? 'N/A'} menit",
                        style: GoogleFonts.poppins(
                          color: secondaryTextColor,
                          decoration: TextDecoration.none,
                        ),
                      ),
                      Text(
                        "Status: ${overtime['status'] ?? 'N/A'}",
                        style: GoogleFonts.poppins(
                          color: secondaryTextColor,
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
  }
}