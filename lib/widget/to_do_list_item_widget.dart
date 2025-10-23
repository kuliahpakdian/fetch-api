import 'package:flutter/material.dart';
import '../model/to_do_item.dart';

class ToDoListItemWidget extends StatelessWidget {
  final ToDoItem item;

  // Konstruktor wajib
  const ToDoListItemWidget({
    super.key,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
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
}