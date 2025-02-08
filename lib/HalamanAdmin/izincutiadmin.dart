import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class IzinCutiAdminPage extends StatefulWidget {
  const IzinCutiAdminPage({Key? key}) : super(key: key);

  @override
  _IzinCutiAdminPageState createState() => _IzinCutiAdminPageState();
}

class _IzinCutiAdminPageState extends State<IzinCutiAdminPage> {
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
        .from('izin_cuti')
        .select()
        .eq('status', 'Menunggu Persetujuan Atasan')
        .order('tanggal_mulai');

    final approvedResponse = await supabase
        .from('izin_cuti')
        .select()
        .eq('status', 'Diizinkan')
        .order('tanggal_mulai');

    final rejectedResponse = await supabase
        .from('izin_cuti')
        .select()
        .eq('status', 'Ditolak')
        .order('tanggal_mulai');

    setState(() {
      waitingRequests = List<Map<String, dynamic>>.from(waitingResponse);
      approvedRequests = List<Map<String, dynamic>>.from(approvedResponse);
      rejectedRequests = List<Map<String, dynamic>>.from(rejectedResponse);
    });
  }

  Future<void> _updateStatus(
      String requestId, String newStatus, int index, String statusType) async {
    try {
      await supabase
          .from('izin_cuti')
          .update({'status': newStatus}).eq('id', requestId);

      await _fetchRequests();

      setState(() {
        if (statusType == 'Menunggu Persetujuan Atasan') {
          waitingRequests[index]['status'] = newStatus;
        } else if (statusType == 'Diizinkan') {
          approvedRequests[index]['status'] = newStatus;
        } else if (statusType == 'Ditolak') {
          rejectedRequests[index]['status'] = newStatus;
        }
      });

      _showDialog('Status Diperbarui', 'Status izin/cuti berhasil diperbarui.');
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
              return _buildRequestList(waitingRequests, 'Menunggu Persetujuan Admin');
            case 1:
              return _buildRequestList(approvedRequests, 'Diizinkan');
            case 2:
              return _buildRequestList(rejectedRequests, 'Ditolak');
            default:
              return _buildRequestList(waitingRequests, 'Menunggu Persetujuan Admin');
          }
        },
      ),
    );
  }

  Widget _buildRequestList(List<Map<String, dynamic>> requestList, String statusType) {
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
                    Text(
                      'Nama: ${request['display_name']}',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        decoration:TextDecoration.none
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Jabatan: ${request['departemen']}',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.9),
                        decoration:TextDecoration.none
                      ),
                    ),
                    Text(
                      'Tanggal Mulai: ${request['tanggal_mulai']}',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.9),
                        decoration:TextDecoration.none
                      ),
                    ),
                    Text(
                      'Tanggal Selesai: ${request['tanggal_selesai']}',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.9),
                        decoration:TextDecoration.none
                      ),
                    ),
                    Text(
                      'Alasan: ${request['alasan']}',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.9),
                        decoration:TextDecoration.none
                      ),
                    ),
                    Text(
                      'Kontak Darurat: ${request['kontak_darurat']}',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.9),
                        decoration:TextDecoration.none
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CupertinoButton(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          onPressed: () {
                            _updateStatus(request['id'].toString(),
                                'Diizinkan', index, statusType);
                          },
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          child: Text(
                            'Diizinkan',
                            style: GoogleFonts.poppins(
                              color: primaryColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        CupertinoButton(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          onPressed: () {
                            _updateStatus(request['id'].toString(),
                                'Ditolak', index, statusType);
                          },
                          color: const Color.fromARGB(255, 255, 0, 0),
                          borderRadius: BorderRadius.circular(8),
                          child: Text(
                            'Ditolak',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
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
