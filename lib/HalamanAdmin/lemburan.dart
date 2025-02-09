import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LemburanPage extends StatefulWidget {
  const LemburanPage({Key? key}) : super(key: key);

  @override
  _LemburanPageState createState() => _LemburanPageState();
}

class _LemburanPageState extends State<LemburanPage> {
  final SupabaseClient supabase = Supabase.instance.client;
  List<Map<String, dynamic>> waitingRequests = [];
  List<Map<String, dynamic>> approvedRequests = [];
  List<Map<String, dynamic>> rejectedRequests = [];
  final Color primaryColor = Color(0xFF2A2D7C);
  final Color accentColor = Color(0xFF00C2FF);
  final LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF2A2D7C), Color(0xFF00C2FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  @override
  void initState() {
    super.initState();
    _fetchRequests();
  }

  Future<void> _fetchRequests() async {
    final waitingResponse = await supabase
        .from('lembur')
        .select()
        .eq('status', 'Menunggu Persetujuan Atasan')
        .order('waktu_mulai');

    final approvedResponse = await supabase
        .from('lembur')
        .select()
        .eq('status', 'Diizinkan')
        .order('waktu_mulai');

    final rejectedResponse = await supabase
        .from('lembur')
        .select()
        .eq('status', 'Ditolak')
        .order('waktu_mulai');

    if (mounted) {
      setState(() {
        waitingRequests = List<Map<String, dynamic>>.from(waitingResponse);
        approvedRequests = List<Map<String, dynamic>>.from(approvedResponse);
        rejectedRequests = List<Map<String, dynamic>>.from(rejectedResponse);
      });
    }
  }

  Future<void> _updateStatus(
      String requestId, String newStatus, int index, String statusType) async {
    try {
      // Update status di Supabase
      await supabase
          .from('lembur')
          .update({'status': newStatus}).eq('id', requestId);

      // Memuat ulang data setelah update
      await _fetchRequests();

      _showDialog('Status Diperbarui', 'Status Lemburan berhasil diperbarui.');
    } catch (e) {
      _showDialog('Gagal', 'Terjadi kesalahan: ${e.toString()}');
    }
  }

  void _showDialog(String title, String content) {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Text(title),
          content: Text(content),
          actions: [
            CupertinoDialogAction(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primaryColor: primaryColor,
        colorScheme: ColorScheme.light(
          primary: primaryColor,
          secondary: accentColor,
        ),
        textTheme: GoogleFonts.poppinsTextTheme(),
      ),
      home: CupertinoTabScaffold(
        tabBar: CupertinoTabBar(
          backgroundColor: primaryColor,
          activeColor: Colors.white,
          inactiveColor: Colors.white.withOpacity(0.7),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.clock),
              label: 'Menunggu',
            ),
            BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.check_mark_circled),
              label: 'Diizinkan',
            ),
            BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.clear_circled),
              label: 'Ditolak',
            ),
          ],
        ),
        tabBuilder: (context, index) {
          switch (index) {
            case 0:
              return _buildRequestList(
                  waitingRequests, 'Menunggu Persetujuan Atasan');
            case 1:
              return _buildRequestList(approvedRequests, 'Diizinkan');
            case 2:
              return _buildRequestList(rejectedRequests, 'Ditolak');
            default:
              return _buildRequestList(
                  waitingRequests, 'Menunggu Persetujuan Atasan');
          }
        },
      ),
    );
  }

  Widget _buildRequestList(
      List<Map<String, dynamic>> requestList, String statusType) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(
          statusType,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: primaryColor,
      ),
      child: SafeArea(
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: requestList.length,
          itemBuilder: (context, index) {
            // Pengecekan index dan daftar
            if (requestList.isEmpty ||
                index < 0 ||
                index >= requestList.length) {
              return SizedBox(); // Kembalikan widget kosong jika index tidak valid
            }

            final request = requestList[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                gradient: primaryGradient,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: accentColor.withOpacity(0.3),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Tampilkan detail request
                    Text(
                      'Nama: ${request['display_name']}',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        decoration: TextDecoration.none,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Waktu Mulai: ${request['waktu_mulai']}',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.9),
                        decoration: TextDecoration.none,
                      ),
                    ),
                    // Tombol Diizinkan dan Ditolak
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CupertinoButton(
                          onPressed: () {
                            _updateStatus(request['id'].toString(), 'Diizinkan',
                                index, statusType);
                          },
                          child: Text('Diizinkan'),
                        ),
                        CupertinoButton(
                          onPressed: () {
                            _updateStatus(request['id'].toString(), 'Ditolak',
                                index, statusType);
                          },
                          child: Text('Ditolak'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
