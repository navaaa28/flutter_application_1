import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TambahEditHapusPegawaiPage extends StatefulWidget {
  const TambahEditHapusPegawaiPage({Key? key}) : super(key: key);

  @override
  _TambahEditHapusPegawaiPageState createState() => _TambahEditHapusPegawaiPageState();
}

class _TambahEditHapusPegawaiPageState extends State<TambahEditHapusPegawaiPage> {
  final _supabase = Supabase.instance.client;
  List<Map<String, dynamic>> _employees = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchEmployees();
  }

  Future<void> _fetchEmployees() async {
    final response = await _supabase
        .from('users')
        .select('*')
        .eq('role', 'employee')
        .order('created_at', ascending: false);

    setState(() {
      _employees = List<Map<String, dynamic>>.from(response);
      _isLoading = false;
    });
  }

  void _showEmployeeForm({Map<String, dynamic>? employee}) {
    TextEditingController nameController = TextEditingController(text: employee?['display_name']);
    TextEditingController emailController = TextEditingController(text: employee?['email']);
    TextEditingController positionController = TextEditingController(text: employee?['position']);

    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text(employee == null ? 'Tambah Pegawai' : 'Edit Pegawai'),
        content: Column(
          children: [
            CupertinoTextField(
              controller: nameController,
              placeholder: 'Nama Lengkap',
              padding: const EdgeInsets.all(12),
            ),
            const SizedBox(height: 10),
            CupertinoTextField(
              controller: emailController,
              placeholder: 'Email',
              keyboardType: TextInputType.emailAddress,
              padding: const EdgeInsets.all(12),
            ),
            const SizedBox(height: 10),
            CupertinoTextField(
              controller: positionController,
              placeholder: 'Jabatan',
              padding: const EdgeInsets.all(12),
            ),
          ],
        ),
        actions: [
          CupertinoDialogAction(
            child: const Text('Batal'),
            onPressed: () => Navigator.pop(context),
          ),
          CupertinoDialogAction(
            child: const Text('Simpan'),
            onPressed: () async {
              if (employee == null) {
                await _supabase.from('users').insert({
                  'display_name': nameController.text,
                  'email': emailController.text,
                  'position': positionController.text,
                  'role': 'employee',
                });
              } else {
                await _supabase
                    .from('users')
                    .update({
                      'display_name': nameController.text,
                      'email': emailController.text,
                      'position': positionController.text,
                    })
                    .eq('id', employee['id']);
              }
              _fetchEmployees();
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  Future<void> _deleteEmployee(String id) async {
    await _supabase.from('users').delete().eq('id', id);
    _fetchEmployees();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(middle: Text('Kelola Pegawai')),
      child: SafeArea(
        child: Column(
          children: [
            CupertinoButton(
              child: const Text('Tambah Pegawai Baru'),
              onPressed: () => _showEmployeeForm(),
            ),
            Expanded(
              child: _isLoading
                  ? const Center(child: CupertinoActivityIndicator())
                  : ListView.builder(
                      itemCount: _employees.length,
                      itemBuilder: (context, index) {
                        final employee = _employees[index];
                        return CupertinoListTile(
                          title: Text(employee['display_name']),
                          subtitle: Text(employee['position']),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CupertinoButton(
                                child: const Icon(CupertinoIcons.pencil),
                                onPressed: () => _showEmployeeForm(employee: employee),
                              ),
                              CupertinoButton(
                                child: const Icon(CupertinoIcons.delete, color: Colors.red),
                                onPressed: () => _deleteEmployee(employee['id']),
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
    );
  }
}