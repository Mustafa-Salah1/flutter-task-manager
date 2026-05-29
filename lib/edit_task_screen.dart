import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class EditTaskScreen extends StatefulWidget {
  final Map task;
  final String token;

  const EditTaskScreen({super.key, required this.task, required this.token});

  @override
  State<EditTaskScreen> createState() => _EditTaskScreenState();
}

class _EditTaskScreenState extends State<EditTaskScreen> {
  late TextEditingController titleController;
  late TextEditingController descriptionController;

  @override
  void initState() {
    super.initState();

    titleController = TextEditingController(text: widget.task['title']);

    descriptionController = TextEditingController(
      text: widget.task['description'],
    );
  }

  Future<void> updateTask() async {
    final response = await http.put(
      Uri.parse(
        'https://task-manager-api-production-ff43.up.railway.app/api/tasks/${widget.task['id']}',
      ),
      headers: {
        'Authorization': 'Bearer ${widget.token}',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'title': titleController.text,
        'description': descriptionController.text,
        'completed': widget.task['completed'],
      }),
    );

    if (response.statusCode == 200) {
      print("Task Updated");

      Navigator.pop(context, true);
    } else {
      print("Update Failed");
      print(response.statusCode);
      print(response.body);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff0B0B0F),

      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text("Edit Task"),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: titleController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(labelText: "Title"),
            ),

            const SizedBox(height: 20),

            TextField(
              controller: descriptionController,
              style: const TextStyle(color: Colors.white),
              maxLines: 3,
              decoration: const InputDecoration(labelText: "Description"),
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () async {
                  await updateTask();
                },
                child: const Text("Update Task"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
