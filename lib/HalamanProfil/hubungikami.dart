import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class HubungiKamiPage extends StatelessWidget {
  const HubungiKamiPage({super.key});

 void _openWhatsApp(String phoneNumber) async {
  final Uri whatsappUri = Uri.parse('https://wa.me/$phoneNumber');
  if (await canLaunchUrl(whatsappUri)) {
    await launchUrl(whatsappUri);
  } else {
    debugPrint('Tidak dapat membuka WhatsApp');
  }
}

  // Fungsi untuk mengirim email
  void _sendEmail(String email) async {
    final Uri emailUri = Uri.parse('mailto:$email?subject=Permintaan Bantuan');
    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    } else {
      debugPrint('Tidak dapat membuka aplikasi email');
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Hubungi Kami'),
      ),
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            const Icon(CupertinoIcons.phone, size: 80, color: Colors.blue),
            const SizedBox(height: 20),
            const Text(
              'Butuh Bantuan?',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              'Silakan hubungi kami melalui telepon atau email.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
           const SizedBox(height: 30),
            CupertinoListTile(
              leading: const Icon(CupertinoIcons.chat_bubble_2_fill, color: Colors.green),
              title: const Text('WhatsApp Kami'),
              subtitle: const Text('+62 896-3389-2082'),
              onTap: () => _openWhatsApp('6289633892082'),
            ),
            const Divider(),
            CupertinoListTile(
              leading: const Icon(CupertinoIcons.mail_solid, color: Colors.red),
              title: const Text('Kirim Email'),
              subtitle: const Text('DaniProCoding@aplikasi.com'),
              onTap: () => _sendEmail('danny.vatur@gmail.com'),
            ),
          ],
        ),
      ),
    );
  }
}
