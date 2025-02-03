import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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

  @override
  void initState() {
    super.initState();
    _fetchRequests();
  }

  Future<void> _fetchRequests() async {
    final waitingResponse = await supabase
        .from('izin_cuti')
        .select()
        .eq('status', 'Menunggu Persetujuan Admin')
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
        if (statusType == 'Menunggu Persetujuan Admin') {
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
    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
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
    );
  }

  Widget _buildRequestList(List<Map<String, dynamic>> requestList, String statusType) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(statusType),
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
                color: CupertinoColors.systemGrey6,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Nama: ${request['display_name']}',
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text('Jabatan: ${request['departemen']}',
                        style: const TextStyle(fontSize: 14)),
                    Text('Tanggal Mulai: ${request['tanggal_mulai']}',
                        style: const TextStyle(fontSize: 14)),
                    Text('Tanggal Selesai: ${request['tanggal_selesai']}',
                        style: const TextStyle(fontSize: 14)),
                        Text('Alasan : ${request['alasan']}',
                        style: const TextStyle(fontSize: 14)),
                        Text('Kontak Darurat: ${request['kontak_darurat']}',
                        style: const TextStyle(fontSize: 14)),
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
                          color: CupertinoColors.activeGreen,
                          child: const Text('Diizinkan'),
                        ),
                        CupertinoButton(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          onPressed: () {
                            _updateStatus(request['id'].toString(),
                                'Ditolak', index, statusType);
                          },
                          color: CupertinoColors.destructiveRed,
                          child: const Text('Ditolak'),
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
