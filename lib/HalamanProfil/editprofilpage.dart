import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

class EditProfilPage extends StatefulWidget {
  final String userId;

  EditProfilPage({required this.userId});

  @override
  _EditProfilPageState createState() => _EditProfilPageState();
}

class _EditProfilPageState extends State<EditProfilPage> {
  final ImagePicker _picker = ImagePicker();
  XFile? _image;
  final TextEditingController _nameController = TextEditingController();
  final SupabaseClient supabase = Supabase.instance.client;

  // Fungsi untuk memilih gambar dari galeri
  Future<void> _pickImageFromGallery() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      _image = image;
    });
  }

  // Fungsi untuk mengambil gambar menggunakan kamera
  Future<void> _pickImageFromCamera() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    setState(() {
      _image = image;
    });
  }

  // Fungsi untuk mengupdate profil di Supabase
  Future<void> _updateProfile() async {
    try {
      String? imageUrl;
      if (_image != null) {
        final fileBytes = await File(_image!.path).readAsBytes();
        final fileName = '${widget.userId}.jpg';
        
        await supabase.storage.from('profile_pictures').uploadBinary(
          fileName,
          fileBytes,
          fileOptions: const FileOptions(upsert: true),
        );
        
        imageUrl = supabase.storage.from('profile_pictures').getPublicUrl(fileName);
      }

      await supabase.from('users').update({
        'display_name': _nameController.text,
        if (imageUrl != null) 'profile_url': imageUrl,
      }).eq('id', widget.userId);

      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: const Text('Profil Diperbarui'),
          content: const Text('Perubahan berhasil disimpan.'),
          actions: [
            CupertinoDialogAction(
              child: const Text('OK'),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      );
    } catch (e) {
      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: const Text('Error'),
          content: Text('Gagal memperbarui profil: $e'),
          actions: [
            CupertinoDialogAction(
              child: const Text('OK'),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Edit Profil'),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 12),
              CupertinoButton(
                child: const Text('Ganti Foto Profil'),
                onPressed: () {
                  showCupertinoModalPopup(
                    context: context,
                    builder: (context) => CupertinoActionSheet(
                      title: const Text('Pilih Sumber Foto'),
                      message: const Text('Pilih apakah ingin mengambil foto dari kamera atau galeri.'),
                      actions: [
                        CupertinoActionSheetAction(
                          onPressed: () {
                            Navigator.pop(context);
                            _pickImageFromCamera();
                          },
                          child: const Text('Ambil Foto dari Kamera'),
                        ),
                        CupertinoActionSheetAction(
                          onPressed: () {
                            Navigator.pop(context);
                            _pickImageFromGallery();
                          },
                          child: const Text('Pilih Foto dari Galeri'),
                        ),
                      ],
                      cancelButton: CupertinoActionSheetAction(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Batal', style: TextStyle(color: Colors.red)),
                      ),
                    ),
                  );
                },
              ),
              if (_image != null)
                Column(
                  children: [
                    Image.file(
                      File(_image!.path),
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                    ),
                    const SizedBox(height: 10),
                    const Text('Foto Profil Terpilih'),
                  ],
                ),
              const SizedBox(height: 12),
              CupertinoTextField(
                controller: _nameController,
                placeholder: 'Nama Baru',
              ),
              const SizedBox(height: 12),
              CupertinoButton(
                child: const Text('Simpan Perubahan'),
                onPressed: _updateProfile,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
