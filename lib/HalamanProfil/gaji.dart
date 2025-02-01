import 'package:flutter/cupertino.dart';

class GajiPage extends StatelessWidget {
  final String selectedSalary;
  final DateTime salaryDate;

  // Menambahkan parameter salaryDate untuk menentukan tanggal gaji diterima
  const GajiPage({super.key, required this.selectedSalary, required this.salaryDate});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Gajian'),
      ),
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            const Text(
              'Gaji yang anda terima',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            if (selectedSalary.isNotEmpty)
              CupertinoListTile(
                leading: const Icon(CupertinoIcons.money_dollar),
                title: Text(selectedSalary),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Gaji yang Anda Terima.'),
                    const SizedBox(height: 5),
                    Text('Diterima pada: ${_formatDate(salaryDate)}'),
                  ],
                ),
              )
            else
              const Text(
                'Anda belum mendapatkan gaji.',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
              ),
          ],
        ),
      ),
    );
  }

  // Fungsi untuk memformat tanggal dalam format yang lebih mudah dibaca
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
