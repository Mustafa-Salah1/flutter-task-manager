import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'add_task_screen.dart';
import 'edit_task_screen.dart';

class TaskScreen extends StatefulWidget {
  final String token;

  const TaskScreen({super.key, required this.token});

  @override
  State<TaskScreen> createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  List tasks = [];

  @override
  void initState() {
    super.initState();
    getTasks();
  }

  Future<void> getTasks() async {
    final response = await http.get(
      Uri.parse(
        'https://task-manager-api-production-ff43.up.railway.app/api/tasks',
      ),
      headers: {
        'Authorization': 'Bearer ${widget.token}',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      setState(() {
        tasks = jsonDecode(response.body);
      });

      print(tasks);
    } else {
      print('Failed to load tasks');
      print(response.statusCode);
    }
  }

  Future<void> deleteTask(int id) async {
    final response = await http.delete(
      Uri.parse(
        'https://task-manager-api-production-ff43.up.railway.app/api/tasks/$id',
      ),
      headers: {
        'Authorization': 'Bearer ${widget.token}',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      print("Task Deleted");
      getTasks();
    } else {
      print("Delete Failed");
      print(response.statusCode);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff0B0B0F),

      appBar: AppBar(
        backgroundColor: Colors.black,
        centerTitle: true,
        title: const Text("My Tasks", style: TextStyle(color: Colors.white)),
      ),

      body: ListView.builder(
        itemCount: tasks.length,
        itemBuilder: (context, index) {
          final task = tasks[index];

          return GestureDetector(
            onTap: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      EditTaskScreen(task: task, token: widget.token),
                ),
              );

              if (result == true) {
                getTasks();
              }
            },

            onLongPress: () {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text("Delete Task"),
                    content: const Text(
                      "Are you sure you want to delete this task?",
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text("Cancel"),
                      ),
                      TextButton(
                        onPressed: () async {
                          Navigator.pop(context);

                          await deleteTask(task['id']);
                        },
                        child: const Text("Delete"),
                      ),
                    ],
                  );
                },
              );
            },

            child: Card(
              color: const Color(0xff1A1A1A),
              margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
              child: ListTile(
                title: Text(
                  task['title'],
                  style: const TextStyle(color: Colors.white),
                ),
                subtitle: Text(
                  task['description'],
                  style: const TextStyle(color: Colors.grey),
                ),
                trailing: Icon(
                  task['completed']
                      ? Icons.check_circle
                      : Icons.radio_button_unchecked,
                  color: task['completed'] ? Colors.green : Colors.orange,
                ),
              ),
            ),
          );
        },
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddTaskScreen(token: widget.token),
            ),
          );

          if (result == true) {
            getTasks();
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
