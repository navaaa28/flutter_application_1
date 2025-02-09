import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/Pertama/splashscreen.dart'; // Sesuaikan path import
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// Inisialisasi plugin notifikasi lokal
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

// Handler untuk notifikasi latar belakang (harus top-level)
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('Menerima notifikasi saat aplikasi di background');
  print('Judul: ${message.notification?.title}');
  print('Isi: ${message.notification?.body}');

  // Akses custom data
  final route = message.data['route'];
  final id = message.data['id'];
  final type = message.data['type'];

  print('Route: $route, ID: $id, Type: $type');

  // Simpan notifikasi ke Supabase
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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi Firebase
  await Firebase.initializeApp();

  // Inisialisasi Supabase
  await Supabase.initialize(
    url: 'https://twthndrmrdkhtvgodqae.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InR3dGhuZHJtcmRraHR2Z29kcWFlIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzcxNTc3MDYsImV4cCI6MjA1MjczMzcwNn0.x1ZLQ8FL-i_GBhpo-zf5WeN8pIiwTlTdz1m324yyZkw',
  );

  // Menangani notifikasi saat aplikasi di background
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Inisialisasi plugin notifikasi lokal
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  final InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  await FirebaseMessaging.instance.subscribeToTopic('Cobian');
  print('Berlangganan ke topik: Cobian');

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Aplikasi Absen',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: SplashScreen(),
    );
  }
}
