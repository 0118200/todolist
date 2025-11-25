import 'package:flutter/material.dart';

void main() {
  runApp(const TodolistArta());
}

class TodolistArta extends StatefulWidget {
  final bool? isBeranda;
  final String? beranda;

  const TodolistArta({this.isBeranda, this.beranda, super.key});

  @override
  State<TodolistArta> createState() => LayarAtas();
}

class LayarAtas extends State<TodolistArta> {
  // Daftar tugas jadi variabel private di luar build
  List<String> _tasksArta = [
    'Belajar Flutter',
    'Buat To-Do List',
    'Kumpulkan Tugas',
  ];

  // Controller buat TextField
  final TextEditingController _textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Welcome to TODOLIST :)'),
          leading: IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              // Nanti bisa diisi buat drawer atau menu
            },
          ),
          actions: const [
            IconButton(icon: Icon(Icons.search), onPressed: null),
            IconButton(icon: Icon(Icons.more_vert), onPressed: null),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              //input teks + tombol tambah
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      decoration: InputDecoration(
                        hintText: "Tambah tugas...",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () {
                      String taskBaru = _textController.text.trim();
                      if (taskBaru.isNotEmpty) {
                        setState(() {
                          _tasksArta.add(taskBaru);
                        });
                        _textController.clear();
                      }
                    },
                    child: const Text("Tambah"),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              //daftar tugas
              Expanded(
                child: ListView.builder(
                  itemCount: _tasksArta.length,
                  itemBuilder: (context, index) {
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      child: ListTile(
                        title: Text(_tasksArta[index]),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            setState(() {
                              _tasksArta.removeAt(index);
                            });
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }
}