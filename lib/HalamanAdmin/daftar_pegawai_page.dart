import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PegawaiScreen extends StatefulWidget {
  const PegawaiScreen({super.key});

  @override
  State<PegawaiScreen> createState() => _PegawaiScreenState();
}

class _PegawaiScreenState extends State<PegawaiScreen> {
  List<Map<String, dynamic>> roleList = [];
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
    fetchRoles();
  }

  Future<void> fetchRoles() async {
    final supabase = Supabase.instance.client;

    try {
      final response = await supabase
      .from('users')
      .select()
      .neq('role', 'ADMIN') // Menampilkan selain ADMIN
      .order('display_name', ascending: true);

      setState(() {
        roleList = List<Map<String, dynamic>>.from(response);
      });
    } catch (e) {
      _showErrorDialog('Gagal memuat data pegawai: $e');
    }
  }

  void _showErrorDialog(String error) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text('Error'),
        content: Text(error),
        actions: [
          CupertinoDialogAction(
            child: Text('OK'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

void _showDetailPegawai(Map<String, dynamic> pegawai) {
  TextEditingController salaryController = TextEditingController(
    text: pegawai['salary']?.toString() ?? '',
  );
  
  String selectedRole = pegawai['role'] ?? 'STAFF';
  String selectedDepartemen = pegawai['departemen'] ?? 'HR';

  List<String> roles = ['STAFF', 'MANAGER', 'SUPERVISOR', 'ADMIN'];
  List<String> departemens = ['HR', 'IT', 'FINANCE', 'MARKETING', 'SALES'];
  
  Navigator.push(
    context,
    CupertinoPageRoute(
      builder: (context) => CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          middle: Text(
            'Detail Pegawai',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
            ),
          ),
          backgroundColor: primaryColor,
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.grey[200],
                  backgroundImage: pegawai['profile_url'] != null && 
                      pegawai['profile_url'].isNotEmpty
                      ? NetworkImage(pegawai['profile_url'])
                      : null,
                  child: pegawai['profile_url'] == null || 
                      pegawai['profile_url'].isEmpty
                      ? Icon(CupertinoIcons.person, size: 60, color: Colors.grey)
                      : null,
                ),
                SizedBox(height: 20),
                _buildDetailItem('Nama Lengkap', pegawai['display_name'] ?? 'N/A'),
                _buildDetailItem('ID Pegawai', pegawai['id']?.toUpperCase() ?? 'N/A'),
                _buildDetailItem('Email', pegawai['email'] ?? 'N/A'),
                _buildDetailItem('Nomor Telepon', pegawai['phone'] ?? 'N/A'),
                
                SizedBox(height: 10),
                Text('Jabatan:', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600)),
                CupertinoButton(
                  child: Text(selectedRole),
                  onPressed: () {
                    _showPicker(context, roles, selectedRole, (value) {
                      selectedRole = value;
                    });
                  },
                ),
                
                SizedBox(height: 10),
                Text('Departemen:', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600)),
                CupertinoButton(
                  child: Text(selectedDepartemen),
                  onPressed: () {
                    _showPicker(context, departemens, selectedDepartemen, (value) {
                      selectedDepartemen = value;
                    });
                  },
                ),
                
                SizedBox(height: 20),
                Text('Gaji:', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600)),
                CupertinoTextField(
                  controller: salaryController,
                  keyboardType: TextInputType.number,
                  placeholder: 'Masukkan gaji',
                ),
                SizedBox(height: 10),
                CupertinoButton.filled(
                  child: Text('Update Data'),
                  onPressed: () => _updateData(pegawai['id'], salaryController.text, selectedRole, selectedDepartemen),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

void _showPicker(BuildContext context, List<String> items, String selectedValue, Function(String) onSelected) {
  showCupertinoModalPopup(
    context: context,
    builder: (BuildContext context) => Container(
      height: 250,
      color: Colors.white,
      child: Column(
        children: [
          Expanded(
            child: CupertinoPicker(
              backgroundColor: Colors.white,
              itemExtent: 32,
              onSelectedItemChanged: (index) {
                onSelected(items[index]);
              },
              children: items.map((e) => Text(e)).toList(),
            ),
          ),
          CupertinoButton(
            child: Text('Pilih'),
            onPressed: () => Navigator.pop(context),
          )
        ],
      ),
    ),
  );
}

Future<void> _updateData(String id, String salary, String role, String departemen) async {
  final supabase = Supabase.instance.client;
  try {
    await supabase.from('users').update({
      'salary': int.parse(salary),
      'role': role,
      'departemen': departemen
    }).eq('id', id);
    fetchRoles();
    Navigator.pop(context);
  } catch (e) {
    _showErrorDialog('Gagal memperbarui data: $e');
  }
}


Widget _buildDetailItem(String title, String value) {
  return Container(
    width: double.infinity,
    margin: EdgeInsets.symmetric(vertical: 8),
    padding: EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: CupertinoColors.systemBackground,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: CupertinoColors.systemGrey.withOpacity(0.2),
          blurRadius: 6,
          offset: Offset(0, 2),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: CupertinoColors.secondaryLabel,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 16,
            color: CupertinoColors.label,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    ),
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
      home: CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          middle: Text(
            'Pegawai',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              color: Colors.white,
              decoration:TextDecoration.none
            ),
          ),
          backgroundColor: primaryColor,
        ),
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: fetchRoles,
            child: SingleChildScrollView(
              physics: AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      "Daftar Pegawai",
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: primaryColor,
                        decoration:TextDecoration.none
                      ),
                    ),
                  ),
                  roleList.isEmpty
                      ? Center(
                          child: Padding(
                            padding: EdgeInsets.all(20),
                            child: Text(
                              "Belum ada data pegawai",
                              style: GoogleFonts.poppins(
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: roleList.length,
                          itemBuilder: (context, index) {
                            final role = roleList[index];
                            return GestureDetector(
                              onTap: () => _showDetailPegawai(role),
                              child: Container(
                                margin: EdgeInsets.symmetric(
                                  vertical: 8.0,
                                  horizontal: 16.0,
                                ),
                                decoration: BoxDecoration(
                                  gradient: primaryGradient,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: accentColor.withOpacity(0.2),
                                      blurRadius: 8,
                                      offset: Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 30,
                                        backgroundColor: Colors.white,
                                        backgroundImage: role['profile_url'] != null && role['profile_url'].isNotEmpty
                                            ? NetworkImage(role['profile_url'])
                                            : null,
                                        child: role['profile_url'] == null || role['profile_url'].isEmpty
                                            ? Icon(Icons.person, color: primaryColor)
                                            : null,
                                      ),
                                      SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              role['display_name'] ?? 'N/A',
                                              style: GoogleFonts.poppins(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.white,
                                                decoration:TextDecoration.none
                                              ),
                                            ),
                                            SizedBox(height: 4),
                                            Text(
                                              role['departemen']?.toUpperCase() ?? 'N/A',
                                              style: GoogleFonts.poppins(
                                                fontSize: 12,
                                                color: Colors.white.withOpacity(0.9),
                                                decoration:TextDecoration.none
                                              ),
                                            ),
                                            SizedBox(height: 4),
                                            Text(
                                              role['email'] ?? 'N/A',
                                              style: GoogleFonts.poppins(
                                                fontSize: 12,
                                                color: Colors.white.withOpacity(0.9),
                                                decoration:TextDecoration.none
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ),
                                      Icon(
                                        Icons.chevron_right,
                                        color: Colors.white,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}