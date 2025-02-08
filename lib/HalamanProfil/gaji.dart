import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class GajiPage extends StatefulWidget {
  final String userId;

  const GajiPage({super.key, required this.userId});

  @override
  _GajiPageState createState() => _GajiPageState();
}

class _GajiPageState extends State<GajiPage> {
  String selectedSalary = '0';
  DateTime? salaryDate;
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    fetchSalary();
  }

  Future<void> fetchSalary() async {
    final supabase = Supabase.instance.client;
    try {
      print("Fetching salary for user: ${widget.userId}"); // Debug: User ID
      final response = await supabase
          .from('users')
          .select('salary, salary_date')
          .eq('id', widget.userId)
          .single();

      print("Response from Supabase: $response"); // Debug: Response data

      if (response != null) {
        setState(() {
          selectedSalary = response['salary']?.toString() ?? '0';
          salaryDate = response['salary_date'] != null
              ? DateTime.tryParse(response['salary_date']) // Gunakan tryParse
              : null;
        });
      } else {
        print("No data found for user: ${widget.userId}"); // Debug: No data
      }
    } catch (e, stackTrace) {
      print("Error fetching salary: $e"); // Debug: Error message
      print("Stack trace: $stackTrace"); // Debug: Stack trace
      setState(() {
        errorMessage = 'Gagal memuat data gaji. Pastikan data sudah tersedia.';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Tanggal tidak tersedia';
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  String _formatCurrency(String amount) {
    try {
      final number = int.parse(amount);
      return number.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.');
    } catch (e) {
      return amount;
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Gajian'),
      ),
      child: SafeArea(
        child: isLoading
            ? const Center(child: CupertinoActivityIndicator())
            : errorMessage != null
                ? Center(
                    child: Text(
                      errorMessage!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  )
                : Column(
                    children: [                    
                      const SizedBox(height: 20),
                      selectedSalary != '0'
                          ? CupertinoListTile(
                              leading: const Icon(CupertinoIcons.money_dollar),
                              title: Text(
                                  'Rp ${_formatCurrency(selectedSalary)}'),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Gaji Anda Saat Ini'),
                                  const SizedBox(height: 5),
                                  if (salaryDate != null)
                                    Text(
                                        'Diterima pada: ${_formatDate(salaryDate)}'),
                                ],
                              ),
                            )
                          : const Text(
                              'Anda belum mendapatkan gaji.',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                    ],
                  ),
      ),
    );
  }
}