import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class JadwalShiftPage extends StatefulWidget {
  @override
  _JadwalShiftPageState createState() => _JadwalShiftPageState();
}

class _JadwalShiftPageState extends State<JadwalShiftPage> {
  final supabase = Supabase.instance.client;
  DateTime _selectedWeek = DateTime.now();
  Map<String, Map<String, String?>> _schedule = {};
  List<Map<String, dynamic>> _employees = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    // Get employees
    final employeesResponse = await supabase
        .from('users')
        .select('id, display_name')
        .eq('role', 'pegawai');
        
    // Get existing schedule
    final startDate = _selectedWeek.subtract(Duration(days: _selectedWeek.weekday - 1));
    final endDate = startDate.add(Duration(days: 6));
    
    final scheduleResponse = await supabase
        .from('jadwal_shift')
        .select('*')
        .gte('tanggal', DateFormat('yyyy-MM-dd').format(startDate))
        .lte('tanggal', DateFormat('yyyy-MM-dd').format(endDate));

    // Initialize schedule structure
    _schedule = {};
    for (var employee in employeesResponse) {
      _schedule[employee['id']] = {};
      for (int i = 0; i < 7; i++) {
        DateTime date = startDate.add(Duration(days: i));
        _schedule[employee['id']]![DateFormat('yyyy-MM-dd').format(date)] = null;
      }
    }

    // Fill existing data
    for (var shift in scheduleResponse) {
      String date = DateFormat('yyyy-MM-dd').format(DateTime.parse(shift['tanggal']));
      _schedule[shift['user_id']]?[date] = shift['shift'];
    }

    setState(() {
      _employees = employeesResponse;
      _isLoading = false;
    });
  }

  Future<void> _saveSchedule() async {
    final shifts = [];
    final startDate = _selectedWeek.subtract(Duration(days: _selectedWeek.weekday - 1));
    
    for (var employeeId in _schedule.keys) {
      for (var entry in _schedule[employeeId]!.entries) {
        if (entry.value != null) {
          shifts.add({
            'user_id': employeeId,
            'tanggal': entry.key,
            'shift': entry.value,
          });
        }
      }
    }

    await supabase.from('jadwal_shift').upsert(shifts);
    _loadData();
  }

  Widget _buildWeekSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CupertinoButton(
          child: Icon(CupertinoIcons.chevron_left),
          onPressed: () {
            setState(() => _selectedWeek = _selectedWeek.subtract(Duration(days: 7)));
            _loadData();
          },
        ),
        Text(
          DateFormat('dd MMM y').format(
            _selectedWeek.subtract(Duration(days: _selectedWeek.weekday - 1)),
          ) +
              ' - ' +
              DateFormat('dd MMM y').format(
                _selectedWeek.add(Duration(days: 7 - _selectedWeek.weekday)),
              ),
          style: TextStyle(fontSize: 16),
        ),
        CupertinoButton(
          child: Icon(CupertinoIcons.chevron_right),
          onPressed: () {
            setState(() => _selectedWeek = _selectedWeek.add(Duration(days: 7)));
            _loadData();
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('Atur Jadwal Shift'),
        trailing: CupertinoButton(
          child: Text('Simpan'),
          onPressed: _saveSchedule,
        ),
      ),
      child: _isLoading
          ? Center(child: CupertinoActivityIndicator())
          : Column(
              children: [
                _buildWeekSelector(),
                Expanded(
                  child: ListView.builder(
                    itemCount: _employees.length,
                    itemBuilder: (context, index) {
                      final employee = _employees[index];
                      return _EmployeeScheduleCard(
                        employee: employee,
                        schedule: _schedule[employee['id']]!,
                        onShiftChanged: (date, shift) {
                          setState(() {
                            _schedule[employee['id']]![date] = shift;
                          });
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}

class _EmployeeScheduleCard extends StatelessWidget {
  final Map<String, dynamic> employee;
  final Map<String, String?> schedule;
  final Function(String, String?) onShiftChanged;

  const _EmployeeScheduleCard({
    required this.employee,
    required this.schedule,
    required this.onShiftChanged,
  });

  @override
  Widget build(BuildContext context) {
    final dates = schedule.keys.toList()..sort();
    
    return Card(
      margin: EdgeInsets.all(8),
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(employee['display_name'],
                style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: dates.map((date) {
                  DateTime dateTime = DateTime.parse(date);
                  return _DayShiftSelector(
                    date: dateTime,
                    shift: schedule[date],
                    onChanged: (value) => onShiftChanged(date, value),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DayShiftSelector extends StatelessWidget {
  final DateTime date;
  final String? shift;
  final Function(String?) onChanged;

  const _DayShiftSelector({
    required this.date,
    required this.shift,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        children: [
          Text(DateFormat('E').format(date), style: TextStyle(fontSize: 12)),
          SizedBox(height: 4),
          Container(
            width: 80,
            decoration: BoxDecoration(
              border: Border.all(color: CupertinoColors.systemGrey),
              borderRadius: BorderRadius.circular(8),
            ),
            child: CupertinoSlidingSegmentedControl<String>(
              groupValue: shift,
              children: const {
                '': Padding(
                  padding: EdgeInsets.symmetric(vertical: 4),
                  child: Text('-', style: TextStyle(fontSize: 12)),
                ),
                'Pagi': Padding(
                  padding: EdgeInsets.symmetric(vertical: 4),
                  child: Text('Pagi', style: TextStyle(fontSize: 12)),
                ),
                'Siang': Padding(
                  padding: EdgeInsets.symmetric(vertical: 4),
                  child: Text('Siang', style: TextStyle(fontSize: 12)),
                ),
                'Malam': Padding(
                  padding: EdgeInsets.symmetric(vertical: 4),
                  child: Text('Malam', style: TextStyle(fontSize: 12)),
                ),
              },
              onValueChanged: (value) => onChanged(value),
            ),
          ),
        ],
      ),
    );
  }
}