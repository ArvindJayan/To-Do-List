import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

/// Helper class for managing to-do items.
class TodoDatabase {
  static Database? _database;
  static final _tableName = 'tasks';

  // Singleton instance
  static final TodoDatabase instance = TodoDatabase._privateConstructor();

  TodoDatabase._privateConstructor();

  /// Gets database connection, initializing if necessary.
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  /// Initializes the database.
  Future<Database> _initDatabase() async {
    return openDatabase(
      join(await getDatabasesPath(), 'todo_database.db'),
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE $_tableName(id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, completed INTEGER)',
        );
      },
      version: 1,
    );
  }

  /// Inserts task into the database.
  Future<void> insertTask(String name, bool completed) async {
    final db = await database;
    await db.insert(
      _tableName,
      {'name': name, 'completed': completed ? 1 : 0},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Retrieves all tasks from the database.
  Future<List<TodoItem>> getTasks() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(_tableName);
    return List.generate(maps.length, (i) {
      return TodoItem(
        id: maps[i]['id'],
        name: maps[i]['name'],
        completed: maps[i]['completed'] == 1,
      );
    });
  }

  /// Updates task completion status.
  Future<void> updateTask(TodoItem task) async {
    final db = await database;
    await db.update(
      _tableName,
      {'completed': task.completed ? 1 : 0},
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  /// Delete task from the database.
  Future<void> deleteTask(int id) async {
    final db = await database;
    await db.delete(
      _tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Closes database connection.
  Future<void> close() async {
    final db = await database;
    db.close();
  }
}

/// Model class for a to-do item.
class TodoItem {
  int id;
  String name;
  bool completed;

  TodoItem({required this.id, required this.name, required this.completed});

  /// Creates a copy of this to-do item and replaces certain fields.
  TodoItem copyWith({int? id, String? name, bool? completed}) {
    return TodoItem(
      id: id ?? this.id,
      name: name ?? this.name,
      completed: completed ?? this.completed,
    );
  }
}
