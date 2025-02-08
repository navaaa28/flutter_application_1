import 'package:flutter/material.dart';

class AuditSistemPage extends StatefulWidget {
  @override
  _AuditSistemPageState createState() => _AuditSistemPageState();
}

class _AuditSistemPageState extends State<AuditSistemPage> {
  // Contoh data audit (bisa diganti dengan data dari API atau database)
  final List<Map<String, String>> auditLogs = [
    {
      "tanggal": "2025-02-06",
      "user": "Admin",
      "aksi": "Login berhasil"
    },
    {
      "tanggal": "2025-02-05",
      "user": "User123",
      "aksi": "Mengubah pengaturan sistem"
    },
    {
      "tanggal": "2025-02-04",
      "user": "Admin",
      "aksi": "Menghapus data pengguna"
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Audit Sistem"),
        backgroundColor: Colors.blueAccent,
      ),
      body: ListView.builder(
        itemCount: auditLogs.length,
        itemBuilder: (context, index) {
          final log = auditLogs[index];
          return Card(
            margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: ListTile(
              leading: Icon(Icons.security, color: Colors.blue),
              title: Text(log["aksi"] ?? "Aksi Tidak Diketahui"),
              subtitle: Text("User: ${log["user"]} • ${log["tanggal"]}"),
            ),
          );
        },
      ),
    );
  }
}
