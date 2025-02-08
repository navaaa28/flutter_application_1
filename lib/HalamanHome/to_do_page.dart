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
    _setupRealtime();
    _fetchTodos();
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
        .order('created_at', ascending: false)
        .listen((List<Map<String, dynamic>> data) {
          if (mounted) {
            setState(() {
              _todos = data;
            });
          }
        });
  }

  Future<void> _addTodo() async {
    if (_taskController.text.isEmpty || _titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Judul dan tugas tidak boleh kosong!')),
      );
      return;
    }

    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    // Optimistic UI Update
    final newTodo = {
      'id': 'temp_${DateTime.now().millisecondsSinceEpoch}',
      'user_id': userId,
      'title': _titleController.text,
      'task': _taskController.text,
      'deadline': _selectedDeadline != null
          ? DateFormat('yyyy-MM-dd').format(_selectedDeadline!)
          : null,
      'is_complete': false,
      'created_at': DateTime.now().toIso8601String(),
    };

    setState(() {
      _todos = [newTodo, ..._todos];
    });

    try {
      await _supabase.from('todos').insert({
        'user_id': userId,
        'title': _titleController.text,
        'task': _taskController.text,
        'deadline': _selectedDeadline != null
            ? DateFormat('yyyy-MM-dd').format(_selectedDeadline!)
            : null,
        'is_complete': false,
      });
    } catch (e) {
      // Rollback jika gagal
      setState(() {
        _todos = _todos.where((todo) => todo['id'] != newTodo['id']).toList();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal menambahkan tugas')),
      );
    }

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
    // Optimistic UI Update
    final originalState = todo['is_complete'];
    setState(() {
      todo['is_complete'] = !(todo['is_complete'] as bool);
    });

    try {
      await _supabase
          .from('todos')
          .update({'is_complete': !originalState}).eq('id', todo['id']);
    } catch (e) {
      // Rollback jika gagal
      setState(() {
        todo['is_complete'] = originalState;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal memperbarui status')),
      );
    }
  }


  Future<void> _deleteTodo(String id) async {
      await _supabase.from('todos').delete().eq('id', id.trim());
  }

  Future<void> _editTodo(Map<String, dynamic> todo) async {
    _titleController.text = todo['title'];
    _taskController.text = todo['task'];
    _deadlineController.text = todo['deadline'] ?? '';
    _selectedDeadline = todo['deadline'] != null
        ? DateFormat('yyyy-MM-dd').parse(todo['deadline'])
        : null;

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
                  'deadline': _selectedDeadline != null
                      ? DateFormat('yyyy-MM-dd').format(_selectedDeadline!)
                      : null,
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
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: const Color(0xFF2A2D7C),
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF2A2D7C), Color(0xFF6A6DA6)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Colors.white),
              )
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
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 16, vertical: 14),
                          ),
                        ),
                        SizedBox(height: 8),
                        TextField(
                          controller: _taskController,
                          decoration: InputDecoration(
                            hintText: 'Tambahkan tugas baru...',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 16, vertical: 14),
                          ),
                        ),
                        SizedBox(height: 8),
                        TextField(
                          controller: _deadlineController,
                          decoration: InputDecoration(
                            hintText: 'Pilih deadline...',
                            suffixIcon: Icon(Icons.calendar_today,
                                color: Color(0xFF2A2D7C)),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 16, vertical: 14),
                          ),
                          readOnly: true,
                          onTap: _selectDeadline,
                        ),
                        SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _addTodo,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF2A2D7C),
                            padding: EdgeInsets.symmetric(
                                horizontal: 32, vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(
                            'Tambah Tugas',
                            style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: _fetchTodos,
                      child: ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemCount: _todos.length,
                        itemBuilder: (context, index) {
                          final todo = _todos[index];
                          return Dismissible(
                            key: Key(todo['id'].toString()),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 20),
                              color: Colors.red,
                              child: const Icon(Icons.delete, color: Colors.white),
                            ),
                            confirmDismiss: (direction) async {
                              return await showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Hapus Tugas'),
                                  content: const Text(
                                      'Apakah Anda yakin ingin menghapus tugas ini?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context, false),
                                      child: const Text('Batal'),
                                    ),
                                    ElevatedButton(
                                      onPressed: () => Navigator.pop(context, true),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red,
                                      ),
                                      child: const Text('Hapus'),
                                    ),
                                  ],
                                ),
                              );
                            },
                            onDismissed: (direction) => _deleteTodo(todo['id']),
                            child: TodoItem(
                              todo: todo,
                              onToggle: () => _toggleComplete(todo),
                              onEdit: () => _editTodo(todo),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class TodoItem extends StatelessWidget {
  final Map<String, dynamic> todo;
  final VoidCallback onToggle;
  final VoidCallback onEdit;

  const TodoItem({
    super.key,
    required this.todo,
    required this.onToggle,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ListTile(
        title: Text(
          todo['title'] ?? 'Tanpa Judul',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            decoration: todo['is_complete'] 
                ? TextDecoration.lineThrough 
                : TextDecoration.none,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              todo['task'] ?? 'Tidak ada deskripsi',
              style: TextStyle(
                decoration: todo['is_complete']
                    ? TextDecoration.lineThrough
                    : TextDecoration.none,
              ),
            ),
            if (todo['deadline'] != null)
              Text(
                'Deadline: ${todo['deadline']}',
                style: const TextStyle(fontSize: 12),
              ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Color(0xFF2A2D7C)),
              onPressed: onEdit,
            ),
            Checkbox(
              value: todo['is_complete'],
              onChanged: (value) => onToggle(),
              activeColor: const Color(0xFF2A2D7C),
            ),
          ],
        ),
      ),
    );
  }
}