import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart'; // For PlatformException handling
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
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
  File? _photoFile;
  final SupabaseClient client = Supabase.instance.client;

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
        List<Placemark> placemarks =
            await placemarkFromCoordinates(position.latitude, position.longitude);
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
      final todayStart = DateTime(now.year, now.month, now.day).toIso8601String();
      final todayEnd = DateTime(now.year, now.month, now.day, 23, 59, 59).toIso8601String();

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
      final fileName = '$dateFolder/${widget.username}_keluar_${formattedDate.replaceAll(":", "-")}.jpg';

      // Upload foto ke bucket
      final photoUrl = await Supabase.instance.client.storage
          .from('absensi-photos') // Bucket name
          .uploadBinary(
            fileName, // File name dengan struktur folder
            File(photoPath).readAsBytesSync(), // File data
          );

      // Simpan data ke tabel `absensi`
      await Supabase.instance.client
          .from('absensi') // Table name
          .insert({
        'user_id': userId, // Menggunakan user_id dari autentikasi
        'tanggal': formattedDate,
        'lokasi': location,
        'foto_url': photoUrl,
        'jenis_absen': 'keluar',
      });

      // Tampilkan dialog sukses
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
        middle: const Text('Absen Keluar'),
        previousPageTitle: 'Dashboard',
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Nama Pengguna
              Text(
                'Nama: ${widget.username}',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),

              // Tanggal
              Text(
                'Tanggal: ${DateFormat('yyyy-MM-dd').format(DateTime.now())}',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),

              // Lokasi
              CupertinoTextField(
                controller: locationController,
                placeholder: 'Tekan untuk mendapatkan lokasi',
                padding: const EdgeInsets.all(16),
                readOnly: true,
                onTap: _getCurrentLocation,
              ),
              const SizedBox(height: 16),

              // Ambil Foto
              CupertinoButton.filled(
                onPressed: _pickImage,
                child: const Text('Ambil Foto'),
              ),
              const SizedBox(height: 16),

              // Tampilkan Foto Jika Ada
              if (_photoFile != null) ...[
                Text(
                  'Foto berhasil diambil:',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Image.file(
                  _photoFile!,
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ],
              const Spacer(),

              // Tombol Simpan
              SizedBox(
                width: double.infinity,
                child: CupertinoButton.filled(
                  onPressed: () {
                    final location = locationController.text;

                    if (location.isEmpty || _photoFile == null) {
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

                    _submitAttendance(context);
                  },
                  child: const Text('Simpan'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
