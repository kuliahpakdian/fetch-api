import 'package:flutter/material.dart';
import '../services/to_do_service.dart';
import '../model/to_do_item.dart';
import '../widget/to_do_list_item_widget.dart';

class ActivityFetcher extends StatefulWidget {
  const ActivityFetcher({super.key});
  @override
  State<ActivityFetcher> createState() => _ActivityFetcherState();
}

class _ActivityFetcherState extends State<ActivityFetcher> {
  final ToDoService _toDoService = ToDoService();
  List<ToDoItem> _toDoItems = []; 
  bool isLoading = false;
  bool isCreating = false; // State untuk proses POST
  String? error; 

  String _initialMessage = "Tekan tombol untuk memuat daftar To-Do dari API. (Simulasi 10 item)";

  Future<void> fetchActivity() async {
    setState(() {
      isLoading = true;
      error = null;
      _toDoItems = []; 
      _initialMessage = "Sedang memuat daftar To-Do... Tunggu sebentar!";
    });

    try {
      final fetchedList = await _toDoService.fetchToDoList();
      setState(() {
        _toDoItems = fetchedList;
      });
    } catch (e) {
      debugPrint('Kesalahan dalam fetching di UI: $e');
      setState(() {
        error = e.toString().replaceFirst('Exception: ', ''); // Bersihkan prefix
        _initialMessage = 'Gagal memuat data.';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // Method untuk submit POST ---
  Future<void> _submitNewToDo(String title) async {
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Judul tidak boleh kosong!'), backgroundColor: Colors.orange),
      );
      return;
    }

    setState(() {
      isCreating = true;
      error = null; // Hapus error lama jika ada
    });

    try {
      final newItem = await _toDoService.createToDoItem(
        title: title, 
        userId: 1, 
        completed: false
      );

      setState(() {
        _toDoItems.insert(0, newItem);
        _initialMessage = "Tekan tombol untuk memuat daftar To-Do dari API.";
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Sukses! To-Do "${newItem.title}" ditambahkan.'),
          backgroundColor: Colors.green.shade700,
        ),
      );

    } catch (e) {
      debugPrint('Kesalahan dalam POST di UI: $e');
      setState(() {
        error = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      setState(() {
        isCreating = false;
      });
    }
  }

  // Method untuk menampilkan Dialog
  Future<void> _showCreateDialog() async {
    final TextEditingController titleController = TextEditingController();

    return showDialog<void>(
      context: context,
      // Jangan tutup dialog saat sedang loading (isCreating)
      barrierDismissible: !isCreating, 
      builder: (BuildContext context) {
        // Gunakan StatefulBuilder agar kita bisa update state (loading) di DALAM dialog
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Buat To-Do Baru'),
              content: SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[
                    if (isCreating)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              CircularProgressIndicator(),
                              SizedBox(height: 16),
                              Text("Menyimpan..."),
                            ],
                          ),
                        ),
                      )
                    else
                      TextField(
                        controller: titleController,
                        autofocus: true,
                        decoration: const InputDecoration(
                          hintText: 'Contoh: Belajar Flutter POST',
                          border: OutlineInputBorder(),
                        ),
                        // Izinkan submit via tombol 'enter' di keyboard
                        onSubmitted: (value) {
                           if (!isCreating) {
                              Navigator.of(context).pop(); // Tutup dialog
                              _submitNewToDo(titleController.text.trim());
                           }
                        },
                      ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Batal'),
                  // Nonaktifkan tombol jika sedang loading
                  onPressed: isCreating ? null : () {
                    Navigator.of(context).pop();
                  },
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    foregroundColor: Colors.white
                  ),
                  // Nonaktifkan tombol jika sedang loading
                  onPressed: isCreating ? null : () {
                    Navigator.of(context).pop(); // Tutup dialog
                    _submitNewToDo(titleController.text.trim());
                  },
                  child: Text(isCreating ? 'Menyimpan...' : 'Simpan'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildContent() {
    if (isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.indigo),
            ),
            SizedBox(height: 16),
            Text("Memuat data...", style: TextStyle(color: Colors.indigo)),
          ],
        ),
      );
    } else if (error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Text(
            '${error!}',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.red.shade700,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      );
    } else if (_toDoItems.isNotEmpty) {
      return ListView.builder(
        padding: const EdgeInsets.all(12.0),
        itemCount: _toDoItems.length,
        itemBuilder: (context, index) {
          return ToDoListItemWidget(item: _toDoItems[index]);
        },
      );
    } else {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Text(
            _initialMessage,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18, 
              color: Colors.grey.shade600,
            ),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Todo List' ,style: TextStyle(color: Colors.white),),
        backgroundColor: Colors.indigo,
        elevation: 4,
        // Tombol Aksi (Add) 
        actions: [
          IconButton(
            icon: const Icon(Icons.add_task, color: Colors.white),
            tooltip: 'Buat To-Do Baru',
            // Nonaktifkan tombol saat fetching ATAU creating
            onPressed: (isLoading || isCreating) ? null : _showCreateDialog,
          ),
        ],
      ),
      body: _buildContent(), 
      floatingActionButton: FloatingActionButton.extended(
        // Nonaktifkan jika isLoading ATAU isCreating
        onPressed: (isLoading || isCreating) ? null : fetchActivity,
        icon: const Icon(Icons.download),
        label: Text(
          // Tampilkan status loading yang sesuai
          isLoading ? 'Sedang Memuat...' : (isCreating ? 'Memproses...' : 'Muat Daftar To-Do'),
          style: const TextStyle(fontSize: 16),
        ),
        // Ubah warna saat disabled
        backgroundColor: (isLoading || isCreating) ? Colors.grey.shade600 : Colors.indigo,
        foregroundColor: Colors.white,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      bottomNavigationBar: _toDoItems.isEmpty && error == null && !isLoading
        ? const Padding(
            padding: EdgeInsets.only(bottom: 8.0),
            child: Text(
              'Catatan: Data diambil dari JSONPlaceholder dan disimulasikan.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          )
        : null,
    );
  }
}
