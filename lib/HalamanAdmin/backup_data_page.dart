import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:excel/excel.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:supabase_flutter/supabase_flutter.dart';

// Model untuk Absensi
class Hadir {
  final String displayName;
  final String fotoUrl;
  final String tanggal;
  final String lokasi;
  final String jenisAbsen;

  Hadir({
    required this.displayName,
    required this.fotoUrl,
    required this.tanggal,
    required this.lokasi,
    required this.jenisAbsen,
  });

  factory Hadir.fromJson(Map<String, dynamic> json) {
    return Hadir(
      displayName: json['display_name'] ?? 'Tanpa Nama',
      fotoUrl: json['foto_url'] ?? '',
      tanggal: json['tanggal'],
      lokasi: json['lokasi'] ?? 'Lokasi tidak tersedia',
      jenisAbsen: json['jenis_absen'] ?? 'masuk',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'display_name': displayName,
      'foto_url': fotoUrl,
      'tanggal': tanggal,
      'lokasi': lokasi,
      'jenis_absen': jenisAbsen,
    };
  }
}

// Model untuk Pegawai
class Pegawai {
  final String id;
  final String displayName;
  final String email;
  final String phone;
  final String role;
  final String departemen;
  final int salary;
  final String profileUrl;

  Pegawai({
    required this.id,
    required this.displayName,
    required this.email,
    required this.phone,
    required this.role,
    required this.departemen,
    required this.salary,
    required this.profileUrl,
  });

  factory Pegawai.fromJson(Map<String, dynamic> json) {
  return Pegawai(
    id: json['id'] ?? '',
    displayName: json['display_name'] ?? 'N/A',
    email: json['email'] ?? 'N/A',
    phone: json['phone'] ?? 'N/A',
    role: json['role'] ?? 'STAFF',
    departemen: json['departemen'] ?? 'HR',
    salary: (json['salary'] is int) ? json['salary'] : int.tryParse(json['salary'].toString()) ?? 0,
    profileUrl: json['profile_url'] ?? '',
  );
}


  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'display_name': displayName,
      'email': email,
      'phone': phone,
      'role': role,
      'departemen': departemen,
      'salary': salary,
      'profile_url': profileUrl,
    };
  }
}

// Model untuk Backup Data
class BackupData<T> {
  final int version;
  final List<T> items;

  BackupData({this.version = 1, required this.items});

  factory BackupData.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    return BackupData<T>(
      version: json['version'] ?? 1,
      items: (json['items'] as List).map((item) => fromJsonT(item)).toList(),
    );
  }

  Map<String, dynamic> toJson(Map<String, dynamic> Function(T) toJsonT) {
    return {
      'version': version,
      'items': items.map((item) => toJsonT(item)).toList(),
    };
  }
}

// Service untuk Backup
class BackupService {
  // Backup Absensi sebagai JSON
  static Future<File> saveBackupHadir(List<Hadir> items) async {
    final backupData = BackupData<Hadir>(items: items);
    final jsonData = backupData.toJson((item) => item.toJson());

    final downloadDir = Directory('/storage/emulated/0/Download');
    if (!await downloadDir.exists()) {
      await downloadDir.create(recursive: true);
    }

    final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
    final file = File('${downloadDir.path}/attendance_backup_$timestamp.json');

    return file.writeAsString(json.encode(jsonData));
  }

  // Backup Absensi sebagai Excel
  static Future<File> saveBackupHadirAsExcel(List<Hadir> items) async {
    final excel = Excel.createExcel();
    final sheet = excel['Sheet1'];

    // Header
    sheet.appendRow(['Nama', 'Tanggal', 'Lokasi', 'Status']);

    // Data
    for (var attendance in items) {
      sheet.appendRow([
        attendance.displayName,
        attendance.tanggal,
        attendance.lokasi,
        attendance.jenisAbsen == "masuk" ? "Masuk" : "Keluar",
      ]);
    }

    final downloadDir = Directory('/storage/emulated/0/Download');
    final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
    final file = File('${downloadDir.path}/attendance_backup_$timestamp.xlsx');

    await file.writeAsBytes(excel.encode()!);
    return file;
  }

