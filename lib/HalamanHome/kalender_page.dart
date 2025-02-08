import 'package:flutter/material.dart';
import 'package:flutter_application_1/HalamanAdmin/admincalenderpage.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/cupertino.dart';

class KalenderPage extends StatefulWidget {
  @override
  _KalenderPageState createState() => _KalenderPageState();
}

class _KalenderPageState extends State<KalenderPage>
    with SingleTickerProviderStateMixin {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  final SupabaseClient _supabase = Supabase.instance.client;
  final DateTime _firstDay = DateTime(2020);
  final DateTime _lastDay = DateTime(2030);
  final Color primaryColor = const Color(0xFF1A237E);
  final Color accentColor = const Color(0xFF00BCD4);
  final LinearGradient primaryGradient = const LinearGradient(
    colors: [Color(0xFF1A237E), Color(0xFF00BCD4)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  List<Map<String, dynamic>> _allEvents = [];
  bool _isLoading = true;
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _loadEvents();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadEvents() async {
    try {
      final response = await _supabase.from('events').select();
      setState(() {
        _allEvents = List<Map<String, dynamic>>.from(response);
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading events: $e');
      setState(() => _isLoading = false);
    }
  }

  List<dynamic> _getEventsForDay(DateTime day) {
    final formattedDate = DateFormat('yyyy-MM-dd').format(day);
    return _allEvents
        .where((event) => event['event_date'] == formattedDate)
        .map((event) => event['title'])
        .toList();
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
                          child: const Icon(Icons.arrow_back,
                              color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                      ScaleTransition(
                        scale: _animation,
                        child: const Icon(
                          Icons.calendar_today,
                          color: Colors.white,
                          size: 60,
                        ),
                      ),
                      Text(
                        'ACTIVO Calendar',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: Icon(Icons.refresh, color: Colors.white),
                onPressed: _loadEvents,
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
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: TableCalendar(
                            firstDay: _firstDay,
                            lastDay: _lastDay,
                            focusedDay: _focusedDay,
                            calendarFormat: _calendarFormat,
                            selectedDayPredicate: (day) =>
                                isSameDay(_selectedDay, day),
                            onDaySelected: (selectedDay, focusedDay) {
                              setState(() {
                                _selectedDay = selectedDay;
                                _focusedDay = focusedDay;
                              });
                            },
                            onFormatChanged: (format) =>
                                setState(() => _calendarFormat = format),
                            onPageChanged: (focusedDay) =>
                                setState(() => _focusedDay = focusedDay),
                            eventLoader: _getEventsForDay,
                            availableCalendarFormats: const {
                              CalendarFormat.month: 'Month',
                              CalendarFormat.week: 'Week',
                            },
                            calendarStyle: CalendarStyle(
                              selectedDecoration: BoxDecoration(
                                color: accentColor,
                                shape: BoxShape.circle,
                              ),
                              todayDecoration: BoxDecoration(
                                color: primaryColor.withOpacity(0.4),
                                shape: BoxShape.circle,
                              ),
                              markerDecoration: BoxDecoration(
                                color: accentColor,
                                shape: BoxShape.circle,
                              ),
                              weekendTextStyle: TextStyle(color: Colors.red),
                              defaultTextStyle: GoogleFonts.poppins(),
                              holidayTextStyle: GoogleFonts.poppins(),
                              outsideDaysVisible: false,
                            ),
                            headerStyle: HeaderStyle(
                              formatButtonVisible: true,
                              titleCentered: true,
                              formatButtonDecoration: BoxDecoration(
                                color: primaryColor,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              formatButtonTextStyle: GoogleFonts.poppins(
                                color: Colors.white,
                              ),
                              leftChevronIcon: Icon(
                                Icons.chevron_left,
                                color: primaryColor,
                              ),
                              rightChevronIcon: Icon(
                                Icons.chevron_right,
                                color: primaryColor,
                              ),
                            ),
                            daysOfWeekStyle: DaysOfWeekStyle(
                              weekdayStyle: GoogleFonts.poppins(
                                color: primaryColor,
                                fontWeight: FontWeight.w600,
                              ),
                              weekendStyle: GoogleFonts.poppins(
                                color: Colors.red,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        ..._buildEventList(),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildEventList() {
    final selectedDate = _selectedDay ?? _focusedDay;
    return _allEvents
        .where((event) =>
            event['event_date'] == DateFormat('yyyy-MM-dd').format(selectedDate))
        .map((event) => Container(
              margin: EdgeInsets.symmetric(vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: ListTile(
                leading: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.event, color: primaryColor),
                ),
                title: Text(
                  event['title'],
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    color: primaryColor,
                  ),
                ),
                subtitle: Text(
                  event['description'] ?? '',
                  style: GoogleFonts.poppins(),
                ),
                trailing: Icon(Icons.chevron_right, color: accentColor),
              ),
            ))
        .toList();
  }
}