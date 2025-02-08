import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LaporanIzinCutiPage extends StatefulWidget {
  const LaporanIzinCutiPage({Key? key}) : super(key: key);

  @override
  _LaporanIzinCutiPageState createState() => _LaporanIzinCutiPageState();
}

class _LaporanIzinCutiPageState extends State<LaporanIzinCutiPage> {
  final _supabase = Supabase.instance.client;
  List<Map<String, dynamic>> _leaves = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchLeaves();
  }

  Future<void> _fetchLeaves() async {
    final response = await _supabase
        .from('leave_requests')
        .select('*, users!inner(*)')
        .order('start_date', ascending: false);

    setState(() {
      _leaves = List<Map<String, dynamic>>.from(response);
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(middle: Text('Laporan Izin & Cuti')),
      child: SafeArea(
        child: _isLoading
            ? const Center(child: CupertinoActivityIndicator())
            : ListView.builder(
                itemCount: _leaves.length,
                itemBuilder: (context, index) {
                  final leave = _leaves[index];
                  return CupertinoListTile(
                    title: Text(leave['users']['display_name']),
                    subtitle: Text('${leave['start_date']} - ${leave['end_date']}'),
                    trailing: Chip(
                      label: Text(
                        leave['status'],
                        style: TextStyle(
                          color: leave['status'] == 'approved'
                              ? Colors.green
                              : leave['status'] == 'rejected'
                                  ? Colors.red
                                  : Colors.orange,
                          decoration:TextDecoration.none
                        ),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}