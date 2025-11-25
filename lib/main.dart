import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

// Sesuai requirement: StatefulWidget utama harus bernama TodoListScreen
class TodoListScreen extends StatefulWidget {
  const TodoListScreen({super.key});

  @override
  State<TodoListScreen> createState() => _TodoListScreenState();
}

enum StatusTugas { tugasBaru, dalamProses, selesai }

class _TodoListScreenState extends State<TodoListScreen> {
  // ✅ PRIVATE + NAMA + LIST<STRING>
  List<String> _tugas_arta = [];
  List<StatusTugas> _status_arta = [];
  List<bool> _selesai_arta = [];

  final TextEditingController _controller = TextEditingController();
  late SharedPreferences _prefs;

  Future<void> _initData() async {
    _prefs = await SharedPreferences.getInstance();
    final String? dataJson = _prefs.getString('kanban_arta');
    if (dataJson != null) {
      final Map<String, dynamic> data = jsonDecode(dataJson);
      setState(() {
        _tugas_arta = List<String>.from(data['tugas'] as List);
        _status_arta = (data['status'] as List)
            .map((e) => StatusTugas.values[e as int])
            .toList();
        _selesai_arta = List<bool>.from(data['selesai'] as List);
      });
    } else {
      // ✅ 3 item default
      setState(() {
        _tugas_arta = [
          'Belajar Flutter',
          'Buat To-Do List',
          'Kumpulkan Tugas',
        ];
        _status_arta = [
          StatusTugas.tugasBaru,
          StatusTugas.dalamProses,
          StatusTugas.selesai,
        ];
        _selesai_arta = [false, false, true];
      });
      _simpanData();
    }
  }

  Future<void> _simpanData() async {
    final data = {
      'tugas': _tugas_arta,
      'status': _status_arta.map((s) => s.index).toList(),
      'selesai': _selesai_arta,
    };
    await _prefs.setString('kanban_arta', jsonEncode(data));
  }

  void _tambahTugas(String input) {
    String teks = input.trim();
    if (teks.isNotEmpty) {
      setState(() {
        _tugas_arta.add(teks);
        _status_arta.add(StatusTugas.tugasBaru);
        _selesai_arta.add(false);
      });
      _simpanData();
      _controller.clear();
    }
  }

  void _hapusTugas(int index) {
    setState(() {
      _tugas_arta.removeAt(index);
      _status_arta.removeAt(index);
      _selesai_arta.removeAt(index);
    });
    _simpanData();
  }

  void _toggleSelesai(int index, bool? value) {
    setState(() {
      _selesai_arta[index] = value ?? false;
      _status_arta[index] = value == true
          ? StatusTugas.selesai
          : StatusTugas.tugasBaru;
    });
    _simpanData();
  }

  void _pindahStatus(int index, StatusTugas baru) {
    setState(() {
      _status_arta[index] = baru;
      _selesai_arta[index] = (baru == StatusTugas.selesai);
    });
    _simpanData();
  }

  List<int> _getIndexByStatus(StatusTugas status) {
    List<int> indices = [];
    for (int i = 0; i < _status_arta.length; i++) {
      if (_status_arta[i] == status) indices.add(i);
    }
    return indices;
  }

  @override
  void initState() {
    super.initState();
    _initData();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, primarySwatch: Colors.blue),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('To-Do List - Arta'),
          centerTitle: true,
          backgroundColor: Colors.blue[700],
        ),
        body: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              // Input
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: 'Tugas baru...',
                        filled: true,
                        fillColor: Colors.grey[200],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () => _tambahTugas(_controller.text),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[700],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Tambah'),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // ✅ KANBAN BOARD (3 Kolom)
              Expanded(
                child: Row(
                  children: [
                    _buildKolom('Tugas Baru', StatusTugas.tugasBaru, Colors.blue[100]!, Colors.blue),
                    const SizedBox(width: 12),
                    _buildKolom('Dalam Proses', StatusTugas.dalamProses, Colors.yellow[100]!, Colors.orange),
                    const SizedBox(width: 12),
                    _buildKolom('Selesai', StatusTugas.selesai, Colors.green[100]!, Colors.green),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildKolom(String judul, StatusTugas status, Color headerColor, Color borderColor) {
    List<int> indices = _getIndexByStatus(status);

    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: borderColor, width: 1.5),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
              color: headerColor,
              child: Text(
                judul,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: indices.length,
                itemBuilder: (context, i) {
                  int idx = indices[i];

                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      // ✅ Checkbox (opsional)
                      leading: Checkbox(
                        value: _selesai_arta[idx],
                        onChanged: (value) => _toggleSelesai(idx, value),
                        activeColor: Colors.green,
                      ),
                      // ✅ ListTile dengan teks (List<String>)
                      title: Text(
                        _tugas_arta[idx],
                        style: TextStyle(
                          fontSize: 14,
                          color: _selesai_arta[idx] ? Colors.grey[600] : Colors.black87,
                          decoration: _selesai_arta[idx]
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                        ),
                      ),
                      // ✅ TRAILING: 1 icon saja (aman dari error layout)
                      trailing: SizedBox(
                        width: 70,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (status == StatusTugas.tugasBaru)
                              IconButton(
                                icon: const Icon(Icons.arrow_forward, size: 16),
                                onPressed: () => _pindahStatus(idx, StatusTugas.dalamProses),
                                padding: EdgeInsets.zero,
                                visualDensity: VisualDensity.compact,
                                color: Colors.orange,
                              ),
                            if (status == StatusTugas.dalamProses)
                              IconButton(
                                icon: const Icon(Icons.arrow_forward, size: 16),
                                onPressed: () => _pindahStatus(idx, StatusTugas.selesai),
                                padding: EdgeInsets.zero,
                                visualDensity: VisualDensity.compact,
                                color: Colors.green,
                              ),
                            IconButton(
                              icon: const Icon(Icons.delete, size: 16),
                              onPressed: () => _hapusTugas(idx),
                              padding: EdgeInsets.zero,
                              visualDensity: VisualDensity.compact,
                              color: Colors.grey,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const TodoListScreen());
}