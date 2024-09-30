import 'package:flutter/material.dart';
import 'package:todo/database/todo_database.dart';

/// Home page for managing to-do items.
class TodoHomepage extends StatefulWidget {
  const TodoHomepage({Key? key}) : super(key: key);

  @override
  State<TodoHomepage> createState() => _TodoHomepageState();
}

class _TodoHomepageState extends State<TodoHomepage> {
  late List<TodoItem> todoItems;
  late TodoDatabase database;

  /// Initializes state and loads tasks.
  @override
  void initState() {
    super.initState();
    todoItems = [];
    database = TodoDatabase.instance;
    _loadTasks();
  }

  /// Loads tasks from the database.
  void _loadTasks() async {
    List<TodoItem> tasks = await database.getTasks();
    setState(() {
      todoItems = tasks;
    });
  }

  /// Opens a dialog to add a new task.
  void _addNewTask(BuildContext context) async {
    TextEditingController controller = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Add New Task"),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(hintText: 'Enter task name'),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child:
                  const Text('Cancel', style: TextStyle(color: Colors.black)),
            ),
            ElevatedButton(
              onPressed: () async {
                String taskName = controller.text;
                if (taskName.isNotEmpty) {
                  await database.insertTask(taskName, false);
                  _loadTasks();
                }
                Navigator.of(context).pop();
              },
              child: const Text('Add', style: TextStyle(color: Colors.white)),
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(
                    const Color.fromARGB(255, 255, 102, 0)),
                elevation: MaterialStateProperty.all<double>(0),
                overlayColor: MaterialStateProperty.resolveWith<Color?>(
                  (Set<MaterialState> states) {
                    if (states.contains(MaterialState.pressed)) {
                      return const Color.fromARGB(255, 255, 179, 0);
                    }
                    return null;
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  /// Toggles task completion status.
  void _toggleTaskCompletion(int index, bool completed) async {
    TodoItem updatedTask = todoItems[index].copyWith(completed: !completed);
    await database.updateTask(updatedTask);
    _loadTasks();
  }

  @override
  Widget build(BuildContext context) {
    List<TodoItem> completedTasks =
        todoItems.where((task) => task.completed).toList();
    List<TodoItem> incompleteTasks =
        todoItems.where((task) => !task.completed).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'To-Do List',
          style: TextStyle(
              fontSize: 24, fontWeight: FontWeight.w500, color: Colors.white),
        ),
        backgroundColor: const Color.fromARGB(255, 255, 183, 0),
        centerTitle: true,
      ),
      backgroundColor: Color.fromARGB(255, 255, 248, 225),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTaskList(incompleteTasks, false),
            _buildTaskList(completedTasks, true),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _addNewTask(context);
        },
        backgroundColor: const Color.fromARGB(255, 255, 157, 0),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  /// Builds the task list for either completed or incomplete tasks.
  Widget _buildTaskList(List<TodoItem> tasks, bool isCompleted) {
    return tasks.isEmpty
        ? const SizedBox.shrink()
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isCompleted)
                const Padding(
                  padding: EdgeInsets.only(top: 16.0, bottom: 8.0),
                  child: Text(
                    'Completed Tasks',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.normal,
                        color: Colors.black),
                  ),
                ),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: tasks.length,
                itemBuilder: (context, index) {
                  return _buildTaskTile(tasks[index]);
                },
              ),
            ],
          );
  }

  /// Builds a tile for a single task item.
  Widget _buildTaskTile(TodoItem task) {
    return Container(
      decoration: BoxDecoration(
        color: Color.fromARGB(255, 253, 233, 208),
        borderRadius: BorderRadius.circular(8.0),
      ),
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      padding: const EdgeInsets.all(10.0),
      child: ListTile(
        title: Text(
          task.name,
          style: TextStyle(
            decoration: task.completed ? TextDecoration.lineThrough : null,
          ),
        ),
        leading: Checkbox(
          value: task.completed,
          onChanged: (isChecked) {
            _toggleTaskCompletion(todoItems.indexOf(task), task.completed);
          },
          fillColor: MaterialStateProperty.resolveWith<Color?>(
            (Set<MaterialState> states) {
              if (task.completed) {
                return const Color.fromARGB(255, 255, 128, 0);
              } else {
                return Colors.white;
              }
            },
          ),
          checkColor: Colors.white,
        ),
      ),
    );
  }
}
