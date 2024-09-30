import 'package:flutter/material.dart';

/// Widget displaying a to-do item with a checkbox.
class TodoTile extends StatelessWidget {
  /// The name of the task.
  final String taskName;

  /// Whether the task is completed.
  final bool taskCompleted;

  /// Callback for checkbox state changes.
  final ValueChanged<bool?> onChanged;

  const TodoTile({
    Key? key,
    required this.taskName,
    required this.taskCompleted,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      /// Displays task name with a line-through if completed.
      title: Text(
        taskName,
        style: TextStyle(
          decoration: taskCompleted ? TextDecoration.lineThrough : null,
        ),
      ),
      leading: Checkbox(
        value: taskCompleted,
        onChanged: onChanged,

        /// Checkbox color based on completion status.
        fillColor: MaterialStateProperty.resolveWith<Color?>(
          (Set<MaterialState> states) {
            return taskCompleted
                ? Color.fromARGB(255, 255, 119, 0)
                : Colors.white;
          },
        ),

        checkColor: Colors.white,
      ),
    );
  }
}
