import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://YOUR_SUPABASE_URL',
    anonKey: 'YOUR_SUPABASE_ANON_KEY',
  );

  runApp(
    CupertinoApp(
      home: LemburPage(),
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: [
        Locale('id', 'ID'), // Bahasa Indonesia
        Locale('en', 'US'), // Bahasa Inggris
      ],
    ),
  );
}

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

  DateTime? _startTime;
  DateTime? _endTime;

  Future<void> _pickDateTimeDirectly(TextEditingController controller, {required bool isStart}) async {
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
                child: const Text('Pilih'),
                onPressed: () {
                  Navigator.pop(context);
                  setState(() {
                    if (isStart) {
                      _startTime = selectedDate;
                    } else {
                      _endTime = selectedDate;
                    }
                  });
                  controller.text = DateFormat('yyyy-MM-dd HH:mm').format(selectedDate);
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
      'waktu_mulai': _startTime!.toIso8601String(),
      'waktu_selesai': _endTime!.toIso8601String(),
      'durasi': _endTime!.difference(_startTime!).inMinutes,
      'catatan': _notesController.text,
    });

    print('Lembur berhasil disimpan.'); // Debugging
    _showMessage('Lembur berhasil disimpan.');
    
    // Jangan langsung pop, biarkan user melihat pesan
    // Navigator.pop(context); // Hapus atau pindahkan setelah delay
  } catch (e) {
    print('Gagal menyimpan lembur: ${e.toString()}'); // Debugging
    _showMessage('Gagal menyimpan lembur: ${e.toString()}');
  }
}


  void _showMessage(String message) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
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

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Lembur'),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CupertinoTextFormFieldRow(
                  controller: _startTimeController,
                  placeholder: 'Waktu Mulai',
                  readOnly: true,
                  onTap: () => _pickDateTimeDirectly(_startTimeController, isStart: true),
                  validator: (value) => value == null || value.isEmpty ? 'Harap pilih waktu mulai.' : null,
                ),
                const SizedBox(height: 8),
                Text(
                  _startTime == null
                      ? 'Waktu mulai belum dipilih'
                      : 'Waktu Mulai: ${DateFormat('yyyy-MM-dd HH:mm').format(_startTime!)}',
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 16),
                CupertinoTextFormFieldRow(
                  controller: _endTimeController,
                  placeholder: 'Waktu Selesai',
                  readOnly: true,
                  onTap: () => _pickDateTimeDirectly(_endTimeController, isStart: false),
                  validator: (value) => value == null || value.isEmpty ? 'Harap pilih waktu selesai.' : null,
                ),
                const SizedBox(height: 8),
                Text(
                  _endTime == null
                      ? 'Waktu selesai belum dipilih'
                      : 'Waktu Selesai: ${DateFormat('yyyy-MM-dd HH:mm').format(_endTime!)}',
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 16),
                CupertinoTextFormFieldRow(
                  controller: _notesController,
                  placeholder: 'Catatan (Opsional)',
                  maxLines: 3,
                ),
                const SizedBox(height: 8),
                CupertinoButton.filled(
                  child: const Text('Simpan Lembur'),
                  onPressed: _saveOvertime,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
