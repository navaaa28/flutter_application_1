import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class TodoPage extends StatefulWidget {
  const TodoPage({super.key});

  @override
  _TodoPageState createState() => _TodoPageState();
}

class _TodoPageState extends State<TodoPage> {
  final SupabaseClient _supabase = Supabase.instance.client;
  final TextEditingController _taskController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _deadlineController = TextEditingController();
  DateTime? _selectedDeadline;
  List<Map<String, dynamic>> _todos = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchTodos();
    _setupRealtime();
  }

  Future<void> _fetchTodos() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    try {
      final response = await _supabase
          .from('todos')
          .select('*')
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      setState(() {
        _todos = List<Map<String, dynamic>>.from(response);
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching todos: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _setupRealtime() {
    final userId = _supabase.auth.currentUser?.id;
    _supabase
        .from('todos')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId!)
        .listen((List<Map<String, dynamic>> data) {
      setState(() {
        _todos = data;
      });
    });
  }

  Future<void> _addTodo() async {
    if (_taskController.text.isEmpty || _titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Judul dan tugas tidak boleh kosong!')),
      );
      return;
    }

    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    await _supabase.from('todos').insert({
      'user_id': userId,
      'title': _titleController.text,
      'task': _taskController.text,
      'deadline': _selectedDeadline != null ? DateFormat('yyyy-MM-dd').format(_selectedDeadline!) : null,
      'is_complete': false,
    });

    _titleController.clear();
    _taskController.clear();
    _deadlineController.clear();
    _selectedDeadline = null;
  }

  Future<void> _selectDeadline() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() {
        _selectedDeadline = pickedDate;
        _deadlineController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
      });
    }
  }

  Future<void> _toggleComplete(Map<String, dynamic> todo) async {
    await _supabase
        .from('todos')
        .update({'is_complete': !(todo['is_complete'] as bool)})
        .eq('id', todo['id']);
  }

  Future<void> _deleteTodo(String id) async {
    await _supabase.from('todos').delete().eq('id', id);
  }

  Future<void> _editTodo(Map<String, dynamic> todo) async {
    _titleController.text = todo['title'];
    _taskController.text = todo['task'];
    _deadlineController.text = todo['deadline'] ?? '';
    _selectedDeadline = todo['deadline'] != null ? DateFormat('yyyy-MM-dd').parse(todo['deadline']) : null;

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Tugas'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  hintText: 'Masukkan Judul...',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 8),
              TextField(
                controller: _taskController,
                decoration: InputDecoration(
                  hintText: 'Tambahkan tugas baru...',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 8),
              TextField(
                controller: _deadlineController,
                decoration: InputDecoration(
                  hintText: 'Pilih deadline...',
                  suffixIcon: Icon(Icons.calendar_today),
                  border: OutlineInputBorder(),
                ),
                readOnly: true,
                onTap: _selectDeadline,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () async {
                await _supabase.from('todos').update({
                  'title': _titleController.text,
                  'task': _taskController.text,
                  'deadline': _selectedDeadline != null ? DateFormat('yyyy-MM-dd').format(_selectedDeadline!) : null,
                }).eq('id', todo['id']);

                _titleController.clear();
                _taskController.clear();
                _deadlineController.clear();
                _selectedDeadline = null;

                Navigator.of(context).pop();
              },
              child: Text('Simpan'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'To-Do List',
          style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.blue,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      TextField(
                        controller: _titleController,
                        decoration: InputDecoration(
                          hintText: 'Masukkan Judul...',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      SizedBox(height: 8),
                      TextField(
                        controller: _taskController,
                        decoration: InputDecoration(
                          hintText: 'Tambahkan tugas baru...',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      SizedBox(height: 8),
                      TextField(
                        controller: _deadlineController,
                        decoration: InputDecoration(
                          hintText: 'Pilih deadline...',
                          suffixIcon: Icon(Icons.calendar_today),
                          border: OutlineInputBorder(),
                        ),
                        readOnly: true,
                        onTap: _selectDeadline,
                      ),
                      SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: _addTodo,
                        child: Text('Tambah Tugas'),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: _todos.length,
                    itemBuilder: (context, index) {
                      final todo = _todos[index];
                      return Card(
                        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: ListTile(
                          title: Text(
                            todo['title'] ?? 'Tanpa Judul',
                            style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(todo['task'] ?? 'Tidak ada tugas'),
                              if (todo['deadline'] != null) Text('Deadline: ${todo['deadline']}'),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit, color: Colors.blue),
                                onPressed: () => _editTodo(todo),
                              ),
                              IconButton(
                                icon: Icon(Icons.delete, color: Colors.red),
                                onPressed: () async {
                                  final confirm = await showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        title: Text('Hapus Tugas'),
                                        content: Text('Apakah Anda yakin ingin menghapus tugas ini?'),
                                        actions: [
                                          TextButton(
                                            onPressed: () {
                                              Navigator.of(context).pop(false);
                                            },
                                            child: Text('Batal'),
                                          ),
                                          ElevatedButton(
                                            onPressed: () {
                                              Navigator.of(context).pop(true);
                                            },
                                            child: Text('Hapus'),
                                          ),
                                        ],
                                      );
                                    },
                                  );

                                  if (confirm == true) {
                                    await _deleteTodo(todo['id']);
                                  }
                                },
                              ),
                              Checkbox(
                                value: todo['is_complete'] ?? false,
                                onChanged: (value) => _toggleComplete(todo),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}