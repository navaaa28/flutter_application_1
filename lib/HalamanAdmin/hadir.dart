import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Untuk format tanggal
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

class Hadir extends StatefulWidget {
  @override
  _HadirState createState() => _HadirState();
}

class _HadirState extends State<Hadir> {
  Map<String, List<Map<String, dynamic>>> groupedAttendance = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchActivities();
  }

  Future<void> fetchActivities() async {
    final supabase = Supabase.instance.client;

    try {
      final response = await supabase
          .from('absensi')
          .select()
          .order('tanggal', ascending: false);

      // Kelompokkan data berdasarkan jenis absen
      final Map<String, List<Map<String, dynamic>>> groupedData = {};
      for (var record in response) {
        final jenisAbsen = record['jenis_absen']?.toString().toUpperCase() ?? 'Lainnya';
        groupedData.putIfAbsent(jenisAbsen, () => []);
        groupedData[jenisAbsen]!.add(record);
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

  @override
  Widget build(BuildContext context) {
    const primaryColor = Colors.blue;

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(
          'Semua Data Absensi',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: primaryColor,
        border: null,
      ),
      child: SafeArea(
        child: isLoading
            ? Center(child: CupertinoActivityIndicator())
            : groupedAttendance.isEmpty
                ? Center(
                    child: Text(
                      "Tidak ada data absensi",
                      style: GoogleFonts.poppins(color: Colors.grey),
                    ),
                  )
                : ListView(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          "Data Absensi",
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: primaryColor,
                            decoration:TextDecoration.none
                          ),
                        ),
                      ),
                      ...groupedAttendance.entries.map((entry) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              color: Colors.grey[100],
                              child: Text(
                                entry.key,
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w600,
                                  color: primaryColor,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            ...entry.value.map((attendance) {
                              return Card(
                                margin: EdgeInsets.symmetric(
                                    vertical: 4, horizontal: 16),
                                elevation: 2,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: Colors.grey[200],
                                    backgroundImage: attendance['foto_url'] !=
                                                null &&
                                            attendance['foto_url'].isNotEmpty
                                        ? NetworkImage(
                                            'https://twthndrmrdkhtvgodqae.supabase.co/storage/v1/object/public/${attendance['foto_url']}',
                                          )
                                        : null,
                                    child: attendance['foto_url'] == null ||
                                            attendance['foto_url'].isEmpty
                                        ? Icon(Icons.person, color: Colors.grey)
                                        : null,
                                  ),
                                  title: Text(
                                    attendance['display_name'] ?? 'Tanpa Nama',
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        formatDate(attendance['tanggal']),
                                        style: GoogleFonts.poppins(
                                          color: Colors.grey[600],
                                          fontSize: 12,
                                        ),
                                      ),
                                      Text(
                                        attendance['lokasi'] ??
                                            'Lokasi tidak tersedia',
                                        style: GoogleFonts.poppins(
                                          color: Colors.grey[600],
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                  trailing: Icon(
                                    attendance['jenis_absen'] == 'masuk'
                                        ? CupertinoIcons.arrow_down_circle_fill
                                        : CupertinoIcons.arrow_up_circle_fill,
                                    color: attendance['jenis_absen'] == 'masuk'
                                        ? Colors.green
                                        : Colors.red,
                                  ),
                                ),
                              );
                            }).toList(),
                          ],
                        );
                      }).toList(),
                    ],
                  ),
      ),
    );
  }
}