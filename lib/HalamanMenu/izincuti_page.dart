import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

class IzinCutiPage extends StatefulWidget {
  const IzinCutiPage({Key? key}) : super(key: key);

  @override
  _IzinCutiPageState createState() => _IzinCutiPageState();
}

class _IzinCutiPageState extends State<IzinCutiPage> {
  final SupabaseClient supabase = Supabase.instance.client;
  DateTime? selectedStartDate;
  DateTime? selectedEndDate;
  final TextEditingController reasonController = TextEditingController();
  final TextEditingController contactController = TextEditingController();
  String displayName = 'Pengguna';
  String role = '';
  final Color primaryColor = Color(0xFF2A2D7C);
  final Color accentColor = Color(0xFF00C2FF);
  final LinearGradient primaryGradient = LinearGradient(
      colors: [Color(0xFF2A2D7C), Color(0xFF00C2FF)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight);
  String? selectedType;
  List<String> types = ['Izin', 'Cuti', 'Sakit'];

  void _showTypePicker(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 200,
          color: Colors.white,
          child: Column(
            children: [
              SizedBox(
                height: 100,
                child: CupertinoPicker(
                  itemExtent: 40,
                  onSelectedItemChanged: (int index) {
                    setState(() {
                      selectedType = types[index];
                    });
                  },
                  children: types.map((String type) {
                    return Center(
                      child: Text(
                        type,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: primaryColor,
                          decoration: TextDecoration.none,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  CupertinoButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Batal'),
                  ),
                  CupertinoButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Pilih'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _fetchDisplayName();
    _fetchRole();
  }

  Future<void> _fetchRole() async {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;

    if (user == null) {
      print('User not logged in');
      return;
    }

    try {
      final response = await supabase
          .from('users')
          .select('role')
          .eq('id', user.id)
          .single();
      setState(() {
        role = response['role'];
      });
    } catch (e) {
      print('$e');
    }
  }

  Future<void> _fetchDisplayName() async {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;

    if (user == null) {
      print('User not logged in');
      return;
    }

    try {
      final response = await supabase
          .from('users')
          .select('display_name')
          .eq('id', user.id)
          .single();
      setState(() {
        displayName = response['display_name'];
      });
    } catch (e) {
      print('$e');
    }
  }

  void _selectDate(BuildContext context, bool isStartDate) {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 300,
          color: Colors.white,
          child: Column(
            children: [
              SizedBox(
                height: 200,
                child: CupertinoDatePicker(
                  initialDateTime: DateTime.now(),
                  mode: CupertinoDatePickerMode.date,
                  onDateTimeChanged: (DateTime newDate) {
                    setState(() {
                      if (isStartDate) {
                        selectedStartDate = newDate;
                      } else {
                        selectedEndDate = newDate;
                      }
                    });
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  CupertinoButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Batal'),
                  ),
                  CupertinoButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Pilih'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // Kirim form dan animasi notifikasi sukses
  Future<void> _submitForm() async {
  if (selectedStartDate == null ||
      selectedEndDate == null ||
      reasonController.text.isEmpty ||
      selectedType == null) { // Tambahkan validasi untuk tipe izin
    _showDialog(
        'Form Tidak Lengkap', 'Harap mengisi semua kolom yang diperlukan.');
    return;
  }

  final user = supabase.auth.currentUser;
  if (user == null) {
    _showDialog('Tidak Masuk', 'Silakan masuk untuk mengirim form.');
    return;
  }

  final formattedStartDate = selectedStartDate!.toIso8601String();
  final formattedEndDate = selectedEndDate!.toIso8601String();

  try {
    await supabase.from('izin_cuti').insert({
      'user_id': user.id,
      'tanggal_mulai': formattedStartDate,
      'tanggal_selesai': formattedEndDate,
      'alasan': reasonController.text,
      'departemen': role,
      'kontak_darurat': contactController.text,
      'display_name': displayName,
      'status': 'Menunggu Persetujuan Atasan',
      'tipe_izin': selectedType, // Tambahkan tipe izin
    });

    // Animasi transisi sukses
    _showDialog('Berhasil',
        'Form izin/cuti berhasil dikirim. Menunggu persetujuan admin.',
        isSuccess: true);
  } catch (e) {
    _showDialog('Gagal', 'Terjadi kesalahan: ${e.toString()}');
  }
}

  void _showDialog(String title, String content, {bool isSuccess = false}) {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Text(
            title,
            style: GoogleFonts.poppins(
              decoration: TextDecoration.none,
            ),
          ),
          content: Text(
            content,
            style: GoogleFonts.poppins(
              decoration: TextDecoration.none,
            ),
          ),
          actions: [
            CupertinoDialogAction(
              onPressed: () {
                Navigator.pop(context);
                if (isSuccess) Navigator.pop(context);
              },
              child: Text(
                'OK',
                style: GoogleFonts.poppins(
                  decoration: TextDecoration.none,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(
          'Permohonan Cuti',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            decoration: TextDecoration.none,
          ),
        ),
        backgroundColor: primaryColor,
        border: null,
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, Color(0xFFF0F4FF)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeaderSection(),
                const SizedBox(height: 20),
                _buildUserInfoSection(),
                const SizedBox(height: 30),
                _buildFormSections(),
                const SizedBox(height: 30),
                _buildSubmitButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTypeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tipe Izin',
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
            decoration: TextDecoration.none,
          ),
        ),
        SizedBox(height: 8),
        GestureDetector(
          onTap: () => _showTypePicker(context),
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Pilih Tipe Izin',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey[600],
                    decoration: TextDecoration.none,
                  ),
                ),
                Text(
                  selectedType ?? 'Pilih',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: selectedType != null ? primaryColor : Colors.grey[400],
                    fontWeight: FontWeight.w500,
                    decoration: TextDecoration.none,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Formulir Permohonan',
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: primaryColor,
            decoration: TextDecoration.none,
          ),
        ),
        Text(
          'Silahkan isi formulir berikut untuk mengajukan cuti/izin',
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: Colors.grey[600],
            decoration: TextDecoration.none,
          ),
        ),
      ],
    );
  }

  Widget _buildUserInfoSection() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildInfoRow('Nama Lengkap', displayName),
          Divider(height: 20),
          _buildInfoRow('Jabatan', role),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: Colors.grey[600],
            decoration: TextDecoration.none,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: primaryColor,
            decoration: TextDecoration.none,
          ),
        ),
      ],
    );
  }

  Widget _buildFormSections() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildTypeSection(),
          SizedBox(height: 20),
          _buildDatePickerSection(),
          SizedBox(height: 20),
          _buildReasonSection(),
          SizedBox(height: 20),
          _buildContactSection(),
        ],
      ),
    );
  }

