import 'package:flutter/cupertino.dart';
import 'package:flutter_application_1/HalamanTengah/dashboard_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'splashscreen.dart'; // Import file splash_screen.dart

void main() async { 
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://twthndrmrdkhtvgodqae.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InR3dGhuZHJtcmRraHR2Z29kcWFlIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzcxNTc3MDYsImV4cCI6MjA1MjczMzcwNn0.x1ZLQ8FL-i_GBhpo-zf5WeN8pIiwTlTdz1m324yyZkw',
  );
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const CupertinoApp(
      theme: CupertinoThemeData(brightness: Brightness.light),
      home: DashboardPage(username: '', password: '',), // SplashScreen menjadi halaman awal
    );
  }
}
