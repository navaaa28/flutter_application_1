import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class KalenderPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('Hello World'),
      ),
      child: Center(
        child: Text(
          'Hello, World!',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

void main() {
  runApp(CupertinoApp(
    home: KalenderPage(),
  ));
}