import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PegawaiScreen extends StatefulWidget {

  @override
  State<PegawaiScreen> createState() => _PegawaiScreenState();
}

class _PegawaiScreenState extends State<PegawaiScreen> {
  List<Map<String, dynamic>> roleList = [];

  @override
  void initState() {
    super.initState();
    fetchRoles();
    
  }

  Future<void> fetchRoles() async {
    final supabase = Supabase.instance.client;

    try {
      final response = await supabase
          .from('users')
          .select()
          .eq('role', 'pegawai')
          .order('display_name', ascending: false);

      print('Fetched role data: $response');

      if (response != null && response.isNotEmpty) {
        setState(() {
          roleList = List<Map<String, dynamic>>.from(response);
        });
      } else {
        setState(() {
          roleList = [];
        });
        print('No role data found.');
      }
    } catch (e) {
      print('Error fetching activities: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Pegawai'),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  "Data Para Pegawai",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              roleList.isEmpty
                  ? Center(child: Text("Tidak ada data absensi"))
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: roleList.length,
                      itemBuilder: (context, index) {
                        final role = roleList[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(
                            vertical: 8.0,
                            horizontal: 16.0,
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.grey[200],
                              backgroundImage: role['profile_url'] != null && role['profile_url'].isNotEmpty
                                  ? NetworkImage(role['profile_url']) // Gunakan URL langsung dari profile_url
                                  : null,
                              child: role['profile_url'] == null || role['profile_url'].isEmpty
                                  ? Icon(Icons.person, color: Colors.grey)
                                  : null,
                            ),
                            title: Text(
                              role['id']?.toUpperCase() ?? 'N/A',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Nama: ${role['display_name'] ?? 'N/A'}"),
                                Text("Email: ${role['email'] ?? 'N/A'}"),
                                Text("Phone: ${role['phone'] ?? 'N/A'}"),
                                Text("Jabatan: ${role['role']?.toUpperCase() ?? 'N/A'}"),
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