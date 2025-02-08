import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AbsenKeluarPage extends StatefulWidget {
  final String username;

  const AbsenKeluarPage({super.key, required this.username});

  @override
  State<AbsenKeluarPage> createState() => _AbsenKeluarPageState();
}

class _AbsenKeluarPageState extends State<AbsenKeluarPage> {
  final TextEditingController locationController = TextEditingController();
  final SupabaseClient supabase = Supabase.instance.client;
  String displayName = 'Pengguna';
  String role = '';
  File? _photoFile;
  final SupabaseClient client = Supabase.instance.client;
  final Color primaryColor = Color(0xFF2A2D7C);
  final Color accentColor = Color(0xFF00C2FF);
  final LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF2A2D7C), Color(0xFF00C2FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  @override
  void initState() {
    super.initState();
    _fetchDisplayName();
    _fetchRole();
  }

  Future<void> _fetchRole() async {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;

    if (user == null) {
      print('User not logged in');
      return;
    }

    try {
      final response = await supabase
          .from('users')
          .select('role')
          .eq('id', user.id)
          .single();
      setState(() {
        role = response['role'];
      });
    } catch (e) {
      print('Error fetching profile image: $e');
    }
  }

  Future<void> _fetchDisplayName() async {
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
        displayName = response['display_name'];
      });
    } catch (e) {
      print('$e');
    }
  }

  /// Mendapatkan Lokasi Saat Ini
  Future<void> _getCurrentLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always) {
        Position position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high);

        // Convert coordinates to address
        List<Placemark> placemarks = await placemarkFromCoordinates(
            position.latitude, position.longitude);
        if (placemarks.isNotEmpty) {
          Placemark place = placemarks.first;
          locationController.text =
              "${place.street}, ${place.subLocality}, ${place.locality}";
        } else {
          locationController.text = "Gagal mendapatkan nama lokasi.";
        }
      } else {
        locationController.text = "Izin lokasi ditolak.";
      }
    } catch (e) {
      locationController.text = "Gagal mendapatkan lokasi: $e";
    }
  }

  /// Mengambil Foto
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? photo = await picker.pickImage(source: ImageSource.camera);

    if (photo != null) {
      setState(() {
        _photoFile = File(photo.path);
      });
    } else {
      setState(() {
        _photoFile = null;
      });
    }
  }

  Future<void> _submitAttendance(BuildContext context) async {
    final now = DateTime.now();
    final formattedDate = DateFormat('yyyy-MM-dd HH:mm:ss').format(now);
    final dateFolder = DateFormat('yyyy-MM-dd').format(now); // Folder per hari
    final location = locationController.text;
    final photoPath = _photoFile?.path;

    if (location.isEmpty || photoPath == null) {
      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: const Text('Error'),
          content: const Text('Semua field harus diisi.'),
          actions: [
            CupertinoDialogAction(
              child: const Text('OK'),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      );
      return;
    }

    try {
      // Mendapatkan user ID dari autentikasi Supabase
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) {
        showCupertinoDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: const Text('Error'),
            content: const Text('User tidak ditemukan atau belum login.'),
            actions: [
              CupertinoDialogAction(
                child: const Text('OK'),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        );
        return;
      }

      // Periksa apakah user sudah absen masuk hari ini
      final todayStart =
          DateTime(now.year, now.month, now.day).toIso8601String();
      final todayEnd =
          DateTime(now.year, now.month, now.day, 23, 59, 59).toIso8601String();

      final existingAttendance = await Supabase.instance.client
          .from('absensi')
          .select()
          .eq('user_id', userId)
          .gte('tanggal', todayStart)
          .lte('tanggal', todayEnd)
          .maybeSingle();

      if (existingAttendance == null) {
        showCupertinoDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: const Text('Error'),
            content: const Text('Anda belum melakukan absensi masuk hari ini.'),
            actions: [
              CupertinoDialogAction(
                child: const Text('OK'),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        );
        return;
      }

      // Nama file dengan struktur folder per hari
      final fileName =
          '$dateFolder/${widget.username}_keluar_${formattedDate.replaceAll(":", "-")}.jpg';

      // Upload foto ke bucket
      final photoUrl = await Supabase.instance.client.storage
          .from('absensi-photos') // Bucket name
          .uploadBinary(
            fileName,
            File(photoPath).readAsBytesSync(),
          );


      await Supabase.instance.client
          .from('absensi')
          .insert({
        'user_id': userId,
        'display_name': displayName,
        'tanggal': formattedDate,
        'lokasi': location,
        'foto_url': photoUrl,
        'jenis_absen': 'keluar',
      });


      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: const Text('Berhasil'),
          content: Text('Absen keluar berhasil disimpan pada $formattedDate.'),
          actions: [
            CupertinoDialogAction(
              child: const Text('OK'),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      );
    } catch (e) {
      // Tangani error
      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: const Text('Error'),
          content: Text('Terjadi kesalahan saat menyimpan data: $e'),
          actions: [
            CupertinoDialogAction(
              child: const Text('OK'),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(
          'Absen Keluar',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        backgroundColor: primaryColor,
        border: null,
        previousPageTitle: 'Dashboard',
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, Color(0xFFF0F4FF)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeaderSection(),
                SizedBox(height: 20),
                _buildUserInfoSection(),
                SizedBox(height: 20),
                _buildFormSection(),
                SizedBox(height: 30),
                _buildSubmitButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Formulir Absen Keluar',
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: primaryColor,
          ),
        ),
        SizedBox(height: 4),
        Text(
          'Silahkan lengkapi form berikut untuk melakukan absen masuk',
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildUserInfoSection() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoRow('Nama Lengkap', displayName),
          Divider(height: 20),
          _buildInfoRow('Jabatan', role),
          Divider(height: 20),
          _buildInfoRow(
              'Tanggal', DateFormat('yyyy-MM-dd').format(DateTime.now())),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: primaryColor,
          ),
        ),
      ],
    );
  }

  Widget _buildFormSection() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildLocationField(),
          SizedBox(height: 20),
          _buildPhotoSection(),
        ],
      ),
    );
  }

  Widget _buildLocationField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Lokasi Saat Ini',
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 8),
        GestureDetector(
          onTap: _getCurrentLocation,
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    locationController.text.isEmpty
                        ? 'Tekan untuk mendapatkan lokasi'
                        : locationController.text,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: locationController.text.isEmpty
                          ? Colors.grey[400]
                          : primaryColor,
                    ),
                    maxLines: 2,
                  ),
                ),
                Icon(
                  CupertinoIcons.location_solid,
                  color: primaryColor,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPhotoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Foto Bukti',
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 8),
        CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: _pickImage,
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Column(
              children: [
                if (_photoFile != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      _photoFile!,
                      width: double.infinity,
                      height: 200,
                      fit: BoxFit.cover,
                    ),
                  ),
                Container(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Icon(
                    CupertinoIcons.camera,
                    size: 40,
                    color: primaryColor,
                  ),
                ),
                Text(
                  _photoFile != null
                      ? 'Foto telah diambil'
                      : 'Tekan untuk mengambil foto',
                  style: GoogleFonts.poppins(
                    color: _photoFile != null ? primaryColor : Colors.grey[400],
                  ),
                ),
                SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: accentColor.withOpacity(0.3),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: CupertinoButton(
        padding: EdgeInsets.symmetric(vertical: 18, horizontal: 40),
        borderRadius: BorderRadius.circular(30),
        color: primaryColor,
        onPressed: () => _submitAttendance(context),
        child: Text(
          'Simpan Absensi',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  // Update dialog untuk konsistensi tema
  void _showDialog(String title, String content) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text(title, style: GoogleFonts.poppins(color: primaryColor)),
        content: Text(content, style: GoogleFonts.poppins()),
        actions: [
          CupertinoDialogAction(
            child: Text('OK', style: GoogleFonts.poppins(color: primaryColor)),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}
