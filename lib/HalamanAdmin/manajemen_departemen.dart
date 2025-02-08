import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ManajemenDepartemenPage extends StatefulWidget {
  const ManajemenDepartemenPage({super.key});

  @override
  _ManajemenDepartemenPageState createState() => _ManajemenDepartemenPageState();
}

class _ManajemenDepartemenPageState extends State<ManajemenDepartemenPage> {
  late Future<List<Map<String, dynamic>>> _departemenFuture;
  late Future<List<Map<String, dynamic>>> _usersFuture;

  @override
  void initState() {
    super.initState();
    _departemenFuture = _fetchDepartemen();
    _usersFuture = _fetchUsers();
  }

  /// Mengambil daftar departemen unik
  Future<List<Map<String, dynamic>>> _fetchDepartemen() async {
    final response = await Supabase.instance.client
        .from('users')
        .select('departemen')
        .neq('departemen' , 0);

    final departemenList = response.map<String>((e) => e['departemen'] as String).toSet().toList();

    List<Map<String, dynamic>> departemenData = [];

    for (String departemen in departemenList) {
      final countResponse = await Supabase.instance.client
          .from('users')
          .select('id')
          .eq('departemen', departemen);
          
      departemenData.add({
        'nama_departemen': departemen,
        'jumlah_karyawan': countResponse.count ?? 0,
      });
    }

    return departemenData;
  }

  /// Mengambil daftar semua pengguna
  Future<List<Map<String, dynamic>>> _fetchUsers() async {
    final response = await Supabase.instance.client
        .from('users')
        .select('id, display_name, email, departemen')
        .order('display_name', ascending: true);

    return List<Map<String, dynamic>>.from(response);
  }

  /// Memperbarui departemen pengguna
  Future<void> _updateUserDepartemen(String userId, String newDepartemen) async {
    await Supabase.instance.client
        .from('users')
        .update({'departemen': newDepartemen})
        .eq('id', userId);

    setState(() {
      _usersFuture = _fetchUsers();
      _departemenFuture = _fetchDepartemen();
    });
  }

  /// Menampilkan menu pilihan untuk mengganti departemen pegawai
  void _showChangeDepartemenDialog(BuildContext context, String userId) async {
    final departemenList = await _fetchDepartemen();

    if (departemenList.isEmpty) return;

    showCupertinoModalPopup(
      context: context,
      builder: (context) {
        return CupertinoActionSheet(
          title: const Text("Pilih Departemen Baru"),
          actions: departemenList.map((departemen) {
            return CupertinoActionSheetAction(
              onPressed: () async {
                await _updateUserDepartemen(userId, departemen['nama_departemen']);
                Navigator.pop(context);
              },
              child: Text(departemen['nama_departemen']),
            );
          }).toList(),
          cancelButton: CupertinoActionSheetAction(
            isDefaultAction: true,
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Manajemen Departemen'),
      ),
      child: SafeArea(
        child: Column(
          children: [
            CupertinoSegmentedControl<int>(
              padding: const EdgeInsets.all(10),
              children: const {
                0: Padding(padding: EdgeInsets.all(4), child: Text("Departemen")),
                1: Padding(padding: EdgeInsets.all(4), child: Text("Pegawai")),
              },
              onValueChanged: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
              groupValue: _selectedIndex,
            ),
            Expanded(
              child: IndexedStack(
                index: _selectedIndex,
                children: [
                  /// **Tampilan Departemen**
                  FutureBuilder<List<Map<String, dynamic>>>(
                    future: _departemenFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CupertinoActivityIndicator());
                      }

                      if (snapshot.hasError) {
                        return Center(
                          child: Text('Terjadi kesalahan: ${snapshot.error}'),
                        );
                      }

                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Center(
                          child: Text('Tidak ada departemen tersedia.'),
                        );
                      }

                      final departemen = snapshot.data!;

                      return CupertinoScrollbar(
                        child: ListView.builder(
                          itemCount: departemen.length,
                          itemBuilder: (context, index) => CupertinoListTile(
                            leading: const Icon(CupertinoIcons.building_2_fill, color: CupertinoColors.activeBlue),
                            title: Text(departemen[index]['nama_departemen'],
                                style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text('Jumlah Karyawan: ${departemen[index]['jumlah_karyawan']}'),
                          ),
                        ),
                      );
                    },
                  ),

                  /// **Tampilan Pegawai**
                  FutureBuilder<List<Map<String, dynamic>>>(
                    future: _usersFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CupertinoActivityIndicator());
                      }

                      if (snapshot.hasError) {
                        return Center(
                          child: Text('Terjadi kesalahan: ${snapshot.error}'),
                        );
                      }

                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Center(
                          child: Text('Tidak ada pegawai terdaftar.'),
                        );
                      }

                      final users = snapshot.data!;

                      return CupertinoScrollbar(
                        child: ListView.builder(
                          itemCount: users.length,
                          itemBuilder: (context, index) => CupertinoListTile(
                            leading: const Icon(CupertinoIcons.person_fill, color: CupertinoColors.activeGreen),
                            title: Text(users[index]['display_name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text(users[index]['email']),
                            trailing: CupertinoButton(
                              padding: EdgeInsets.zero,
                              onPressed: () => _showChangeDepartemenDialog(context, users[index]['id']),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(users[index]['departemen'] ?? "Belum Ada"),
                                  const Icon(CupertinoIcons.chevron_down, size: 16)
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  int _selectedIndex = 0; // Untuk menyimpan index tampilan
}

extension on PostgrestList {
  get count => null;
}
