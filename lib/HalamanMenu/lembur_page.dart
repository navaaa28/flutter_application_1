import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

class LemburPage extends StatefulWidget {
  const LemburPage({super.key});

  @override
  _LemburPageState createState() => _LemburPageState();
}

class _LemburPageState extends State<LemburPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _startTimeController = TextEditingController();
  final TextEditingController _endTimeController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  String role = '';
  String displayName = '';
  DateTime? _startTime;
  DateTime? _endTime;
  final Color primaryColor = Color(0xFF2A2D7C);
  final Color accentColor = Color(0xFF00C2FF);

  @override
  void initState() {
    super.initState();
    _fetchAll();
  }

  Future<void> _fetchAll() async {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;

    if (user == null) {
      print('User not logged in');
      return;
    }

    try {
      final response = await supabase
          .from('users')
          .select('role, display_name')
          .eq('id', user.id)
          .single();
      setState(() {
        role = response['role'];
        displayName = response['display_name'];
      });
    } catch (e) {
      print('$e');
    }
  }

  Future<void> _pickDateTimeDirectly(TextEditingController controller,
      {required bool isStart}) async {
    DateTime selectedDate = DateTime.now();

    await showCupertinoModalPopup(
      context: context,
      builder: (context) {
        return Container(
          height: 300,
          color: Colors.white,
          child: Column(
            children: [
              SizedBox(
                height: 200,
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.dateAndTime,
                  initialDateTime: selectedDate,
                  use24hFormat: true,
                  onDateTimeChanged: (DateTime dateTime) {
                    selectedDate = dateTime;
                  },
                ),
              ),
              CupertinoButton(
                child: Text(
                  'Pilih',
                  style: GoogleFonts.poppins(
                    color: primaryColor,
                    decoration: TextDecoration.none,
                  ),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  setState(() {
                    if (isStart) {
                      _startTime = selectedDate;
                    } else {
                      _endTime = selectedDate;
                    }
                  });
                  controller.text =
                      DateFormat('yyyy-MM-dd HH:mm').format(selectedDate);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _saveOvertime() async {
    if (!_formKey.currentState!.validate()) return;

    if (_startTime == null || _endTime == null) {
      _showMessage('Waktu mulai dan selesai harus diisi.');
      return;
    }

    if (_endTime!.isBefore(_startTime!)) {
      _showMessage('Waktu selesai tidak boleh lebih awal dari waktu mulai.');
      return;
    }

    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;

    if (user == null) {
      _showMessage('Pengguna tidak ditemukan.');
      return;
    }

    try {
      await supabase.from('lembur').insert({
        'user_id': user.id,
        'display_name': displayName,
        'role': role,
        'waktu_mulai': _startTime!.toIso8601String(),
        'waktu_selesai': _endTime!.toIso8601String(),
        'durasi': _endTime!.difference(_startTime!).inMinutes,
        'catatan': _notesController.text,
        'status': 'Menunggu Persetujuan Atasan'
      });

      _showMessage('Lembur berhasil disimpan. Menunggu Persetujuan Atasan', isSuccess: true);
    } catch (e) {
      _showMessage('Gagal menyimpan lembur: ${e.toString()}');
    }
  }

  void _showMessage(String message, {bool isSuccess = false}) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text(
          isSuccess ? 'Sukses' : 'Peringatan',
          style: GoogleFonts.poppins(
            color: primaryColor,
            decoration: TextDecoration.none,
          ),
        ),
        content: Text(
          message,
          style: GoogleFonts.poppins(
            decoration: TextDecoration.none,
          ),
        ),
        actions: [
          CupertinoDialogAction(
            child: Text(
              'OK',
              style: GoogleFonts.poppins(
                color: primaryColor,
                decoration: TextDecoration.none,
              ),
            ),
            onPressed: () {
              Navigator.pop(context);
              if (isSuccess) Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(
          'Pengajuan Lembur',
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
                const SizedBox(height: 25),
                _buildFormSection(),
                const SizedBox(height: 30),
                _buildSubmitButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Formulir Lembur',
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: primaryColor,
            decoration: TextDecoration.none,
          ),
        ),
        Text(
          'Silahkan isi formulir berikut untuk mengajukan lembur',
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

  Widget _buildFormSection() {
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
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            _buildDateTimePicker(
              label: 'Waktu Mulai',
              controller: _startTimeController,
              isStart: true,
            ),
            SizedBox(height: 20),
            _buildDateTimePicker(
              label: 'Waktu Selesai',
              controller: _endTimeController,
              isStart: false,
            ),
            SizedBox(height: 20),
            _buildNotesSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildDateTimePicker({
    required String label,
    required TextEditingController controller,
    required bool isStart,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
            decoration: TextDecoration.none,
          ),
        ),
        SizedBox(height: 8),
        GestureDetector(
          onTap: () => _pickDateTimeDirectly(controller, isStart: isStart),
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
                  controller.text.isEmpty ? 'Pilih Waktu' : controller.text,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: controller.text.isEmpty
                        ? Colors.grey[400]
                        : primaryColor,
                    decoration: TextDecoration.none,
                  ),
                ),
                Icon(
                  CupertinoIcons.clock,
                  color: primaryColor,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNotesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Catatan (Opsional)',
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
            decoration: TextDecoration.none,
          ),
        ),
        SizedBox(height: 8),
        CupertinoTextField(
          controller: _notesController,
          placeholder: 'Masukkan catatan tambahan...',
          style: GoogleFonts.poppins(
            fontSize: 14,
            decoration: TextDecoration.none,
          ),
          padding: EdgeInsets.all(16),
          maxLines: 3,
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
        onPressed: _saveOvertime,
        child: Text(
          'Simpan Lembur',
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