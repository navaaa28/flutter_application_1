import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ManajemenUserPage extends StatefulWidget {
  const ManajemenUserPage({super.key});

  @override
  State<ManajemenUserPage> createState() => _ManajemenUserPageState();
}

class _ManajemenUserPageState extends State<ManajemenUserPage> {
  late Future<List<Map<String, dynamic>>> _usersFuture;

  @override
  void initState() {
    super.initState();
    _usersFuture = _fetchUsers();
  }

  Future<List<Map<String, dynamic>>> _fetchUsers() async {
    final response = await Supabase.instance.client
        .from('users')
        .select('id, display_name, email, role, profile_url')
        .order('created_at', ascending: false);
    return response;
  }

  Future<void> _deleteUser(String userId) async {
    try {
      // Menghapus pengguna dari tabel `users`
      await Supabase.instance.client.from('users').delete().eq('id', userId);

      // Menghapus pengguna dari sistem autentikasi
      await Supabase.instance.client.auth.admin.deleteUser(userId);

      // Memperbarui daftar pengguna setelah penghapusan
      setState(() {
        _usersFuture = _fetchUsers();
      });
    } catch (error) {
      print('Gagal menghapus pengguna: $error');
    }
  }

  Future<void> _showDeleteUserDialog(BuildContext context, String userId) async {
    return showDialog(
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          title: const Text('Hapus Akun'),
          content: const Text('Apakah Anda yakin ingin menghapus akun ini?'),
          actions: [
            CupertinoDialogAction(
              child: const Text('Batal'),
              onPressed: () => Navigator.pop(context),
            ),
            CupertinoDialogAction(
              child: const Text('Hapus'),
              isDestructiveAction: true,
              onPressed: () async {
                await _deleteUser(userId);
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Manajemen Pengguna', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        backgroundColor: CupertinoColors.systemBlue,
      ),
      child: Container(
        color: CupertinoColors.systemGrey6,
        child: FutureBuilder(
          future: _usersFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CupertinoActivityIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text('Terjadi kesalahan: ${snapshot.error}'));
            }

            final users = snapshot.data as List<Map<String, dynamic>>;

            return ListView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: users.length,
              itemBuilder: (context, index) => Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(10),
                  leading: CircleAvatar(
                    backgroundImage: users[index]['profile_url'] != null
                        ? NetworkImage(users[index]['profile_url'])
                        : const AssetImage('images/logo.png') as ImageProvider,
                  ),
                  title: Text(users[index]['display_name'], style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(users[index]['email']),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: CupertinoColors.systemGrey4,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(users[index]['role'], style: TextStyle(fontSize: 12)),
                      ),
                      const SizedBox(width: 10),
                      IconButton(
                        icon: const Icon(CupertinoIcons.trash, color: CupertinoColors.destructiveRed),
                        onPressed: () => _showDeleteUserDialog(context, users[index]['id']),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}