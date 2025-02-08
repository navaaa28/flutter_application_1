import 'package:flutter/material.dart';
import 'package:flutter_application_1/HalamanHome/kalender_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

class AdminCalendarPage extends StatefulWidget {
  @override
  _AdminCalendarPageState createState() => _AdminCalendarPageState();
}

class _AdminCalendarPageState extends State<AdminCalendarPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _submitEvent() async {
    if (_formKey.currentState!.validate()) {
      try {
        await _supabase.from('events').insert({
          'title': _titleController.text,
          'description': _descriptionController.text,
          'event_date': DateFormat('yyyy-MM-dd').format(_selectedDate),
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Event berhasil ditambahkan!')),
        );
        
        _titleController.clear();
        _descriptionController.clear();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Kalender'),
        actions: [
          IconButton(
            icon: Icon(Icons.calendar_today),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => KalenderPage()),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(labelText: 'Judul Event'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Harap isi judul';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: 'Deskripsi'),
                maxLines: 3,
              ),
              SizedBox(height: 20),
              ListTile(
                title: Text('Tanggal Event'),
                subtitle: Text(DateFormat('dd MMMM yyyy').format(_selectedDate)),
                trailing: Icon(Icons.calendar_today),
                onTap: () => _selectDate(context),
              ),
              ElevatedButton(
                onPressed: _submitEvent,
                child: Text('Simpan Event'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}