  Widget _buildDatePickerSection() {
    return Column(
      children: [
        _buildDatePickerItem(
          label: 'Tanggal Mulai',
          date: selectedStartDate,
          onTap: () => _selectDate(context, true),
        ),
        SizedBox(height: 15),
        _buildDatePickerItem(
          label: 'Tanggal Selesai',
          date: selectedEndDate,
          onTap: () => _selectDate(context, false),
        ),
      ],
    );
  }

  Widget _buildDatePickerItem(
      {required String label, DateTime? date, required Function() onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey[600],
                decoration: TextDecoration.none,
              ),
            ),
            Text(
              date != null
                  ? '${date.day}/${date.month}/${date.year}'
                  : 'Pilih Tanggal',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: date != null ? primaryColor : Colors.grey[400],
                fontWeight: FontWeight.w500,
                decoration: TextDecoration.none,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReasonSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Alasan Cuti/Izin',
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
            decoration: TextDecoration.none,
          ),
        ),
        SizedBox(height: 8),
        CupertinoTextField(
          controller: reasonController,
          placeholder: 'Masukkan alasan lengkap...',
          style: GoogleFonts.poppins(
            fontSize: 14,
            decoration: TextDecoration.none,
          ),
          padding: EdgeInsets.all(16),
          maxLines: 4,
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[200]!),
          ),
          placeholderStyle: GoogleFonts.poppins(
            fontSize: 14,
            color: Colors.grey[400],
            fontStyle: FontStyle.italic,
            decoration: TextDecoration.none,
          ),
        ),
      ],
    );
  }

  Widget _buildContactSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Kontak Darurat (Opsional)',
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
            decoration: TextDecoration.none,
          ),
        ),
        SizedBox(height: 8),
        CupertinoTextField(
          controller: contactController,
          placeholder: 'Masukkan kontak darurat...',
          style: GoogleFonts.poppins(
            fontSize: 14,
            decoration: TextDecoration.none,
          ),
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[200]!),
          ),
          placeholderStyle: GoogleFonts.poppins(
            fontSize: 14,
            color: Colors.grey[400],
            fontStyle: FontStyle.italic,
            decoration: TextDecoration.none,
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: accentColor.withOpacity(0.3),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: CupertinoButton(
        padding: EdgeInsets.symmetric(vertical: 18, horizontal: 40),
        borderRadius: BorderRadius.circular(30),
        color: primaryColor,
        onPressed: _submitForm,
        child: Text(
          'Kirim Permohonan',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
            decoration: TextDecoration.none,
          ),
        ),
      ),
    );
  }
}