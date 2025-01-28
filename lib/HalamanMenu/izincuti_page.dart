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
  DateTime? selectedDate;
  final TextEditingController reasonController = TextEditingController();
  String? displayName;

  @override
  void initState() {
    super.initState();
    _fetchDisplayName();
  }

  Future<void> _fetchDisplayName() async {
    final user = supabase.auth.currentUser;
    if (user != null) {
      setState(() {
        displayName = user.userMetadata?['display_name'] ?? 'Pengguna';
      });
    } else {
      setState(() {
        displayName = 'Pengguna';
      });
    }
  }

  void _selectDate(BuildContext context) {
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
                      selectedDate = newDate;
                    });
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  CupertinoButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Batal'),
                  ),
                  CupertinoButton(
                    onPressed: () {
                      Navigator.pop(context);
                      setState(() {});
                    },
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

Future<void> _submitForm() async {
  if (selectedDate == null || reasonController.text.isEmpty) {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: const Text('Form Tidak Lengkap'),
          content: const Text(
              'Harap memilih tanggal dan mengisi alasan untuk izin/cuti.'),
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
    return;
  }

  final user = supabase.auth.currentUser;
  if (user == null) {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: const Text('Tidak Masuk'),
          content: const Text('Silakan masuk untuk mengirim form.'),
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
    return;
  }

  final formattedDate =
      "${selectedDate!.year}-${selectedDate!.month}-${selectedDate!.day}";

  // Cek berapa kali izin cuti sudah diajukan pada bulan ini
  final startOfMonth = DateTime(selectedDate!.year, selectedDate!.month, 1);
  final endOfMonth = DateTime(selectedDate!.year, selectedDate!.month + 1, 0);

  // Menggunakan query untuk mendapatkan izin yang ada pada bulan tersebut
  final response = await supabase
      .from('izin_cuti')
      .select()
      .eq('user_id', user.id)
      .gte('tanggal', startOfMonth.toIso8601String())
      .lte('tanggal', endOfMonth.toIso8601String());

  // Menghitung jumlah izin yang ditemukan
  if (response != null && response is List && response.length >= 3) {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: const Text('Batas Izin Cuti Tercapai'),
          content: const Text(
              'Anda hanya bisa mengajukan izin cuti maksimal 3 kali dalam 1 bulan.'),
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
    return;
  }

  try {
    await supabase.from('izin_cuti').insert({
      'user_id': user.id,
      'tanggal': formattedDate,
      'alasan': reasonController.text,
      'display_name': displayName ?? 'Pengguna',
    });

    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: const Text('Berhasil'),
          content: const Text('Form izin/cuti berhasil dikirim.'),
          actions: [
            CupertinoDialogAction(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  } catch (e) {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: const Text('Gagal'),
          content: Text('Terjadi kesalahan: $e'),
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
}

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(displayName ?? 'Form Izin / Cuti'),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Selamat datang, ${displayName ?? 'Pengguna'}!',
                style: const TextStyle(fontSize: 16, color: CupertinoColors.activeBlue),
              ),
              const SizedBox(height: 16),
              const Text(
                'Pilih Tanggal:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () => _selectDate(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  decoration: BoxDecoration(
                    color: CupertinoColors.systemGrey4,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    selectedDate == null
                        ? 'Pilih Tanggal'
                        : "${selectedDate!.day}-${selectedDate!.month}-${selectedDate!.year}",
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Alasan:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              CupertinoTextField(
                controller: reasonController,
                placeholder: 'Masukkan alasan izin/cuti',
                maxLines: 3,
                decoration: BoxDecoration(
                  border: Border.all(color: CupertinoColors.systemGrey),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              const Spacer(),
              CupertinoButton.filled(
                onPressed: _submitForm,
                child: const Text('Kirim Permintaan'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
