import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/HalamanAdmin/izincutiadmin.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'daftar_pegawai_page.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  _AdminDashboardState createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _selectedIndex = 0;
  int totalPegawai = 0;

  @override
  void initState() {
    super.initState();
    _fetchTotalPegawai();
  }

  // Fungsi untuk mengambil jumlah pegawai dari Supabase
  Future<void> _fetchTotalPegawai() async {
    final response = await Supabase.instance.client
        .from('users')
        .select('id')
        .eq('role', 'pegawai');
    
    if (response.isNotEmpty) {
      setState(() {
        totalPegawai = response.length;
      });
    }
  }

  void _onTabSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
    if (index == 2) {
      Navigator.push(
        context,
        CupertinoPageRoute(builder: (context) => PegawaiScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Dashboard Admin'),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Aktivitas Hari Ini',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: 6,
                  itemBuilder: (context, index) {
                    List<Map<String, dynamic>> data = [
                      {'value': '150', 'label': 'Hadir', 'color': Colors.blue, 'icon': Icons.check_circle},
                      {'value': '20', 'label': 'Izin', 'color': Colors.orange, 'icon': Icons.warning},
                      {'value': '10', 'label': 'Sakit', 'color': Colors.red, 'icon': Icons.medical_services},
                      {'value': '5', 'label': 'Terlambat', 'color': Colors.purple, 'icon': Icons.timer},
                      {'value': '$totalPegawai', 'label': 'Total Pegawai', 'color': Colors.green, 'icon': Icons.people},
                      {'value': '4.5/5', 'label': 'Rata-rata Feedback', 'color': Colors.yellow, 'icon': Icons.star},
                    ];

                    return GestureDetector(
                      onTap: () {
                        if (data[index]['label'] == 'Total Pegawai') {
                          Navigator.push(
                            context,
                            CupertinoPageRoute(builder: (context) =>  PegawaiScreen()),
                          );
                        }else if (index == 1) {
                        Navigator.push(
                          context,
                          CupertinoPageRoute(
                            builder: (context) =>
                                IzinCutiAdminPage(),
                          ),
                        );
                      }                        
                      },
                      child: _buildDashboardCard(
                        data[index]['value'] as String,
                        data[index]['label'] as String,
                        data[index]['color'] as Color,
                        data[index]['icon'] as IconData,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 10),
              const Divider(),
              _buildBottomNavigationBar(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDashboardCard(String value, String label, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.grey.shade300, blurRadius: 5, spreadRadius: 2),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 32, color: color),
          const SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color),
          ),
          const SizedBox(height: 5),
          Text(label, style: const TextStyle(fontSize: 16, color: Colors.black54)),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return CupertinoTabBar(
      currentIndex: _selectedIndex,
      onTap: _onTabSelected,
      backgroundColor: Colors.white,
      activeColor: Colors.blue,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Dashboard',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.list),
          label: 'Daftar Absensi',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Pegawai',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings),
          label: 'Pengaturan',
        ),
      ],
    );
  }
}
