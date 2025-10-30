import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/to_do_item.dart';
import '../constants/api_constants.dart';

class ToDoService {

  Future<List<ToDoItem>> fetchToDoList() async {
    try {
      
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode != 200) {
        throw Exception('Gagal mengambil data: Status ${response.statusCode}');
      }
      final List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((json) => ToDoItem.fromJson(json)).toList();

    } catch (e) {
      throw Exception(e.toString().replaceFirst('Exception: ', 'Gagal mengambil daftar data: '));
    }
  }

  Future<ToDoItem> createToDoItem({
    required String title,
    required int userId,
    bool completed = false, // Default untuk item baru
  }) async {
    final ToDoItem itemToPost = ToDoItem(
      userId: userId, 
      id: 0, // ID ini hanya placeholder, tidak akan dikirim (lihat toJson())
      title: title, 
      completed: completed
    );

    try {
      final response = await http.post(
        Uri.parse(apiUrl), // API URL dari constants
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        // Gunakan method toJson() dari model
        body: jsonEncode(itemToPost.toJson()), 
      );

      print('Status Code POST: ${response.statusCode}');
      print('Body Respon POST: ${response.body}');

      if (response.statusCode == 201) {
        return ToDoItem.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Gagal membuat To-Do: Status ${response.statusCode}');
      }
    } catch (e) {
      throw Exception(e.toString().replaceFirst('Exception: ', 'Gagal mengirim data: '));
    }
  }
}