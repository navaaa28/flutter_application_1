import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';

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

class BackupService {
  static Future<File> saveBackupHadir(List<Hadir> items) async {
    try {
      final directory = await getExternalStorageDirectory();
      if (directory == null) {
        throw Exception('Tidak dapat mengakses penyimpanan eksternal');
      }

      final downloadDir = Directory('${directory.path}/Download');
      if (!await downloadDir.exists()) {
        await downloadDir.create(recursive: true);
      }

      final backupData = BackupData<Hadir>(items: items);
      final jsonData = backupData.toJson((item) => item.toJson());

      final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
      final file = File('${downloadDir.path}/attendance_backup_$timestamp.json');

      return await file.writeAsString(json.encode(jsonData));
    } catch (e) {
      throw Exception('Gagal menyimpan backup: $e');
    }
  }

  static Future<File> saveBackupHadirAsPdf(List<Hadir> items) async {
    try {
      final pdfDocument = pw.Document();
      final font = await pw.Font.courier();

      pdfDocument.addPage(
        pw.Page(
          build: (pw.Context context) {
            return pw.Column(
              children: [
                pw.Text('Laporan Absensi',
                    style: pw.TextStyle(fontSize: 24, font: font)),
                pw.SizedBox(height: 20),
                ...items.map((attendance) {
                  return pw.Padding(
                    padding: const pw.EdgeInsets.only(bottom: 8),
                    child: pw.Text(
                      'Nama: ${attendance.displayName}\n'
                      'Tanggal: ${_formatPdfDate(attendance.tanggal)}\n'
                      'Lokasi: ${attendance.lokasi}\n'
                      'Status: ${attendance.jenisAbsen == "masuk" ? "Masuk" : "Keluar"}\n'
                      '----------------------------------------',
                      style: pw.TextStyle(fontSize: 12, font: font),
                    ),
                  );
                }).toList(),
              ],
            );
          },
        ),
      );

      final directory = await getExternalStorageDirectory();
      if (directory == null) {
        throw Exception('Tidak dapat mengakses penyimpanan eksternal');
      }

      final downloadDir = Directory('${directory.path}/Download');
      if (!await downloadDir.exists()) {
        await downloadDir.create(recursive: true);
      }

      final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
      final file = File('${downloadDir.path}/attendance_backup_$timestamp.pdf');

      await file.writeAsBytes(await pdfDocument.save());
      return file;
    } catch (e) {
      throw Exception('Gagal membuat PDF: $e');
    }
  }

  static String _formatPdfDate(String dateString) {
    try {
      DateTime date = DateTime.parse(dateString);
      return DateFormat('dd-MMM-yyyy HH:mm').format(date);
    } catch (e) {
      return dateString;
    }
  }
}

class HadirPage extends StatefulWidget {
  @override
  _HadirPageState createState() => _HadirPageState();
}

class _HadirPageState extends State<HadirPage> {
  Map<String, List<Hadir>> groupedAttendance = {};
  bool isLoading = true;
  final _supabase = Supabase.instance.client;

  Future<void> _requestPermissions() async {
    final status = await Permission.storage.request();
    if (!status.isGranted) {
      throw Exception('Izin penyimpanan ditolak');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchActivities();
  }

  Future<void> fetchActivities() async {
    try {
      final response = await _supabase
          .from('absensi')
          .select()
          .order('tanggal', ascending: false);

      final Map<String, List<Hadir>> groupedData = {};
      for (var record in response) {
        final jenisAbsen = record['jenis_absen']?.toString().toUpperCase() ?? 'LAINNYA';
        final attendance = Hadir.fromJson(record);

        groupedData.putIfAbsent(jenisAbsen, () => []);
        groupedData[jenisAbsen]!.add(attendance);
      }

      setState(() {
        groupedAttendance = groupedData;
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching activities: $e');
      setState(() => isLoading = false);
    }
  }

  String formatDate(String dateString) {
    try {
      DateTime date = DateTime.parse(dateString);
      return DateFormat('dd MMM yyyy, HH:mm').format(date);
    } catch (e) {
      return 'Tanggal tidak valid';
    }
  }

  Future<void> _saveAsPdf() async {
    try {
      await _requestPermissions();
      await BackupService.saveBackupHadirAsPdf(
          groupedAttendance.values.expand((x) => x).toList());
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Backup PDF berhasil disimpan di folder Download!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  Future<void> _saveAsJson() async {
    try {
      await _requestPermissions();
      await BackupService.saveBackupHadir(
          groupedAttendance.values.expand((x) => x).toList());
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Backup JSON berhasil disimpan di folder Download!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Semua Data Absensi', 
               style: GoogleFonts.poppins(color: Colors.white)),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: const Icon(Icons.save_alt),
            onPressed: _saveAsJson,
            tooltip: 'Simpan sebagai JSON',
          ),
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: _saveAsPdf,
            tooltip: 'Simpan sebagai PDF',
          ),
        ],
      ),
      body: _buildBody(),
    );
  }
      Widget _buildBody() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    
    if (groupedAttendance.isEmpty) {
      return Center(
        child: Text(
          "Tidak ada data absensi",
          style: GoogleFonts.poppins(color: Colors.grey),
        ),
      );
    }
    
    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            "Daftar Absensi Karyawan",
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
        ),
        ...groupedAttendance.entries.map((entry) => _buildAttendanceGroup(entry)),
      ],
    );
  }

  Widget _buildAttendanceGroup(MapEntry<String, List<Hadir>> entry) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          color: Colors.blue[50],
          child: Text(
            'ABSEN ${entry.key}',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              color: Colors.blue[800],
              fontSize: 14,
            ),
          ),
        ),
        ...entry.value.map((attendance) => _buildAttendanceCard(attendance)),
      ],
    );
  }

  Widget _buildAttendanceCard(Hadir attendance) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: Colors.grey[300]!),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        leading: CircleAvatar(
          radius: 25,
          backgroundColor: Colors.grey[200],
          backgroundImage: attendance.fotoUrl.isNotEmpty
              ? NetworkImage('https://twthndrmrdkhtvgodqae.supabase.co/storage/v1/object/public/${attendance.fotoUrl}')
              : null,
          child: attendance.fotoUrl.isEmpty
              ? Icon(Icons.person, color: Colors.grey[500])
              : null,
        ),
        title: Text(
          attendance.displayName,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              formatDate(attendance.tanggal),
              style: GoogleFonts.poppins(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
            Text(
              attendance.lokasi,
              style: GoogleFonts.poppins(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: attendance.jenisAbsen == 'masuk' 
                 ? Colors.green[50] 
                 : Colors.red[50],
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            attendance.jenisAbsen == 'masuk' ? 'MASUK' : 'KELUAR',
            style: GoogleFonts.poppins(
              color: attendance.jenisAbsen == 'masuk' 
                   ? Colors.green[800] 
                   : Colors.red[800],
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: HadirPage(),
  ));
}