import 'package:flutter/cupertino.dart';
import 'splashscreen.dart'; // Import file splash_screen.dart

void main() => runApp(const MainApp());

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const CupertinoApp(
      theme: CupertinoThemeData(brightness: Brightness.light),
      home: SplashScreen(), // SplashScreen menjadi halaman awal
    );
  }
}
