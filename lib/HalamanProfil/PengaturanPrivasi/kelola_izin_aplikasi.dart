import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class KelolaIzinAplikasi extends StatefulWidget {
  const KelolaIzinAplikasi({super.key});

  @override
  _KelolaIzinAplikasiState createState() => _KelolaIzinAplikasiState();
}

class _KelolaIzinAplikasiState extends State<KelolaIzinAplikasi> {
  // Variabel untuk menyimpan status izin
  bool isLocationGranted = false;
  bool isCameraGranted = false;
  bool isMicrophoneGranted = false;
  bool isStorageGranted = false;

  @override
  void initState() {
    super.initState();
    // Memeriksa status izin saat pertama kali dibuka
    _checkPermissions();
  }

  // Fungsi untuk memeriksa status izin
  void _checkPermissions() async {
    var locationStatus = await Permission.location.status;
    var cameraStatus = await Permission.camera.status;
    var storageStatus = await Permission.storage.status;

    setState(() {
      isLocationGranted = locationStatus.isGranted;
      isCameraGranted = cameraStatus.isGranted;
      isStorageGranted = storageStatus.isGranted;
    });
  }

  // Fungsi untuk membuka pengaturan aplikasi
  void _openAppSettings() async {
    await openAppSettings();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Kelola Izin Aplikasi'),
      ),
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            CupertinoListSection.insetGrouped(
              header: const Text('Perizinan Aplikasi'),
              children: [
                CupertinoListTile(
                  leading: const Icon(CupertinoIcons.location, color: Colors.blue),
                  title: const Text('Izin Lokasi'),
                  subtitle: const Text('Akses lokasi untuk peta dan navigasi'),
                  trailing: CupertinoSwitch(
                    value: isLocationGranted,
                    onChanged: (bool value) {
                      setState(() {
                        isLocationGranted = value;
                      });
                      if (value) {
                        Permission.location.request();
                      } else {
                        _openAppSettings();
                      }
                    },
                  ),
                  onTap: () {
                    // Logika saat mengetuk izin lokasi
                    _openAppSettings();
                  },
                ),
                CupertinoListTile(
                  leading: const Icon(CupertinoIcons.camera, color: Colors.green),
                  title: const Text('Izin Kamera'),
                  subtitle: const Text('Akses kamera untuk mengambil foto dan video'),
                  trailing: CupertinoSwitch(
                    value: isCameraGranted,
                    onChanged: (bool value) {
                      setState(() {
                        isCameraGranted = value;
                      });
                      if (value) {
                        Permission.camera.request();
                      } else {
                        _openAppSettings();
                      }
                    },
                  ),
                  onTap: () {
                    // Logika saat mengetuk izin kamera
                    _openAppSettings();
                  },
                ),
                CupertinoListTile(
                  leading: const Icon(CupertinoIcons.photo, color: Colors.purple),
                  title: const Text('Izin Penyimpanan'),
                  subtitle: const Text('Akses penyimpanan untuk file media'),
                  trailing: CupertinoSwitch(
                    value: isStorageGranted,
                    onChanged: (bool value) {
                      setState(() {
                        isStorageGranted = value;
                      });
                      if (value) {
                        Permission.storage.request();
                      } else {
                        _openAppSettings();
                      }
                    },
                  ),
                  onTap: () {
                    // Logika saat mengetuk izin penyimpanan
                    _openAppSettings();
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(const CupertinoApp(
    home: KelolaIzinAplikasi(),
  ));
}
