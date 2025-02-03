import 'package:flutter/material.dart';

class StatusBar extends StatelessWidget {
  const StatusBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 36),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '9:41',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              fontFamily: 'SF Pro Text',
            ),
          ),
          Row(
            children: [
              Image.asset('assets/signal.png', width: 18, height: 12),
              const SizedBox(width: 8),
              Image.asset('assets/wifi.png', width: 17, height: 12),
              const SizedBox(width: 8),
              Image.asset('assets/battery.png', width: 28, height: 13),
            ],
          ),
        ],
      ),
    );
  }
}