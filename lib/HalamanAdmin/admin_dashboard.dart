import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/HalamanAdmin/admin_profiletab.dart';
import 'package:flutter_application_1/HalamanAdmin/admincalenderpage.dart';
import 'package:flutter_application_1/HalamanAdmin/hadir.dart';
import 'package:flutter_application_1/HalamanAdmin/izincutiadmin.dart';
import 'package:flutter_application_1/HalamanAdmin/jadwal_shift_page.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'daftar_pegawai_page.dart';
import 'package:flutter/rendering.dart';
import 'dart:math' as math;

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});
  

  @override
  _AdminDashboardState createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  String username = "";
  int _selectedIndex = 0;
  int totalPegawai = 0;
  int totalIzin = 0;
  int totalHadir = 0;
  int totalTerlmbat = 0;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    await _fetchTotalPegawai();
    await _fetchTotalHadir();
    await _fetchTotalIzin();
    await _fetchTotalTerlambat();
    await _fetchUsername();
  }

  Future<void> _fetchUsername() async {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;

    if (user == null) {
      print('User not logged in');
      return;
    }

    try {
      final response = await supabase
          .from('users')
          .select('display_name')
          .eq('id', user.id)
          .single();
      setState(() {
        username = response['display_name'] ?? "Pengguna";
      });
    } catch (e) {
      print('Error fetching profile image: $e');
    }
  }
  

  Future<void> _fetchTotalTerlambat() async {
    setState(() => isLoading = true);
    final supabase = await Supabase.instance.client;
    try {
      final response =
          await supabase.from('absensi').select().eq('status', 'Terlambat');

      setState(() {
        totalTerlmbat = response.length;
      });
    } catch (e) {
      _showErrorDialog('Gagal memuat total terlambat: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _fetchTotalIzin() async {
    setState(() => isLoading = true);
    try {
      final response = await Supabase.instance.client
          .from('izin_cuti')
          .select('display_name')
          .eq('status', 'Menunggu Persetujuan Atasan');

      setState(() {
        totalIzin = response.length;
      });
    } catch (e) {
      _showErrorDialog('Gagal memuat total izin: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _fetchTotalPegawai() async {
    setState(() => isLoading = true);
    try {
      final response = await Supabase.instance.client
          .from('users')
          .select('id')
          .eq('role', 'pegawai');

      setState(() {
        totalPegawai = response.length;
      });
    } catch (e) {
      _showErrorDialog('Gagal memuat total pegawai: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _fetchTotalHadir() async {
    setState(() => isLoading = true);
    try {
      DateTime now = DateTime.now();
      DateTime sevenDaysAgo = now.subtract(const Duration(days: 7));
      String formattedDate = DateFormat('yyyy-MM-dd').format(sevenDaysAgo);

      final response = await Supabase.instance.client
          .from('absensi')
          .select('user_id')
          .or("jenis_absen.eq.masuk, jenis_absen.eq.keluar")
          .gte('tanggal', formattedDate);

      setState(() {
        totalHadir = response.length;
      });
    } catch (e) {
      _showErrorDialog('Gagal memuat data kehadiran: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _showErrorDialog(String error) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Error'),
        content: Text(error),
        actions: [
          CupertinoDialogAction(
            child: const Text('OK'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Future<void> _onRefresh() async {
    await _fetchData();
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Color(0xFF6C56F5);
    final Color secondaryColor = Color(0xFF8F73FF);
    final Color accentColor = Color.fromARGB(255, 255, 0, 247);

    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        currentIndex: _selectedIndex,
        onTap: (index) async {
          setState(() => _selectedIndex = index);
          if (index == 0) await _fetchData();
        },
        backgroundColor: primaryColor,
        activeColor: Colors.white,
        inactiveColor: Colors.white70,
        items: [
          _buildNavItem(CupertinoIcons.graph_square, 'Dashboard'),
          _buildNavItem(CupertinoIcons.chart_bar_alt_fill, 'Absensi'),
          _buildNavItem(CupertinoIcons.person_3_fill, 'Pegawai'),
          _buildNavItem(CupertinoIcons.gear_alt_fill, 'Pengaturan'),
        ],
      ),
      tabBuilder: (context, index) {
        return CupertinoTabView(
          builder: (context) {
            return Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFF8F9FF), Color(0xFFEFF1FF)],
                ),
              ),
              child: CupertinoPageScaffold(
                backgroundColor: Colors.transparent,
                navigationBar: CupertinoNavigationBar(
                  backgroundColor: primaryColor,
                  middle: Text(
                    'Admin Dashboard',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 24,
                      letterSpacing: 1.1,
                    ),
                  ),
                  trailing: Icon(CupertinoIcons.bell_fill, color: Colors.white),
                ),
                child: _buildTabContent(
                    index, primaryColor, secondaryColor, accentColor),
              ),
            );
          },
        );
      },
    );
  }

  BottomNavigationBarItem _buildNavItem(IconData icon, String label) {
    return BottomNavigationBarItem(
      icon: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Icon(icon, size: 28),
      ),
      label: label,
    );
  }

  Widget _buildTabContent(
      int index, Color primary, Color secondary, Color accent) {
    switch (index) {
      case 0:
        return _buildDashboard(primary, secondary, accent);
      case 1:
        return Hadir();
      case 2:
        return PegawaiScreen();
      case 3:
        return AdminProfileTab(informasi: () {  },);
      default:
        return Container();
    }
  }

  Widget _buildDashboard(Color primary, Color secondary, Color accent) {
    return SafeArea(
      child: CustomScrollView(
        slivers: [
          CupertinoSliverRefreshControl(onRefresh: _onRefresh),
          SliverPadding(
            padding: EdgeInsets.all(20),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  SizedBox(height: 30),
                  _buildStatsGrid(primary, secondary, accent),
                  SizedBox(height: 30),
                  _buildActivityChart(primary, secondary),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          DateFormat('EEEE, d MMMM y').format(DateTime.now()),
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 16,
            fontWeight: FontWeight.w500,
            decoration:TextDecoration.none
          ),
        ),
        Text(
          "Selamat Datang, $username",
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: Color(0xFF2D2F3A),
            letterSpacing: 0.5,
            decoration:TextDecoration.none
          ),
        ),
      ],
    );
  }

  Widget _buildStatsGrid(Color primary, Color secondary, Color accent) {
    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 15,
        mainAxisSpacing: 15,
        childAspectRatio: 1.2,
      ),
      itemCount: 7,
      itemBuilder: (context, index) {
        final List<Map<String, dynamic>> cards = [
          {
            'value': totalHadir,
            'label': 'Kehadiran',
            'color': primary,
            'icon': CupertinoIcons.checkmark_alt_circle_fill,
            'onTap': () {},
          },
          {
            'value': totalIzin,
            'label': 'Izin',
            'color': secondary,
            'icon': CupertinoIcons.doc_text_fill,
            'onTap': () => _navigateTo(context, IzinCutiAdminPage()),
          },
          {
            'value': 10,
            'label': 'Sakit',
            'color': Color(0xFFFF6B6B),
            'icon': CupertinoIcons.heart_slash_fill,
            'onTap': () {},
          },
          {
            'value': totalTerlmbat,
            'label': 'Terlambat',
            'color': Color(0xFFA55EEA),
            'icon': CupertinoIcons.clock_fill,
            'onTap': () {},
          },
          {
            'value': totalPegawai,
            'label': 'Pegawai',
            'color': Color(0xFF4ECDC4),
            'icon': CupertinoIcons.person_2_fill,
            'onTap': () {},
          },
          {
            'value': '',
            'label': 'Kalender Event',
            'color': accent,
            'icon': CupertinoIcons.calendar,
            'onTap': () => _navigateTo(context, AdminCalendarPage()),
          },
          {
            'value': '',
            'label': 'Jadwal Pegawai',
            'color': Color(0xFFFF6B6B),
            'icon': CupertinoIcons.calendar_circle,
            'onTap': () => _navigateTo(context, JadwalShiftPage()),
          },
        ];

        return _buildDashboardCard(cards[index], index);
      },
    );
  }

  Widget _buildDashboardCard(Map<String, dynamic> data, int index) {
    return TweenAnimationBuilder(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 500 + (index * 100)),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, (1 - value) * 50),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: data['onTap'],
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: data['color'].withOpacity(0.2),
                  blurRadius: 15,
                  spreadRadius: 2,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            child: Stack(
              children: [
                Positioned(
                  right: -30,
                  top: -30,
                  child: Transform.rotate(
                    angle: math.pi / 4,
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: data['color'].withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Icon(data['icon'], size: 32, color: data['color']),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            data['value'].toString(),
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              color: data['color'],
                              decoration:TextDecoration.none
                            ),
                          ),
                          Text(
                            data['label'],
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey.shade600,
                              decoration:TextDecoration.none
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActivityChart(Color primary, Color secondary) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 15,
            spreadRadius: 2,
          ),
        ],
      ),
    );
  }

  void _navigateTo(BuildContext context, Widget page) async {
  await Navigator.push(
    context,
    CupertinoPageRoute(builder: (context) => page),
  );
  _fetchData(); // Pastikan ini tetap dipanggil setelah kembali dari navigasi
}

}