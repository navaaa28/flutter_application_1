import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PengelolaanAdminPage extends StatefulWidget {
  const PengelolaanAdminPage({Key? key}) : super(key: key);

  @override
  _PengelolaanAdminPageState createState() => _PengelolaanAdminPageState();
}

class _PengelolaanAdminPageState extends State<PengelolaanAdminPage> {
  final _supabase = Supabase.instance.client;
  List<Map<String, dynamic>> _admins = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAdmins();
  }

  Future<void> _fetchAdmins() async {
    try {
      final response = await _supabase
          .from('users')
          .select('*')
          .eq('role', 'admin')
          .order('created_at', ascending: false);

      setState(() {
        _admins = List<Map<String, dynamic>>.from(response);
        _isLoading = false;
      });
    } catch (e) {
      _showErrorDialog('Gagal mengambil data admin');
    }
  }

  Future<void> _toggleAdminStatus(String userId, bool isActive) async {
    try {
      await _supabase
          .from('users')
          .update({'is_active': isActive})
          .eq('id', userId);

      _fetchAdmins();
      _showSuccessDialog('Status admin berhasil diperbarui');
    } catch (e) {
      _showErrorDialog('Gagal memperbarui status admin');
    }
  }

  void _showSuccessDialog(String message) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Berhasil'),
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            child: const Text('OK'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Terjadi Kesalahan', style: TextStyle(color: CupertinoColors.systemRed)),
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            child: const Text('Tutup'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Kelola Admin'),
      ),
      child: SafeArea(
        child: _isLoading
            ? const Center(child: CupertinoActivityIndicator(radius: 15))
            : Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  children: [
                    Expanded(
                      child: _admins.isEmpty
                          ? const Center(child: Text("Tidak ada admin yang tersedia"))
                          : ListView.builder(
                              itemCount: _admins.length,
                              itemBuilder: (context, index) {
                                final admin = _admins[index];
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 10),
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: CupertinoColors.systemBackground,
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.3),
                                        blurRadius: 5,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            admin['display_name'] ?? 'Tanpa Nama',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18,
                                              decoration:TextDecoration.none
                                            ),
                                          ),
                                          const SizedBox(height: 5),
                                          Text(
                                            admin['email'] ?? 'Tidak ada email',
                                            style: const TextStyle(
                                              fontSize: 14,
                                              color: CupertinoColors.systemGrey,
                                              decoration:TextDecoration.none
                                            ),
                                          ),
                                        ],
                                      ),
                                      CupertinoSwitch(
                                        value: (admin['is_active'] is bool) ? admin['is_active'] : admin['is_active'] == 'true',
                                        onChanged: (value) => _toggleAdminStatus(admin['id'], value),
                                      ),
                                    ],
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
