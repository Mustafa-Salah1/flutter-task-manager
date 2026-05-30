import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:new_api/screens/tasks/add_task_screen.dart';
import 'package:new_api/screens/tasks/edit_task_screen.dart';
import '../../main.dart';

class TaskScreen extends StatefulWidget {
  final String token;

  const TaskScreen({super.key, required this.token});

  @override
  State<TaskScreen> createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  List tasks = [];
  List filteredTasks = [];
  bool isLoading = true;

  int get totalTasks => tasks.length;
  int get completedTasks =>
      tasks.where((task) => task['completed'] == true).length;
  int get pendingTasks =>
      tasks.where((task) => task['completed'] != true).length;

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
      final data = jsonDecode(response.body);

      setState(() {
        tasks = data;
        filteredTasks = data;
        isLoading = false;
      });

      print(tasks);
    } else {
      setState(() {
        isLoading = false;
      });

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

  void searchTasks(String query) {
    setState(() {
      filteredTasks = tasks.where((task) {
        final title = task['title'].toString().toLowerCase();
        final description = task['description'].toString().toLowerCase();

        final search = query.toLowerCase();

        return title.contains(search) || description.contains(search);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,

      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        centerTitle: true,
        title: const Text("My Tasks"),
        actions: [
          IconButton(
            icon: const Icon(Icons.dark_mode),
            onPressed: () {
              MyApp.of(context)?.toggleTheme();
            },
          ),
        ],
      ),

      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              children: [
                                const Text(
                                  "Total",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Text(totalTasks.toString()),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              children: [
                                const Text(
                                  "Done",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Text(completedTasks.toString()),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              children: [
                                const Text(
                                  "Pending",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Text(pendingTasks.toString()),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(12),
                  child: TextField(
                    onChanged: searchTasks,
                    decoration: InputDecoration(
                      hintText: 'Search tasks...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),

                Expanded(
                  child: filteredTasks.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.task_alt, size: 80),
                              SizedBox(height: 16),
                              Text(
                                "No Tasks Yet",
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text("Tap + to create your first task"),
                            ],
                          ),
                        )
                      : ListView.builder(
                          itemCount: filteredTasks.length,
                          itemBuilder: (context, index) {
                            final task = filteredTasks[index];

                            return GestureDetector(
                              onTap: () async {
                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => EditTaskScreen(
                                      task: task,
                                      token: widget.token,
                                    ),
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
                                color: Theme.of(context).cardColor,
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 15,
                                  vertical: 8,
                                ),
                                child: ListTile(
                                  title: Text(
                                    task['title'],
                                    style: Theme.of(
                                      context,
                                    ).textTheme.titleMedium,
                                  ),
                                  subtitle: Text(
                                    task['description'],
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodyMedium,
                                  ),
                                  trailing: Icon(
                                    task['completed']
                                        ? Icons.check_circle
                                        : Icons.radio_button_unchecked,
                                    color: task['completed']
                                        ? Colors.green
                                        : Colors.orange,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
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
