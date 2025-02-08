import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_application_1/HalamanHome/to_do_page.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_application_1/HalamanHome/kalender_page.dart';
import 'package:flutter_application_1/HalamanHome/activity_page.dart';

class HomeTab extends StatefulWidget {
  final String username;
  final VoidCallback informasi;

  const HomeTab({
    super.key,
    required this.username,
    required this.informasi,
  });

  @override
  _HomeTabState createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  String? checkInTime;
  String? checkOutTime;
  String? profileImageUrl;
  String? departemen;
  String? shift;
  bool isDarkMode = false;
  final Color primaryColor = Color(0xFF2A2D7C);
  final Color accentColor = Color(0xFF00C2FF);
  final LinearGradient primaryGradient = LinearGradient(
      colors: [Color(0xFF2A2D7C), Color(0xFF00C2FF)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight);

  final Color lightBlue = Color.fromARGB(255, 0, 0, 0);

  @override
  void initState() {
    super.initState();
    fetchUserProfile();
    fetchAttendanceData();
    setupRealtimeListener();
    fetchIncompleteTodos();
    fetchJadwalShift();
  }

  Future<void> fetchJadwalShift() async {
  final supabase = Supabase.instance.client;
  final user = supabase.auth.currentUser;

  if (user == null) {
    print('User not logged in');
    return;
  }

  try {
    // Ambil tanggal hari ini dalam format YYYY-MM-DD
    String today = DateFormat('yyyy-MM-dd').format(DateTime.now());

    final response = await supabase
        .from('jadwal_shift')
        .select('shift')
        .eq('user_id', user.id)
        .eq('tanggal', today)
        .maybeSingle();

    setState(() {
      shift = response != null ? response['shift'] : 'Tidak Ada Shift';
    });
  } catch (e) {
    print('Error fetching shift: $e');
  }
}


  Future<void> fetchIncompleteTodos() async {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;

    if (user == null) {
      print('User not logged in');
      return;
    }

    try {
      final response = await supabase
          .from('todos')
          .select()
          .eq('user_id', user.id)
          .eq('is_complete', false);

      if (response.isNotEmpty) {
        Future.delayed(Duration.zero, () {
          showTodoPopup(response);
        });
      }
    } catch (e) {
      print('Error fetching incomplete todos: $e');
    }
  }

  void showTodoPopup(List todos) {
    if (context == null) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        elevation: 10,
        titlePadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        contentPadding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
        title: Row(
          children: [
            Icon(Icons.task_alt_rounded, color: Colors.blue[800], size: 28),
            const SizedBox(width: 12),
            Text(
              "Tugas Tertunda",
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.blue[900],
              ),
            ),
          ],
        ),
        content: SizedBox(
          width: MediaQuery.of(context).size.width * 0.8,
          height: MediaQuery.of(context).size.height * 0.6,
          child: todos.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_circle_outline,
                          size: 48, color: Colors.green[400]),
                      const SizedBox(height: 16),
                      Text(
                        "Semua tugas selesai!",
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${todos.length} Tugas belum selesai",
                      style: GoogleFonts.poppins(
                        color: Colors.red[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: ListView.separated(
                        physics: const BouncingScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: todos.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final todo = todos[index];
                          return Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.blue[50],
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 2,
                                  offset: Offset(1, 1),
                                ),
                              ],
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.circle_outlined,
                                  size: 20,
                                  color: Colors.blue[800],
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        todo['title'] ?? 'Tanpa Judul',
                                        style: GoogleFonts.poppins(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.blue[900],
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      if (todo['task'] != null)
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(bottom: 4),
                                          child: Text(
                                            todo['task'],
                                            style: GoogleFonts.poppins(
                                              fontSize: 13,
                                              color: Colors.grey[700],
                                            ),
                                            maxLines: 3,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      Row(
                                        children: [
                                          Icon(Icons.calendar_today,
                                              size: 14, color: Colors.red[700]),
                                          const SizedBox(width: 6),
                                          Text(
                                            _formatDeadline(todo['deadline']),
                                            style: GoogleFonts.poppins(
                                              fontSize: 12,
                                              color: Colors.red[700],
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
        ),
        actions: [
          TextButton(
            style: TextButton.styleFrom(
              backgroundColor: Colors.blue[100],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () => Navigator.pop(context),
            child: Text(
              "Mengerti",
              style: GoogleFonts.poppins(
                color: Colors.blue[800],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDeadline(String? deadline) {
    if (deadline == null) return 'Tanpa deadline';
    try {
      final date = DateTime.parse(deadline);
      return DateFormat('dd MMM yyyy, HH:mm').format(date);
    } catch (e) {
      return 'Format deadline tidak valid';
    }
  }

  Future<void> fetchUserProfile() async {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;

    if (user == null) {
      print('User not logged in');
      return;
    }

    try {
      final response = await supabase
          .from('users')
          .select('profile_url, departemen')
          .eq('id', user.id)
          .single();
      setState(() {
        profileImageUrl = response['profile_url'];
        departemen = response['departemen'] ?? 'Departemen Tidak Diketahui';
      });
    } catch (e) {
      print('Error fetching profile image: $e');
    }
  }

  Future<void> fetchAttendanceData() async {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;

    if (user == null) {
      print('User not logged in');
      return;
    }

    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = DateTime(today.year, today.month, today.day, 23, 59, 59);

    try {
      final response = await supabase
          .from('absensi')
          .select()
          .eq('user_id', user.id)
          .gte('tanggal', startOfDay.toIso8601String())
          .lte('tanggal', endOfDay.toIso8601String());

      if (response.isNotEmpty) {
        setState(() {
          checkInTime = response
              .firstWhere(
                (record) => record['jenis_absen'] == 'masuk',
                orElse: () => {},
              )['tanggal']
              ?.toString();
          checkOutTime = response
              .firstWhere(
                (record) => record['jenis_absen'] == 'keluar',
                orElse: () => {},
              )['tanggal']
              ?.toString();
        });
      } else {
        setState(() {
          checkInTime = null;
          checkOutTime = null;
        });
      }
    } catch (e) {
      print('Error fetching attendance data: $e');
    }
  }

  void setupRealtimeListener() {
    final supabase = Supabase.instance.client;
    final userId = supabase.auth.currentUser?.id;

    if (userId == null) {
      print('User not logged in, skipping realtime listener setup.');
      return;
    }

    // Listen to attendance changes
    supabase
        .from('absensi')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .listen((event) {
          print('Realtime event: $event');
          fetchUserProfile();
          fetchAttendanceData();
        });

    // Listen to user profile changes (profile_url & username updates)
    supabase
        .from('users')
        .stream(primaryKey: ['id'])
        .eq('id', userId)
        .listen((event) {
          print('User profile updated: $event');
          fetchUserProfile();
        });
  }

  String formatDate(String? dateString) {
    if (dateString == null) return 'Belum Absen';
    final date = DateTime.parse(dateString);
    return DateFormat('HH:mm, dd MMM yyyy').format(date);
  }

  void toggleDarkMode() {
    setState(() {
      isDarkMode = !isDarkMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primaryColor: primaryColor,
        colorScheme: ColorScheme.light(
          primary: primaryColor,
          secondary: accentColor,
        ),
        textTheme: GoogleFonts.poppinsTextTheme(),
      ),
      home: Scaffold(
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 180.0,
              floating: false,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  'Dashboard',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    shadows: [
                      Shadow(
                        color: Colors.black26,
                        blurRadius: 4,
                        offset: Offset(1, 1),
                      )
                    ],
                  ),
                ),
                background: Container(
                  decoration: BoxDecoration(
                    gradient: primaryGradient,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Align(
                    alignment: Alignment.bottomRight,
                    child: Opacity(
                      opacity: 0.1,
                      child: Icon(
                        Icons.dashboard_rounded,
                        size: 150,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              actions: [
                Padding(
                  padding: EdgeInsets.only(right: 16),
                  child: IconButton(
                    icon: Icon(isDarkMode ? Icons.light_mode : Icons.dark_mode,
                        color: Colors.white),
                    onPressed: toggleDarkMode,
                  ),
                ),
              ],
            ),
            SliverList(
              delegate: SliverChildListDelegate([
                // Profile Card Section
                Container(
                  margin: EdgeInsets.all(16),
                  child: Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: primaryGradient,
                        boxShadow: [
                          BoxShadow(
                            color: accentColor.withOpacity(0.3),
                            blurRadius: 20,
                            offset: Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border:
                                    Border.all(color: Colors.white, width: 2),
                              ),
                              child: CircleAvatar(
                                radius: 28,
                                backgroundColor: Colors.white,
                                backgroundImage: profileImageUrl != null
                                    ? NetworkImage(profileImageUrl!)
                                    : AssetImage('images/logo.png')
                                        as ImageProvider,
                              ),
                            ),
                            SizedBox(width: 20),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Selamat Datang',
                                    style: GoogleFonts.poppins(
                                      fontSize: 18,
                                      color: Colors.white.withOpacity(0.9),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  SizedBox(height: 6),
                                  Text(
                                    widget.username,
                                    style: GoogleFonts.poppins(
                                      fontSize: 22,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    departemen ?? 'Departemen Tidak Diketahui',
                                    style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      color: Colors.white70,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'Shift Hari Ini: $shift', // ✅ Interpolasi string yang benar
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      color: Colors.white70,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // Attendance Card Section
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 16),
                  child: Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: primaryGradient,
                        boxShadow: [
                          BoxShadow(
                            color: accentColor.withOpacity(0.3),
                            blurRadius: 20,
                            offset: Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildTimeColumn('Masuk', checkInTime),
                            VerticalDivider(color: Colors.white54, width: 1),
                            _buildTimeColumn('Selesai', checkOutTime),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // Grid Menu Section
                Padding(
                  padding: EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(bottom: 16),
                        child: Text(
                          'Quick Access',
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            color: primaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      GridView.count(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        crossAxisCount: 3,
                        crossAxisSpacing: 20,
                        mainAxisSpacing: 20,
                        childAspectRatio: 0.9,
                        children: [
                          _buildMenuButton(
                            CupertinoIcons.calendar,
                            'Kalender',
                            _showKalenderPage,
                          ),
                          _buildMenuButton(
                            CupertinoIcons.square_list,
                            'Aktivitas',
                            _showActivityPage,
                          ),
                          _buildMenuButton(
                            CupertinoIcons.clock,
                            'To-Do List',
                            _showTodoList,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeColumn(String title, String? time) {
    return Column(
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
            color: Colors.white.withOpacity(0.8),
            fontSize: 14,
          ),
        ),
        SizedBox(height: 8),
        Text(
          formatDate(time),
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildMenuButton(IconData icon, String label, Function() onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        splashColor: accentColor.withOpacity(0.2),
        highlightColor: accentColor.withOpacity(0.1),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: primaryGradient,
            boxShadow: [
              BoxShadow(
                color: accentColor.withOpacity(0.2),
                blurRadius: 15,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.2),
                ),
                child: Icon(icon, size: 28, color: Colors.white),
              ),
              SizedBox(height: 12),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    height: 1.2,
                  ),
                  maxLines: 2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showActivityPage() {
    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) => ActivityPage(),
      ),
    );
  }

  void _showKalenderPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => KalenderPage(),
      ),
    );
  }

  void _showTodoList() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TodoPage(),
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String label, {VoidCallback? onTap}) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20.0),
              gradient: LinearGradient(
                colors: [
                  Colors.blue.shade100,
                  Colors.blue.shade200,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 32, color: CupertinoColors.activeBlue),
                const SizedBox(height: 8),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
