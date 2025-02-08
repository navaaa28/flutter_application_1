import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:csv/csv.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class RekapitulasiAbsensiPage extends StatefulWidget {
  const RekapitulasiAbsensiPage({Key? key}) : super(key: key);

  @override
  _RekapitulasiAbsensiPageState createState() => _RekapitulasiAbsensiPageState();
}

class _RekapitulasiAbsensiPageState extends State<RekapitulasiAbsensiPage> {
  final _supabase = Supabase.instance.client;
  List<Map<String, dynamic>> _attendance = [];
  bool _isLoading = true;
  final Color primaryColor = const Color(0xFF1A237E);
  final Color accentColor = const Color(0xFF00BCD4);
  final LinearGradient primaryGradient = const LinearGradient(
    colors: [Color(0xFF1A237E), Color(0xFF00BCD4)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  @override
  void initState() {
    super.initState();
    _fetchAttendance();
  }

  Future<void> _fetchAttendance() async {
    final sevenDaysAgo = DateTime.now().subtract(Duration(days: 7));
    final response = await _supabase
        .from('absensi')
        .select('*')
        .gte('tanggal', sevenDaysAgo.toIso8601String())
        .order('tanggal', ascending: false);

    setState(() {
      _attendance = List<Map<String, dynamic>>.from(response);
      _isLoading = false;
    });
  }

  Future<void> _exportToCsv() async {
    List<List<dynamic>> csvData = [];
    csvData.add([
      'User ID',
      'Nama',
      'Tanggal',
      'Lokasi',
      'Foto URL',
      'Jenis Absen',
      'Status'
    ]);

    for (var record in _attendance) {
      csvData.add([
        record['user_id'] ?? '-',
        record['display_name'] ?? '-',
        record['tanggal'] ?? '-',
        record['lokasi'] ?? '-',
        record['foto_url'] ?? '-',
        record['jenis_absen'] ?? '-',
        record['status'] ?? '-',
      ]);
    }

    String csv = const ListToCsvConverter().convert(csvData);
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/absensi_7_hari_terakhir.csv');
    await file.writeAsString(csv);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('File CSV berhasil disimpan di ${file.path}'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: primaryGradient,
                  boxShadow: [
                    BoxShadow(
                      color: accentColor.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: SafeArea(
                  child: Column(
                    children: [
                      Align(
                        alignment: Alignment.topLeft,
                        child: CupertinoButton(
                          child: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                          ),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                      const Spacer(),
                      Icon(
                        Icons.assignment,
                        color: Colors.white,
                        size: 60,
                      ),
                      const SizedBox(height: 15),
                      Text(
                        'Rekap Absensi',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                    ],
                  ),
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: Icon(Icons.download, color: Colors.white),
                onPressed: _exportToCsv,
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Text(
                          'Rekap 7 Hari Terakhir',
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: primaryColor,
                          ),
                        ),
                        const SizedBox(height: 20),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                            columns: const [
                              DataColumn(label: Text('User ID')),
                              DataColumn(label: Text('Nama')),
                              DataColumn(label: Text('Tanggal')),
                              DataColumn(label: Text('Lokasi')),
                              DataColumn(label: Text('Foto')),
                              DataColumn(label: Text('Jenis Absen')),
                              DataColumn(label: Text('Status')),
                            ],
                            rows: _attendance.map((record) {
                            String formattedDate = 'Invalid Date';
                            try {
                              if (record['tanggal'] != null) {
                                formattedDate = DateFormat('dd/MM/yyyy HH:mm')
                                    .format(DateTime.parse(record['tanggal']));
                              }
                            } catch (e) {
                              formattedDate = 'Invalid Date';
                            }

                            return DataRow(cells: [
                              DataCell(Text(record['user_id']?.toString() ?? '-')),
                              DataCell(Text(record['display_name'] ?? '-')),
                              DataCell(Text(formattedDate)),
                              DataCell(Text(record['lokasi'] ?? '-')),
                              DataCell(Text(record['foto_url'] ?? '-')),
                              DataCell(Text(record['jenis_absen'] ?? '-')),
                              DataCell(Text(record['status'] ?? '-')),
                            ]);
                          }).toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}