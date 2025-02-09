import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/HalamanAwal/halaman_login.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  late AnimationController _controller;
  late Animation<double> _logoScale;
  late Animation<double> _logoFade;
  late Animation<Offset> _textSlide;

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();

    _initializeNotifications(); // ✅ Inisialisasi notifikasi lokal

    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    );

    _logoFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    _logoScale = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(0.3, 1.0, curve: Curves.elasticOut),
      ),
    );

    _textSlide = Tween<Offset>(
      begin: Offset(0, 0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(0.5, 1.0, curve: Curves.easeOut),
      ),
    );

    _controller.forward();

    Timer(Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HalamanLogin(username: '')),
        );
      }
    });

    _setupFirebaseListeners();
    subscribeToTopic();
  }

  Future<void> _initializeNotifications() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final InitializationSettings settings = InitializationSettings(
      android: androidSettings,
    );

    await flutterLocalNotificationsPlugin.initialize(settings);
  }

  Future<void> subscribeToTopic() async {
    await FirebaseMessaging.instance.subscribeToTopic('Cobian');
    print('Berlangganan ke topic: Cobian');
  }

  static Future<void> _firebaseMessagingBackgroundHandler(
      RemoteMessage message) async {
    print('Menerima notifikasi saat aplikasi di background');
    print('Judul: ${message.notification?.title}');
    print('Isi: ${message.notification?.body}');

    final route = message.data['route'];
    final id = message.data['id'];
    final type = message.data['type'];

    print('Route: $route, ID: $id, Type: $type');

    final supabase = Supabase.instance.client;
    final response = await supabase.from('notifications').insert({
      'title': message.notification?.title,
      'body': message.notification?.body,
      'route': route,
      'item_id': id,
      'type': type,
      'received_at': DateTime.now().toIso8601String(),
    });

    if (response.error != null) {
      print('Error menyimpan notifikasi: ${response.error!.message}');
    } else {
      print('Notifikasi berhasil disimpan');
    }
  }

  void _setupFirebaseListeners() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (!mounted) return;
      print('Menerima notifikasi saat aplikasi berjalan');
      print('Judul: ${message.notification?.title}');
      print('Isi: ${message.notification?.body}');

      _showLocalNotification(message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      if (!mounted) return;
      print('Notifikasi dibuka oleh user');
      print('Judul: ${message.notification?.title}');
      print('Isi: ${message.notification?.body}');
    });
  }

  Future<void> _showLocalNotification(RemoteMessage message) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'high_importance_channel',
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

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1A237E),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Opacity(
                  opacity: _logoFade.value,
                  child: Transform.scale(
                    scale: _logoScale.value,
                    child: ClipOval(
                      child: Container(
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 10,
                              spreadRadius: 2,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Image.asset(
                          'images/logo.png',
                          width: 150,
                          height: 150,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),

            SizedBox(height: 40),

            SlideTransition(
              position: _textSlide,
              child: Column(
                children: [
                  Text(
                    'ACTIVO',
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.w300,
                      color: Colors.white,
                      letterSpacing: 2,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Attendance & To-Do List',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.9),
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
