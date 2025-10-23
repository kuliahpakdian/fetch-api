import 'package:flutter/material.dart';
import '../services/to_do_service.dart';
import '../model/to_do_item.dart';

class ActivityFetcher extends StatefulWidget {
  const ActivityFetcher({super.key});

  @override
  State<ActivityFetcher> createState() => _ActivityFetcherState();
}

class _ActivityFetcherState extends State<ActivityFetcher> {
  final ToDoService _toDoService = ToDoService();

  List<ToDoItem> _toDoItems = []; 
  bool isLoading = false;
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

  Widget _buildToDoListItem(ToDoItem item) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: item.completed ? Colors.green.shade600 : Colors.orange.shade600,
          child: Text(
            item.id.toString(),
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(
          item.title,
          style: TextStyle(
            decoration: item.completed ? TextDecoration.lineThrough : TextDecoration.none,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: Icon(
          item.completed ? Icons.check_circle : Icons.pending,
          color: item.completed ? Colors.green : Colors.orange,
        ),
      ),
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
          return _buildToDoListItem(_toDoItems[index]);
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
        title: const Text('API Fetcher Flutter (ListView)'),
        backgroundColor: Colors.indigo,
        elevation: 4,
      ),
      body: _buildContent(), 
      floatingActionButton: FloatingActionButton.extended(
        onPressed: isLoading ? null : fetchActivity,
        icon: const Icon(Icons.download),
        label: Text(
          isLoading ? 'Sedang Memuat...' : 'Muat Daftar To-Do',
          style: const TextStyle(fontSize: 16),
        ),
        backgroundColor: Colors.indigo,
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