  // Backup Absensi sebagai PDF
  static Future<File> saveBackupHadirAsPdf(List<Hadir> items) async {
    final pdfDocument = pw.Document();

    pdfDocument.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            children: [
              pw.Text('Attendance Backup', style: pw.TextStyle(fontSize: 24)),
              ...items.map((attendance) {
                return pw.Text(
                  'Name: ${attendance.displayName}, Date: ${attendance.tanggal}, Location: ${attendance.lokasi}, Status: ${attendance.jenisAbsen == "masuk" ? "Masuk" : "Keluar"}',
                  style: pw.TextStyle(fontSize: 12),
                );
              }).toList(),
            ],
          );
        },
      ),
    );

    final downloadDir = Directory('/storage/emulated/0/Download');
    final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
    final file = File('${downloadDir.path}/attendance_backup_$timestamp.pdf');

    await file.writeAsBytes(await pdfDocument.save());
    return file;
  }

  // Backup Pegawai sebagai JSON
  static Future<File> saveBackupPegawai(List<Pegawai> items) async {
    final backupData = BackupData<Pegawai>(items: items);
    final jsonData = backupData.toJson((item) => item.toJson());

    final downloadDir = Directory('/storage/emulated/0/Download');
    final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
    final file = File('${downloadDir.path}/pegawai_backup_$timestamp.json');

    return file.writeAsString(json.encode(jsonData));
  }

  // Backup Pegawai sebagai Excel
  static Future<File> saveBackupPegawaiAsExcel(List<Pegawai> items) async {
    final excel = Excel.createExcel();
    final sheet = excel['Sheet1'];

    // Header
    sheet.appendRow(['ID', 'Nama', 'Email', 'Telepon', 'Role', 'Departemen', 'Gaji']);

    // Data
    for (var pegawai in items) {
      sheet.appendRow([
        pegawai.id,
        pegawai.displayName,
        pegawai.email,
        pegawai.phone,
        pegawai.role,
        pegawai.departemen,
        pegawai.salary.toString(),
      ]);
    }

    final downloadDir = Directory('/storage/emulated/0/Download');
    final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
    final file = File('${downloadDir.path}/pegawai_backup_$timestamp.xlsx');

    await file.writeAsBytes(excel.encode()!);
    return file;
  }

  // Backup Pegawai sebagai PDF
  static Future<File> saveBackupPegawaiAsPdf(List<Pegawai> items) async {
    final pdfDocument = pw.Document();

    pdfDocument.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            children: [
              pw.Text('Daftar Pegawai', style: pw.TextStyle(fontSize: 24)),
              ...items.map((pegawai) {
                return pw.Text(
                  'ID: ${pegawai.id}, Nama: ${pegawai.displayName}, Email: ${pegawai.email}, Role: ${pegawai.role}',
                  style: pw.TextStyle(fontSize: 12),
                );
              }).toList(),
            ],
          );
        },
      ),
    );

    final downloadDir = Directory('/storage/emulated/0/Download');
    final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
    final file = File('${downloadDir.path}/pegawai_backup_$timestamp.pdf');

    await file.writeAsBytes(await pdfDocument.save());
    return file;
  }
}

// Halaman Backup Data
class BackupDataPage extends StatelessWidget {
  const BackupDataPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Backup Data', style: GoogleFonts.poppins(color: Colors.white)),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Backup Absensi
            _buildBackupSection(
              context,
              title: 'Backup Data Absensi',
              onJson: () => _backupAbsensiJson(context),
              onExcel: () =>_backupAbsensiExcel(context),
              onPdf: () => _backupAbsensiPdf(context),
            ),
            SizedBox(height: 20),
            // Backup Pegawai
            _buildBackupSection(
              context,
              title: 'Backup Data Pegawai',
              onJson: () =>_backupPegawaiJson(context),
              onExcel: () =>_backupPegawaiExcel(context),
              onPdf: () =>_backupPegawaiPdf(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackupSection(
    BuildContext context, {
    required String title,
    required VoidCallback onJson,
    required VoidCallback onExcel,
    required VoidCallback onPdf,
  }) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                IconButton(
                  icon: Icon(Icons.insert_drive_file, color: Colors.green),
                  onPressed: onJson,
                  tooltip: 'Simpan sebagai JSON',
                ),
                IconButton(
                  icon: Icon(Icons.table_chart, color: Colors.blue),
                  onPressed: onExcel,
                  tooltip: 'Simpan sebagai Excel',
                ),
                IconButton(
                  icon: Icon(Icons.picture_as_pdf, color: Colors.red),
                  onPressed: onPdf,
                  tooltip: 'Simpan sebagai PDF',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _backupAbsensiJson(BuildContext context) async {
  final supabase = Supabase.instance.client;
  final response = await supabase.from('absensi').select().order('tanggal', ascending: false);
  final absensiList = response.map((e) => Hadir.fromJson(e)).toList();

  await BackupService.saveBackupHadir(absensiList);
  _showSnackbar(context, 'Backup absensi JSON berhasil!');
}


  Future<void> _backupAbsensiExcel(BuildContext context) async {
    final supabase = Supabase.instance.client;
    final response = await supabase.from('absensi').select().order('tanggal', ascending: false);
    final absensiList = response.map((e) => Hadir.fromJson(e)).toList();

    await BackupService.saveBackupHadirAsExcel(absensiList);
    _showSnackbar(context, 'Backup absensi Excel berhasil!');
  }

  Future<void> _backupAbsensiPdf(BuildContext context) async {
    final supabase = Supabase.instance.client;
    final response = await supabase.from('absensi').select().order('tanggal', ascending: false);
    final absensiList = response.map((e) => Hadir.fromJson(e)).toList();

    await BackupService.saveBackupHadirAsPdf(absensiList);
    _showSnackbar(context, 'Backup absensi PDF berhasil!');
  }

  // Fungsi Backup Pegawai
  Future<void> _backupPegawaiJson(BuildContext context) async {
    final supabase = Supabase.instance.client;
    final response = await supabase.from('users').select().neq('role', 'admin');
    final pegawaiList = response.map((e) => Pegawai.fromJson(e)).toList();

    await BackupService.saveBackupPegawai(pegawaiList);
    _showSnackbar(context, 'Backup pegawai JSON berhasil!');
  }

  Future<void> _backupPegawaiExcel(BuildContext context) async {
    final supabase = Supabase.instance.client;
    final response = await supabase.from('users').select().neq('role', 'admin');
    final pegawaiList = response.map((e) => Pegawai.fromJson(e)).toList();

    await BackupService.saveBackupPegawaiAsExcel(pegawaiList);
    _showSnackbar(context, 'Backup pegawai Excel berhasil!');
  }

  Future<void> _backupPegawaiPdf(BuildContext context) async {
    final supabase = Supabase.instance.client;
    final response = await supabase.from('users').select().neq('role', 'admin');
    final pegawaiList = response.map((e) => Pegawai.fromJson(e)).toList();

    await BackupService.saveBackupPegawaiAsPdf(pegawaiList);
    _showSnackbar(context, 'Backup pegawai PDF berhasil!');
  }

  void _showSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
  void main() {
  runApp(MaterialApp(
    home: BackupDataPage(),
  ));
}
}