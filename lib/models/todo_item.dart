/// Single to-do item.
class TodoItem {
  final int id;
  final String name;
  final bool completed;

  /// Creating a new to-do item.
  TodoItem({
    required this.id,
    required this.name,
    required this.completed,
  });

  /// Creates copy of the current to-do item and allows overrides (Completed tasks)
  TodoItem copyWith({
    int? id,
    String? name,
    bool? completed,
  }) {
    return TodoItem(
      id: id ?? this.id,
      name: name ?? this.name,
      completed: completed ?? this.completed,
    );
  }
}
