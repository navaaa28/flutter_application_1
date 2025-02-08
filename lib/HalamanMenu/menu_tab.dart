import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/HalamanMenu/absensikeluar_page.dart';
import 'package:flutter_application_1/HalamanMenu/izincuti_page.dart';
import 'package:flutter_application_1/HalamanMenu/lembur_page.dart';
import 'package:flutter_application_1/HalamanMenu/absensimasuk_page.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MenuTab extends StatefulWidget {
  final VoidCallback informasi;
  final String username;

  const MenuTab({
    super.key,
    required this.informasi,
    required this.username,
  });

  @override
  _MenuTabState createState() => _MenuTabState();
}

class _MenuTabState extends State<MenuTab> {
  String displayName = '';
  String? departemen;
  final Color primaryColor = Color(0xFF2A2D7C);
  final Color accentColor = Color(0xFF00C2FF);
  final LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF2A2D7C), Color(0xFF00C2FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  String username = "";
  String profileImageUrl = "";

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _fetchData();
  }

  Future<void> _fetchData() async {
    await fetchUserProfile();
    await fetchUserName();
    setupRealtimeListener();
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
          .select('display_name')
          .eq('id', user.id)
          .single();
      setState(() {
        displayName = response['display_name'] ?? "Pengguna";
      });
    } catch (e) {
      print('Error fetching profile image: $e');
    }
  }

  Future<void> fetchUserName() async {
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

  void setupRealtimeListener() {
    final supabase = Supabase.instance.client;
    final userId = supabase.auth.currentUser?.id;

    if (userId == null) {
      print('User not logged in, skipping realtime listener setup.');
      return;
    }

    supabase
        .from('users')
        .stream(primaryKey: ['id'])
        .eq('id', userId)
        .listen((event) {
      print('User profile updated: $event');
      fetchUserProfile();
      fetchUserName();
    });
  }

  Future<void> _onRefresh() async {
    await _fetchData();
  }


  @override
  Widget build(BuildContext context) {
    final items = [
      {
        'icon': CupertinoIcons.check_mark_circled,
        'label': 'Absen Masuk',
        'page': AbsenMasukPage(
          username: '',
        )
      },
      {
        'icon': CupertinoIcons.clear_circled,
        'label': 'Absen Keluar',
        'page': AbsenKeluarPage(
          username: '',
        )
      },
      {
        'icon': CupertinoIcons.doc_text,
        'label': 'Lembur',
        'page': LemburPage()
      },
      {
        'icon': CupertinoIcons.calendar_badge_minus,
        'label': 'Izin / Cuti',
        'page': IzinCutiPage()
      },
      {
        'icon': CupertinoIcons.exclamationmark_triangle,
        'label': 'Coming Soon',
        'page': null
      },
    ];

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
        body: RefreshIndicator(
          onRefresh: _onRefresh,
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 180.0,
                floating: false,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    'Menu Utama',
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
              ),
              SliverList(
                delegate: SliverChildListDelegate([
                  // Header Section
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
                                  // ignore: unnecessary_null_comparison
                                  backgroundImage: profileImageUrl != null
                                      ? NetworkImage(profileImageUrl)
                                      : AssetImage('images/logo.png')
                                          as ImageProvider,
                                  // ignore: unnecessary_null_comparison
                                  child: profileImageUrl == null
                                      ? Icon(Icons.person, color: Colors.grey)
                                      : null,
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
                                    SizedBox(height: 4),
                                    Text(
                                      displayName,
                                      style: GoogleFonts.poppins(
                                        fontSize: 22,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      'Departemen: $departemen',
                                      style: GoogleFonts.poppins(
                                        fontSize: 16,
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

                  // Menu Grid Section
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: Text(
                            'Menu Utama',
                            style: GoogleFonts.poppins(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: primaryColor,
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
                          children: items.map((item) {
                            return Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(20),
                                onTap: () {
                                  if (item['page'] != null) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              item['page'] as Widget),
                                    );
                                  } else {
                                    // Handle case when there's no page (e.g., "Coming Soon")
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Coming Soon!')),
                                    );
                                  }
                                },
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
                                        child: Icon(
                                          item['icon'] as IconData,
                                          size: 28,
                                          color: Colors.white,
                                        ),
                                      ),
                                      SizedBox(height: 12),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8.0),
                                        child: Text(
                                          item['label'] as String,
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
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}