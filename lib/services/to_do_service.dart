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
}