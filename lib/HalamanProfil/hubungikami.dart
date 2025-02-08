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
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Hubungi Kami', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const SizedBox(height: 20),
                const Icon(CupertinoIcons.phone_circle_fill, size: 100, color: Colors.blueAccent),
                const SizedBox(height: 20),
                const Text(
                  'Butuh Bantuan?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Silakan hubungi kami melalui WhatsApp atau Email.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 30),
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ListTile(
                    leading: const Icon(CupertinoIcons.chat_bubble_2_fill, color: Colors.green),
                    title: const Text('WhatsApp Kami', style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: const Text('+62 896-3389-2082'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () => _openWhatsApp('6289633892082'),
                  ),
                ),
                const SizedBox(height: 20),
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ListTile(
                    leading: const Icon(CupertinoIcons.mail_solid, color: Colors.red),
                    title: const Text('Kirim Email', style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: const Text('DaniProCoding@aplikasi.com'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () => _sendEmail('danny.vatur@gmail.com'),
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