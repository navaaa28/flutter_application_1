import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
  String selectedDepartment = 'Ketua'; // Default jabatan
  final List<String> departments = [
    'Ketua',
    'Wakil Ketua',
    'Sekretaris',
    'Bendahara',
    'Koordinator Divisi',
    'Sekretaris Divisi',
    'Anggota Divisi',
    'Staff Ahli Internal',
    'Staff Ahli Eksternal',
    'Humas'
  ];

  @override
  void initState() {
    super.initState();
    _fetchDisplayName();
  }

  Future<void> _fetchDisplayName() async {
    final user = supabase.auth.currentUser;
    if (user != null) {
      setState(() {
        displayName = user.userMetadata?['display_name'] ?? user.email ?? 'Pengguna';
      });
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

  void _selectDepartment(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 300,
          color: Colors.white,
          child: Column(
            children: [
              Expanded(
                child: CupertinoPicker(
                  itemExtent: 32.0,
                  onSelectedItemChanged: (int index) {
                    setState(() {
                      selectedDepartment = departments[index];
                    });
                  },
                  children: departments.map((String department) => Text(department)).toList(),
                ),
              ),
              CupertinoButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Selesai'),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _submitForm() async {
    if (selectedStartDate == null || selectedEndDate == null || reasonController.text.isEmpty) {
      _showDialog('Form Tidak Lengkap', 'Harap mengisi semua kolom yang diperlukan.');
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
        'departemen': selectedDepartment,
        'kontak_darurat': contactController.text,
        'display_name': displayName,
        'status': 'Menunggu Persetujuan Atasan', // Status default menunggu
      });

      _showDialog('Berhasil', 'Form izin/cuti berhasil dikirim. Menunggu persetujuan admin.', isSuccess: true);
    } catch (e) {
      _showDialog('Gagal', 'Terjadi kesalahan: ${e.toString()}');
    }
  }

  void _showDialog(String title, String content, {bool isSuccess = false}) {
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
                if (isSuccess) Navigator.pop(context);
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
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('Perizinan Cuti'),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 255, 255, 255),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Selamat datang, $displayName!',
                  style: const TextStyle(fontSize: 18, color: CupertinoColors.white),
                ),
              ),
              const SizedBox(height: 20),
              _buildSection('Nama Lengkap:', displayName),
              const SizedBox(height: 20),
              _buildSection('Jabatan:', selectedDepartment, onTap: () => _selectDepartment(context)),
              const SizedBox(height: 20),
              _buildSection('Tanggal Cuti/Izin Mulai:', selectedStartDate == null ? 'Pilih Tanggal' : '${selectedStartDate!.day}-${selectedStartDate!.month}-${selectedStartDate!.year}', onTap: () => _selectDate(context, true)),
              const SizedBox(height: 20),
              _buildSection('Tanggal Cuti/Izin Selesai:', selectedEndDate == null ? 'Pilih Tanggal' : '${selectedEndDate!.day}-${selectedEndDate!.month}-${selectedEndDate!.year}', onTap: () => _selectDate(context, false)),
              const SizedBox(height: 20),
              _buildSection('Alasan Cuti/Izin:', reasonController.text, controller: reasonController, placeholder: 'Masukkan alasan'),
              const SizedBox(height: 20),
              _buildSection('Kontak Darurat (Opsional):', contactController.text, controller: contactController, placeholder: 'Masukkan kontak darurat'),
              const SizedBox(height: 20),
              Center(
                child: CupertinoButton.filled(
                  onPressed: _submitForm,
                  child: const Text('Kirim Permintaan'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(String label, String content, {TextEditingController? controller, String? placeholder, Function()? onTap}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: CupertinoColors.systemGrey5,
              borderRadius: BorderRadius.circular(8),
            ),
            child: controller == null
                ? Text(content, style: const TextStyle(fontSize: 16))
                : CupertinoTextField(
                    controller: controller,
                    placeholder: placeholder,
                  ),
          ),
        ),
      ],
    );
  }
}
