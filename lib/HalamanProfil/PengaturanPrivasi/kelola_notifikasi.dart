import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NotifikasiPage extends StatefulWidget {
  const NotifikasiPage({super.key});

  @override
  _NotifikasiPageState createState() => _NotifikasiPageState();
}

class _NotifikasiPageState extends State<NotifikasiPage> {
  bool _pushNotifications = false;
  final Color _primaryColor = const Color(0xFF2A2D7C);
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final SupabaseClient _supabase = Supabase.instance.client;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
  }

  /// 🔹 Meminta izin & setup notifikasi
  Future<void> _initializeNotifications() async {
    // Minta izin notifikasi dari user
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print("Izin notifikasi diberikan ✅");

      // Ambil token FCM
      String? token = await _firebaseMessaging.getToken();
      if (token != null) {
        print("FCM Token: $token");
        await _sendTokenToSupabase(token);
      }

      // Setup notifikasi lokal
      await _setupLocalNotifications();

      // Event listener untuk notifikasi yang masuk
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        print("Notifikasi diterima saat aplikasi berjalan: ${message.notification?.title}");
        _showLocalNotification(message);
      });

      setState(() {
        _pushNotifications = true;
      });
    } else {
      print("Izin notifikasi ditolak ❌");
    }
  }

  /// 🔹 Setup Notifikasi Lokal
  Future<void> _setupLocalNotifications() async {
    const AndroidInitializationSettings androidInitSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initSettings =
        InitializationSettings(android: androidInitSettings);

    await flutterLocalNotificationsPlugin.initialize(initSettings);
  }

  /// 🔹 Menampilkan Notifikasi Lokal
  Future<void> _showLocalNotification(RemoteMessage message) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'high_importance_channel', // ID Channel
      'High Importance Notifications',
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails notificationDetails =
        NotificationDetails(android: androidDetails);

    await flutterLocalNotificationsPlugin.show(
      0,
      message.notification?.title ?? 'Notifikasi',
      message.notification?.body ?? 'Isi pesan tidak tersedia',
      notificationDetails,
    );
  }

  /// 🔹 Simpan Token FCM ke Supabase
  Future<void> _sendTokenToSupabase(String token) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) {
      print('User tidak terautentikasi');
      return;
    }

    try {
      await _supabase.from('user_tokens').upsert({
        'user_id': userId,
        'fcm_token': token,
      });
      print('Token berhasil disimpan di Supabase ✅');
    } catch (e) {
      print('Gagal menyimpan token: $e ❌');
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        backgroundColor: _primaryColor,
        middle: Text(
          'Pengaturan Notifikasi',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Icon(CupertinoIcons.back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: Scaffold(
          body: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        ListTile(
                          leading: Icon(Icons.notifications, color: _primaryColor),
                          title: Text(
                            'Notifikasi Push',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          subtitle: Text(
                            'Terima notifikasi langsung di perangkat',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                          trailing: Switch(
                            value: _pushNotifications,
                            onChanged: (bool value) async {
                              if (value) {
                                await _initializeNotifications();
                              } else {
                                await _firebaseMessaging.deleteToken();
                                setState(() => _pushNotifications = false);
                              }
                            },
                            activeColor: _primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
